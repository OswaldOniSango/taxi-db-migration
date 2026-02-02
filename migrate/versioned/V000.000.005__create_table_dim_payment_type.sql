--DIM_PAYMENT_TYPE
CREATE OR REPLACE TABLE DIM_PAYMENT_TYPE (
  PAYMENT_TYPE              NUMBER(38,0)        NOT NULL            COMMENT 'Payment type identifier from NYC TLC trip data.',
  PAYMENT_TYPE_DESC         VARCHAR(20)         NOT NULL            COMMENT 'Short description for the payment type.',
  IS_ACTIVE                 BOOLEAN             DEFAULT TRUE        COMMENT 'Indicates whether this dimension record is active.',
  CREATE_TIMESTAMP          TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()   COMMENT 'Record creation timestamp.',
  LAST_UPDATE_TIMESTAMP     TIMESTAMP_NTZ(9)    DEFAULT SYSDATE()   COMMENT 'Record last update timestamp.'
);