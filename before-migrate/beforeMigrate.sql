ALTER SESSION SET JDBC_QUERY_RESULT_FORMAT='JSON';

------------------------------------
--         Schema Creation        --
------------------------------------

BEGIN
    CREATE SCHEMA IF NOT EXISTS ${schema};
END;

USE SCHEMA ${schema};

-- JAR Stage (Should have been created by jar deployment pipelines)
CREATE STAGE IF NOT EXISTS ${schema}.JAR_LIB