CREATE OR REPLACE PROCEDURE SUSPEND_ALL_TASKS_AND_WAIT_COMPLETION()
    RETURNS VARCHAR
    LANGUAGE SQL
    -- Necessary for information schema queries (num_running_tasks function)
    EXECUTE AS CALLER
AS
$$
    BEGIN
    CALL SUSPEND_ALL_TASKS();

    LET num_running_tasks NUMBER := (SELECT num_running_tasks(current_schema()));
    WHILE (:num_running_tasks > 0) DO
        num_running_tasks := (SELECT num_running_tasks(current_schema()));
        -- Wait 10 seconds per check
        CALL SYSTEM$WAIT(10);
    END WHILE;
    return 'Tasks SUSPENDED and COMPLETED';
    END;
$$
;