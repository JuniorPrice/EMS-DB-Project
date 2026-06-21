-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 09: Triggers
-- Tasks 1 & 2: BEFORE INSERT and AFTER INSERT Triggers
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 09: Triggers';
PROMPT 'Tasks 1 & 2: BEFORE INSERT and AFTER INSERT Triggers';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: BEFORE INSERT - Auto-assign emp_ID
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: BEFORE INSERT Trigger - Auto-assign emp_ID';
PROMPT '==========================================';

-- ============================================================
-- Create BEFORE INSERT trigger named TRG_EMP_ID on EMPLOYEE table
-- If inserted emp_ID is NULL, populate it from seq_employee.NEXTVAL
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_EMP_ID
BEFORE INSERT ON EMPLOYEE
FOR EACH ROW
BEGIN
    IF :NEW.emp_ID IS NULL THEN
        SELECT seq_employee.NEXTVAL INTO :NEW.emp_ID FROM DUAL;
    END IF;
END TRG_EMP_ID;
/

PROMPT 'Trigger TRG_EMP_ID created successfully.';

-- ============================================================
-- Test: INSERT an employee without specifying emp_ID
-- ============================================================

PROMPT '';
PROMPT 'Test: Inserting employee without emp_ID (auto-assigned)';
PROMPT '--------------------------------------------------------';

INSERT INTO EMPLOYEE (
    fname, lname, gender, age, contact_add, 
    emp_email, emp_pass, job_ID, salary_ID
) VALUES (
    'Auto', 'Assign', 'M', 28, '789 Trigger St, Test City',
    'auto.assign@company.com', 'autopass123', 1, 1
);

COMMIT;

-- Verify the employee was inserted with auto-assigned emp_ID
PROMPT '';
PROMPT 'Verification: New employee with auto-assigned emp_ID:';
SELECT 
    emp_ID,
    fname || ' ' || lname AS "Full Name",
    emp_email
FROM EMPLOYEE
WHERE emp_email = 'auto.assign@company.com';

-- ============================================================
-- TASK 2: AFTER INSERT - Welcome Log
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: AFTER INSERT Trigger - Welcome Log';
PROMPT '==========================================';

-- ============================================================
-- Create table EMPLOYEE_LOG
-- ============================================================

PROMPT '';
PROMPT 'Creating EMPLOYEE_LOG table...';

CREATE TABLE EMPLOYEE_LOG (
    log_id         NUMBER PRIMARY KEY,
    emp_id         NUMBER,
    action         VARCHAR2(50),
    log_timestamp  DATE
);

-- Create sequence for EMPLOYEE_LOG
CREATE SEQUENCE seq_employee_log
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

PROMPT 'Table EMPLOYEE_LOG and sequence created successfully.';

-- ============================================================
-- Create AFTER INSERT trigger named TRG_EMP_WELCOME_LOG
-- Inserts log row with action = 'NEW HIRE' whenever new employee is added
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_EMP_WELCOME_LOG
AFTER INSERT ON EMPLOYEE
FOR EACH ROW
BEGIN
    INSERT INTO EMPLOYEE_LOG (log_id, emp_id, action, log_timestamp)
    VALUES (seq_employee_log.NEXTVAL, :NEW.emp_ID, 'NEW HIRE', SYSDATE);
END TRG_EMP_WELCOME_LOG;
/

PROMPT 'Trigger TRG_EMP_WELCOME_LOG created successfully.';

-- ============================================================
-- Test: Insert 2 employees and query EMPLOYEE_LOG
-- ============================================================

PROMPT '';
PROMPT 'Test: Inserting 2 new employees...';
PROMPT '------------------------------------';

-- Insert first employee
INSERT INTO EMPLOYEE (
    fname, lname, gender, age, contact_add, 
    emp_email, emp_pass, job_ID, salary_ID
) VALUES (
    'Trigger', 'Test1', 'F', 32, '101 Log St, Test City',
    'trigger.test1@company.com', 'trigger1pass', 2, 2
);

-- Insert second employee
INSERT INTO EMPLOYEE (
    fname, lname, gender, age, contact_add, 
    emp_email, emp_pass, job_ID, salary_ID
) VALUES (
    'Trigger', 'Test2', 'M', 45, '202 Log Ave, Test City',
    'trigger.test2@company.com', 'trigger2pass', 3, 3
);

COMMIT;

-- ============================================================
-- Query EMPLOYEE_LOG to verify log entries
-- ============================================================

PROMPT '';
PROMPT 'Verification: EMPLOYEE_LOG entries:';
PROMPT '------------------------------------';

SELECT 
    log_id,
    emp_id,
    action,
    TO_CHAR(log_timestamp, 'YYYY-MM-DD HH24:MI:SS') AS log_timestamp
FROM EMPLOYEE_LOG
ORDER BY log_timestamp DESC;

-- ============================================================
-- Additional Verification
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Verification - Triggers Created';
PROMPT '==========================================';

-- Verify both triggers exist
SELECT 
    trigger_name,
    trigger_type,
    triggering_event,
    table_name,
    status
FROM user_triggers
WHERE trigger_name IN ('TRG_EMP_ID', 'TRG_EMP_WELCOME_LOG')
ORDER BY trigger_name;

-- Show trigger source code
PROMPT '';
PROMPT 'TRG_EMP_ID source:';
SELECT text 
FROM user_source 
WHERE name = 'TRG_EMP_ID' 
ORDER BY line;

PROMPT '';
PROMPT 'TRG_EMP_WELCOME_LOG source:';
SELECT text 
FROM user_source 
WHERE name = 'TRG_EMP_WELCOME_LOG' 
ORDER BY line;

-- Show EMPLOYEE_LOG count
PROMPT '';
PROMPT 'Total log entries:';
SELECT COUNT(*) AS "Total Log Entries" FROM EMPLOYEE_LOG;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All trigger tasks executed successfully!';
PROMPT '==========================================';