CREATE OR REPLACE PROCEDURE suspend_all_tasks()
    RETURNS VARCHAR
    LANGUAGE SQL
AS
$$
    BEGIN
    SHOW TASKS;
    CREATE OR REPLACE TEMP TABLE TASK_LIST AS (
        SELECT * FROM TABLE(result_scan(last_query_id())) WHERE "schema_name" = current_schema()
    );

    CREATE OR REPLACE TEMP TABLE TASK_DAG AS (
        WITH RECURSIVE
            root_tasks AS (
                SELECT * FROM task_list WHERE array_size("predecessors") = 0
            )
                , task_dag (name, depth) AS (
            SELECT
                concat(current_database(), '.', current_schema(), '.', rt."name") AS name,
                0 AS depth
            FROM root_tasks rt
            UNION ALL
            SELECT
                concat(current_database(), '.', current_schema(), '.', tl."name") AS name
                    , td.depth + 1 AS depth
            FROM task_dag td
                     INNER JOIN task_list tl
                                ON array_contains(td.name::variant, tl."predecessors")
        )

        SELECT * FROM task_dag ORDER BY depth ASC
    );

    LET alter_task_query VARCHAR;
    LET task_dag_array ARRAY := (SELECT array_agg(name) FROM TASK_DAG);
    FOR i IN 0 to array_size(:task_dag_array)-1 DO
            alter_task_query := REPLACE('ALTER TASK <task_name> SUSPEND;', '<task_name>', get(:task_dag_array, :i));
    EXECUTE IMMEDIATE :alter_task_query;
    END FOR;

    RETURN 'All Tasks SUSPENDED!';
    END;
$$
;