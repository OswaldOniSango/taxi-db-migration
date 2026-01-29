CREATE OR REPLACE PROCEDURE handle_error(process_name STRING(50), sql_code NUMBER(10), sql_state STRING(10), sql_errm STRING, context VARIANT)
    RETURNS VARCHAR
    LANGUAGE SQL
    AS
    $$
    BEGIN
        INSERT INTO RUNTIME_ERROR(process, sql_error, context) select :process_name, object_construct('sql_code', :sql_code, 'sql_state', :sql_state, 'sql_error_msg', :sql_errm), :context;
        return 'OK';
    END;
    $$
;
