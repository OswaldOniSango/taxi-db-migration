--DIM_VENDOR
CREATE OR REPLACE TABLE DIM_VENDOR (
  VENDOR_ID                 NUMBER(38,0)        NOT NULL            COMMENT 'Vendor identifier for the taxi meter provider.',
  VENDOR_NAME               VARCHAR(50)                             COMMENT 'Short vendor name.',
  IS_ACTIVE                 BOOLEAN             DEFAULT TRUE        COMMENT 'Indicates whether this dimension record is active.',
  CREATE_TIMESTAMP          TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()   COMMENT 'Record creation timestamp.',
  LAST_UPDATE_TIMESTAMP     TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()   COMMENT 'Record last update timestamp.'
);