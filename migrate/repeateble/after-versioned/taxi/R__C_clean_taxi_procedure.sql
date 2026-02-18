CREATE OR REPLACE PROCEDURE SP_BUILD_TRAVEL_CLEAN(limit_rows NUMBER)
RETURNS VARIANT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
  v_limit NUMBER DEFAULT COALESCE(:limit_rows, 1000);
  v_rows_merged NUMBER DEFAULT 0;
  v_rows_inserted NUMBER DEFAULT 0;
  v_rows_updated NUMBER DEFAULT 0;
BEGIN

  --------------------------------------------------------------------
  -- Temp "stream" sample (demo): pull N rows from RAW
  --------------------------------------------------------------------
  CREATE OR REPLACE TEMPORARY TABLE taxi_stream AS (
    SELECT *
    FROM TRAVEL_RAW
    ORDER BY RAW_ID
    LIMIT :v_limit
  );

  --------------------------------------------------------------------
  -- Exceptions (SQL-side addon)
  -- Build FINAL_EXCEPTIONS from RAW fields + derived rules
  --------------------------------------------------------------------
  CREATE OR REPLACE TEMPORARY TABLE taxi_output_enriched AS
  WITH base AS (
    SELECT
      RAW_ID AS SOURCE_RAW_ID,

      VENDOR_ID,
      TPEP_PICKUP_DATETIME,
      TPEP_DROPOFF_DATETIME,
      /* derived */
      CAST(TPEP_PICKUP_DATETIME AS DATE) AS TRAVEL_DATE,

      PASSENGER_COUNT,
      TRIP_DISTANCE,
      RATE_CODE_ID,
      STORE_AND_FWD_FLAG,
      PU_LOCATION_ID,
      DO_LOCATION_ID,
      PAYMENT_TYPE,

      FARE_AMOUNT,
      EXTRA,
      MTA_TAX,
      TIP_AMOUNT,
      TOLLS_AMOUNT,
      IMPROVEMENT_SURCHARGE,
      TOTAL_AMOUNT,
      CONGESTION_SURCHARGE,
      AIRPORT_FEE,
      CBD_CONGESTION_FEE
    FROM taxi_stream
  ),
  sql_exceptions AS (
    SELECT
      b.*,
      ARRAY_CONSTRUCT_COMPACT(
        IFF(TPEP_PICKUP_DATETIME IS NULL, 'pickup_null', NULL),
        IFF(TPEP_DROPOFF_DATETIME IS NULL, 'dropoff_null', NULL),
        IFF(TPEP_PICKUP_DATETIME IS NOT NULL AND TPEP_DROPOFF_DATETIME IS NOT NULL AND TPEP_DROPOFF_DATETIME < TPEP_PICKUP_DATETIME, 'pickup_after_dropoff', NULL),

        IFF(TRIP_DISTANCE IS NULL, 'distance_null', NULL),
        IFF(TRIP_DISTANCE < 0, 'distance_negative', NULL),
        IFF(TRIP_DISTANCE > 200, 'distance_unrealistic', NULL),

        IFF(TOTAL_AMOUNT IS NULL, 'total_amount_null', NULL),
        IFF(TOTAL_AMOUNT < 0, 'total_amount_negative', NULL),

        IFF(PASSENGER_COUNT < 0 OR PASSENGER_COUNT > 8, 'passenger_count_out_of_range', NULL)
      ) AS SQL_EXC
    FROM base b
  )
  SELECT
    SOURCE_RAW_ID,

    VENDOR_ID,
    /* map RAW -> CLEAN */
    CAST(TPEP_PICKUP_DATETIME AS TIMESTAMP_NTZ(9))  AS PICKUP_DATETIME,
    CAST(TPEP_DROPOFF_DATETIME AS TIMESTAMP_NTZ(9)) AS DROPOFF_DATETIME,
    CAST(TRAVEL_DATE AS TIMESTAMP_NTZ(9))           AS TRAVEL_DATE,

    PASSENGER_COUNT,
    TRIP_DISTANCE,
    RATE_CODE_ID,
    STORE_AND_FWD_FLAG,
    PU_LOCATION_ID,
    DO_LOCATION_ID,
    PAYMENT_TYPE,

    FARE_AMOUNT,
    EXTRA,
    MTA_TAX,
    TIP_AMOUNT,
    TOLLS_AMOUNT,
    IMPROVEMENT_SURCHARGE,
    TOTAL_AMOUNT,
    CONGESTION_SURCHARGE,
    AIRPORT_FEE,
    CBD_CONGESTION_FEE,

    TO_VARIANT(COALESCE(SQL_EXC, ARRAY_CONSTRUCT())) AS FINAL_EXCEPTIONS
  FROM sql_exceptions;

  --------------------------------------------------------------------
  -- Merge into CLEAN
  --------------------------------------------------------------------
  MERGE INTO TRAVEL_CLEAN t
  USING (
    SELECT
      SOURCE_RAW_ID,

      VENDOR_ID,
      PICKUP_DATETIME,
      DROPOFF_DATETIME,
      TRAVEL_DATE,
      PASSENGER_COUNT,
      TRIP_DISTANCE,
      RATE_CODE_ID,
      STORE_AND_FWD_FLAG,
      PU_LOCATION_ID,
      DO_LOCATION_ID,
      PAYMENT_TYPE,

      FARE_AMOUNT,
      EXTRA,
      MTA_TAX,
      TIP_AMOUNT,
      TOLLS_AMOUNT,
      IMPROVEMENT_SURCHARGE,
      TOTAL_AMOUNT,
      CONGESTION_SURCHARGE,
      AIRPORT_FEE,
      CBD_CONGESTION_FEE,

      FINAL_EXCEPTIONS AS DATA_EXCEPTIONS
    FROM taxi_output_enriched
  ) s
  ON t.SOURCE_RAW_ID = s.SOURCE_RAW_ID

  WHEN MATCHED THEN
    UPDATE SET
      t.VENDOR_ID = s.VENDOR_ID,
      t.PICKUP_DATETIME = s.PICKUP_DATETIME,
      t.DROPOFF_DATETIME = s.DROPOFF_DATETIME,
      t.TRAVEL_DATE = s.TRAVEL_DATE,
      t.PASSENGER_COUNT = s.PASSENGER_COUNT,
      t.TRIP_DISTANCE = s.TRIP_DISTANCE,
      t.RATE_CODE_ID = s.RATE_CODE_ID,
      t.STORE_AND_FWD_FLAG = s.STORE_AND_FWD_FLAG,
      t.PU_LOCATION_ID = s.PU_LOCATION_ID,
      t.DO_LOCATION_ID = s.DO_LOCATION_ID,
      t.PAYMENT_TYPE = s.PAYMENT_TYPE,

      t.FARE_AMOUNT = s.FARE_AMOUNT,
      t.EXTRA = s.EXTRA,
      t.MTA_TAX = s.MTA_TAX,
      t.TIP_AMOUNT = s.TIP_AMOUNT,
      t.TOLLS_AMOUNT = s.TOLLS_AMOUNT,
      t.IMPROVEMENT_SURCHARGE = s.IMPROVEMENT_SURCHARGE,
      t.TOTAL_AMOUNT = s.TOTAL_AMOUNT,
      t.CONGESTION_SURCHARGE = s.CONGESTION_SURCHARGE,
      t.AIRPORT_FEE = s.AIRPORT_FEE,
      t.CBD_CONGESTION_FEE = s.CBD_CONGESTION_FEE,

      t.DATA_EXCEPTIONS = s.DATA_EXCEPTIONS,
      t.LAST_UPDATE_TIMESTAMP = SYSDATE()

  WHEN NOT MATCHED THEN
    INSERT (
      SOURCE_RAW_ID,

      VENDOR_ID,
      PICKUP_DATETIME,
      DROPOFF_DATETIME,
      TRAVEL_DATE,
      PASSENGER_COUNT,
      TRIP_DISTANCE,
      RATE_CODE_ID,
      STORE_AND_FWD_FLAG,
      PU_LOCATION_ID,
      DO_LOCATION_ID,
      PAYMENT_TYPE,

      FARE_AMOUNT,
      EXTRA,
      MTA_TAX,
      TIP_AMOUNT,
      TOLLS_AMOUNT,
      IMPROVEMENT_SURCHARGE,
      TOTAL_AMOUNT,
      CONGESTION_SURCHARGE,
      AIRPORT_FEE,
      CBD_CONGESTION_FEE,

      DATA_EXCEPTIONS,
      CREATE_TIMESTAMP,
      LAST_UPDATE_TIMESTAMP
    )
    VALUES (
      s.SOURCE_RAW_ID,

      s.VENDOR_ID,
      s.PICKUP_DATETIME,
      s.DROPOFF_DATETIME,
      s.TRAVEL_DATE,
      s.PASSENGER_COUNT,
      s.TRIP_DISTANCE,
      s.RATE_CODE_ID,
      s.STORE_AND_FWD_FLAG,
      s.PU_LOCATION_ID,
      s.DO_LOCATION_ID,
      s.PAYMENT_TYPE,

      s.FARE_AMOUNT,
      s.EXTRA,
      s.MTA_TAX,
      s.TIP_AMOUNT,
      s.TOLLS_AMOUNT,
      s.IMPROVEMENT_SURCHARGE,
      s.TOTAL_AMOUNT,
      s.CONGESTION_SURCHARGE,
      s.AIRPORT_FEE,
      s.CBD_CONGESTION_FEE,

      s.DATA_EXCEPTIONS,
      SYSDATE(),
      SYSDATE()
    );

  --------------------------------------------------------------------
  -- Basic metrics to return
  --------------------------------------------------------------------
  v_rows_merged := (SELECT COUNT(*) FROM taxi_output_enriched);

  v_rows_inserted := (
    SELECT COUNT(*)
    FROM taxi_output_enriched e
    LEFT JOIN TRAVEL_CLEAN c
      ON c.SOURCE_RAW_ID = e.SOURCE_RAW_ID
    WHERE c.SOURCE_RAW_ID IS NULL
  );

  v_rows_updated := v_rows_merged - v_rows_inserted;

  RETURN OBJECT_CONSTRUCT(
    'status','OK',
    'limit_rows', v_limit,
    'source_rows', (SELECT COUNT(*) FROM taxi_stream),
    'processed_rows', v_rows_merged,
    'inserted_estimate', v_rows_inserted,
    'updated_estimate', v_rows_updated
  );

  DROP TABLE IF EXISTS taxi_output_enriched;
  DROP TABLE IF EXISTS taxi_stream;


END;
$$;