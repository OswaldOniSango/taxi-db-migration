CREATE OR REPLACE PROCEDURE resume_all_tasks()
    RETURNS VARCHAR
    LANGUAGE SQL
AS
$$
    BEGIN
    SHOW TASKS;
    CREATE OR REPLACE TEMP TABLE ROOT_TASK AS (
        SELECT * FROM TABLE(result_scan(last_query_id())) WHERE "schema_name" = current_schema() AND array_size("predecessors") = 0
    );

    LET alter_task_query VARCHAR;
    LET root_task_array ARRAY := (SELECT array_agg("name") FROM ROOT_TASK);
    LET task_name VARCHAR;
    FOR i IN 0 to array_size(:root_task_array)-1 DO
        task_name := (SELECT get(:root_task_array, :i));
        SELECT SYSTEM$TASK_DEPENDENTS_ENABLE(:task_name);
    END FOR;

    RETURN 'All Tasks RESUMED!';
    END;
$$
;