-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 10: Oracle Scheduler Jobs
-- Tasks 1 & 2: Simple One-Time Scheduler Job and Recurring Job
-- Author: Ya'Rab Almamri
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 10: Oracle Scheduler Jobs';
PROMPT 'Tasks 1 & 2: One-Time and Recurring Jobs';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: Simple One-Time Scheduler Job
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: Simple One-Time Scheduler Job';
PROMPT '==========================================';

-- ============================================================
-- Create one-time DBMS_SCHEDULER job named JOB_GREET_EMPLOYEES
-- Runs 2 minutes from now and executes an anonymous PL/SQL block
-- that prints 'Payroll System Initialized' to DBMS_OUTPUT
-- and inserts a record into EMPLOYEE_LOG
-- ============================================================

PROMPT '';
PROMPT 'Creating one-time scheduler job JOB_GREET_EMPLOYEES...';

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_GREET_EMPLOYEES',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                                DBMS_OUTPUT.PUT_LINE(''Payroll System Initialized'');
                                INSERT INTO EMPLOYEE_LOG (log_id, emp_id, action, log_timestamp)
                                VALUES (seq_employee_log.NEXTVAL, NULL, ''SYSTEM INIT'', SYSDATE);
                                COMMIT;
                            END;',
        start_date      => SYSTIMESTAMP + INTERVAL '2' MINUTE,
        enabled         => TRUE
    );
    
    DBMS_OUTPUT.PUT_LINE('Job JOB_GREET_EMPLOYEES created successfully.');
    DBMS_OUTPUT.PUT_LINE('Job will run in 2 minutes.');
END;
/


-- ============================================================
-- TASK 2: Recurring Job - Daily Leave Report
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: Recurring Job - Daily Leave Report';
PROMPT '==========================================';

-- ============================================================
-- Create recurring DBMS_SCHEDULER job named JOB_DAILY_LEAVE_REPORT
-- Runs every day at 07:00 AM
-- Counts leave records taken that day and inserts a summary into EMPLOYEE_LOG
-- ============================================================

PROMPT '';
PROMPT 'Creating recurring scheduler job JOB_DAILY_LEAVE_REPORT...';

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_DAILY_LEAVE_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                                DECLARE
                                    v_leave_count NUMBER;
                                    v_report_date DATE := TRUNC(SYSDATE);
                                BEGIN
                                    SELECT COUNT(*)
                                    INTO v_leave_count
                                    FROM LEAVE
                                    WHERE TRUNC(leave_date) = v_report_date;
                                    
                                    INSERT INTO EMPLOYEE_LOG (log_id, emp_id, action, log_timestamp)
                                    VALUES (seq_employee_log.NEXTVAL, NULL, 
                                           ''DAILY LEAVE REPORT: '' || v_leave_count || '' leave records today'', 
                                           SYSDATE);
                                    COMMIT;
                                    DBMS_OUTPUT.PUT_LINE(''Daily leave report generated. Total leaves: '' || v_leave_count);
                                END;
                            END;',
        start_date      => TRUNC(SYSDATE) + INTERVAL '7' HOUR,
        repeat_interval => 'FREQ=DAILY; BYHOUR=7; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );
    
    DBMS_OUTPUT.PUT_LINE('Job JOB_DAILY_LEAVE_REPORT created successfully.');
    DBMS_OUTPUT.PUT_LINE('Job will run daily at 07:00 AM.');
END;
/

-- ============================================================
-- Show job definition
-- ============================================================

PROMPT '';
PROMPT 'Job definition for JOB_DAILY_LEAVE_REPORT:';

SELECT 
    job_name,
    job_type,
    job_action,
    start_date,
    repeat_interval,
    enabled,
    state
FROM user_scheduler_jobs
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';

-- ============================================================
-- Additional Verification
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Verification - Scheduler Jobs Created';
PROMPT '==========================================';

-- List all scheduler jobs
PROMPT '';
PROMPT 'All scheduler jobs:';

SELECT 
    job_name,
    job_type,
    enabled,
    state,
    TO_CHAR(last_start_date, 'YYYY-MM-DD HH24:MI:SS') AS last_start_date,
    TO_CHAR(next_run_date, 'YYYY-MM-DD HH24:MI:SS') AS next_run_date
FROM user_scheduler_jobs
WHERE job_name IN ('JOB_GREET_EMPLOYEES', 'JOB_DAILY_LEAVE_REPORT')
ORDER BY job_name;

-- Check EMPLOYEE_LOG for entries
PROMPT '';
PROMPT 'EMPLOYEE_LOG entries:';

SELECT 
    log_id,
    emp_id,
    action,
    TO_CHAR(log_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS log_timestamp
FROM EMPLOYEE_LOG
WHERE action IN ('SYSTEM INIT', 'DAILY LEAVE REPORT')
ORDER BY log_timestamp DESC;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All scheduler job tasks executed successfully!';
PROMPT '==========================================';

