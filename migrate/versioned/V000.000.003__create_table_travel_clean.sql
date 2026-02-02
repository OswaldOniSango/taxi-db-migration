CREATE TABLE IF NOT EXISTS TRAVEL_CLEAN (
  RAW_ID                    NUMBER(38,0)    NOT NULL    AUTOINCREMENT   COMMENT '',

  -- CAMPOS DEL DATASET (YELLOW TAXI)
  VENDOR_ID                 NUMBER(38,0)                                COMMENT 'A code indicating the TPEP provider that provided the record. 1 = Creative Mobile Technologies, LLC 2 = Curb Mobility, LLC 6 = Myle Technologies Inc 7 = Helix',
  PICKUP_DATETIME           TIMESTAMP_NTZ(9)                            COMMENT 'The date and time when the meter was engaged.',
  DROPOFF_DATETIME          TIMESTAMP_NTZ(9)                            COMMENT 'The date and time when the meter was disengaged.',
  TRAVEL_DATE               TIMESTAMP_NTZ(9)                            COMMENT 'The date of the trip (derived from the pickup_datetime).',
  PASSENGER_COUNT           NUMBER(38,0)                                COMMENT 'The number of passengers in the vehicle.',
  TRIP_DISTANCE             NUMBER(38,0)                                COMMENT 'The elapsed trip distance in miles reported by the taximeter.',
  RATE_CODE_ID              NUMBER(38,0)                                COMMENT 'The final rate code in effect at the end of the trip. 1 = Standard rate 2 = JFK 3 = Newark 4 = Nassau or Westchester 5 = Negotiated fare 6 = Group ride 99 = Null/unknown',
  STORE_AND_FWD_FLAG        VARCHAR(20)                                 COMMENT 'This flag indicates whether the trip record was held in vehicle memory before sending to the vendor, aka “store and forward,” because the vehicle did not have a connection to the server. Y = store and forward trip N = not a store and forward trip',
  PU_LOCATION_ID            NUMBER(38,0)                                COMMENT 'TLC Taxi Zone in which the taximeter was engaged.',
  DO_LOCATION_ID            NUMBER(38,0)                                COMMENT 'TLC Taxi Zone in which the taximeter was disengaged.',
  PAYMENT_TYPE              NUMBER(38,0)                                COMMENT 'A numeric code signifying how the passenger paid for the trip. 0 = Flex Fare trip 1 = Credit card 2 = Cash 3 = No charge 4 = Dispute 5 = Unknown 6 = Voided trip',

  FARE_AMOUNT               NUMBER(38,0)                                COMMENT 'The time-and-distance fare calculated by the meter. For additional information on the following columns, see https://www.nyc.gov/site/tlc/passengers/taxi-fare.page',
  EXTRA                     NUMBER(38,0)                                COMMENT 'Miscellaneous extras and surcharges.',
  MTA_TAX                   NUMBER(38,0)                                COMMENT 'Tax that is automatically triggered based on the metered rate in use.',
  TIP_AMOUNT                NUMBER(38,0)                                COMMENT 'Tip amount – This field is automatically populated for credit card tips. Cash tips are not included.',
  TOLLS_AMOUNT              NUMBER(38,0)                                COMMENT 'Total amount of all tolls paid in trip.',
  IMPROVEMENT_SURCHARGE     NUMBER(38,0)                                COMMENT 'Improvement surcharge assessed trips at the flag drop. The improvement surcharge began being levied in 2015.',
  TOTAL_AMOUNT              NUMBER(38,0)                                COMMENT 'The total amount charged to passengers. Does not include cash tips.',
  CONGESTION_SURCHARGE      NUMBER(38,0)                                COMMENT 'Total amount collected in trip for NYS congestion surcharge.',
  AIRPORT_FEE               NUMBER(38,0)                                COMMENT 'For pick up only at LaGuardia and John F. Kennedy Airports.',
  CBD_CONGESTION_FEE        NUMBER(38,0)                                COMMENT 'Per-trip charge for MTA''s Congestion Relief Zone starting Jan. 5, 2025.',

  DATA_EXCEPTIONS           VARIANT                                     COMMENT 'Exceptions identified while creating the record',
  CREATE_TIMESTAMP          TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()       COMMENT 'Timestamp for the Probe Sample creation',
  LAST_UPDATE_TIMESTAMP 	TIMESTAMP_NTZ (9)   DEFAULT SYSDATE()	    COMMENT 'Indicates the last time the Probe Sample State changed'
);
