BEGIN
    SHOW PROCEDURES;
    -- Check if the procedure exists for the schema
    IF (EXISTS (SELECT * FROM TABLE(result_scan(last_query_id())) WHERE "name" = 'SUSPEND_ALL_TASKS_AND_WAIT_COMPLETION') ) THEN
        -- Procedure will SUSPEND all tasks and wait until all on-going tasks finish before returning
        CALL SUSPEND_ALL_TASKS_AND_WAIT_COMPLETION();
    END IF;
END;