--DIM_RATE_CODE
CREATE OR REPLACE TABLE DIM_RATE_CODE (
  RATE_CODE_ID              NUMBER(38,0)        NOT NULL            COMMENT 'Rate code identifier from NYC TLC trip data (fare rules category).',
  RATE_CODE_DESC            VARCHAR(50)         NOT NULL            COMMENT 'Short description for the rate code.',
  IS_ACTIVE                 BOOLEAN             DEFAULT TRUE        COMMENT 'Indicates whether this dimension record is active.',
  CREATE_TIMESTAMP          TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()   COMMENT 'Record creation timestamp.',
  LAST_UPDATE_TIMESTAMP     TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()   COMMENT 'Record last update timestamp.'
);