CREATE TABLE IF NOT EXISTS RUNTIME_ERROR (
    ID                  NUMBER(38,0)         NOT NULL    AUTOINCREMENT       COMMENT 'Auto generated incremental ID for the Runtime Error',
    PROCESS             STRING(50)           NOT NULL                        COMMENT 'Name of the process in which the error occurred',
    SQL_ERROR           VARIANT                                              COMMENT 'SQL error information provided by Snowflake',
    CONTEXT             VARIANT                                              COMMENT 'Extra context information useful for insight on the error',
    CREATED_TIMESTAMP   TIMESTAMP_NTZ(9)     DEFAULT SYSDATE()               COMMENT 'Timestamp for the Error entry creation'
);
