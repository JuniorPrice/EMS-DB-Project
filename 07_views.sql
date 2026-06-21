-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 07: Views
-- Tasks 1 & 2: Simple Read-Only View and Payroll Dashboard View
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 07: Views';
PROMPT 'Tasks 1 & 2: Simple Read-Only View and Payroll Dashboard View';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: Simple Read-Only View
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: Simple Read-Only View';
PROMPT '==========================================';

-- ============================================================
-- Create view VW_EMPLOYEE_SUMMARY
-- Returns: emp_ID, full name, gender, age, department name, 
--          and job title (from QUALIFICATION)
-- ============================================================

PROMPT '';
PROMPT 'Creating VW_EMPLOYEE_SUMMARY view...';

CREATE OR REPLACE VIEW VW_EMPLOYEE_SUMMARY AS
SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS full_name,
    e.gender,
    e.age,
    jd.name AS department_name,
    q.position AS job_title
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
JOIN QUALIFICATION q ON e.emp_ID = q.emp_ID;

PROMPT 'View VW_EMPLOYEE_SUMMARY created successfully.';

-- ============================================================
-- Query 1(a): List all female employees over 30
-- ============================================================

PROMPT '';
PROMPT 'Query 1(a): Female employees over 30';
PROMPT '-------------------------------------';

SELECT *
FROM VW_EMPLOYEE_SUMMARY
WHERE gender = 'F' AND age > 30
ORDER BY age DESC;

-- ============================================================
-- Query 1(b): Try to INSERT a row through this view and 
-- document the Oracle error message
-- ============================================================

PROMPT '';
PROMPT 'Query 1(b): Attempting INSERT through view (will fail)';
PROMPT '----------------------------------------------------------';

-- This INSERT will fail because the view is based on multiple tables
-- and contains columns from different base tables
INSERT INTO VW_EMPLOYEE_SUMMARY (emp_ID, full_name, gender, age, department_name, job_title)
VALUES (99, 'Test User', 'M', 25, 'Test Dept', 'Test Job');

-- The error:
-- ORA-01779: cannot modify a column which maps to a non key-preserved table

-- ============================================================
-- TASK 2: Payroll Dashboard View
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: Payroll Dashboard View';
PROMPT '==========================================';

-- ============================================================
-- Create view VW_PAYROLL_DASHBOARD
-- Returns: payroll_ID, employee full name, department, 
--          salary amount, bonus, leave reason, payroll date, 
--          and total_amount
-- ============================================================

PROMPT '';
PROMPT 'Creating VW_PAYROLL_DASHBOARD view...';

CREATE OR REPLACE VIEW VW_PAYROLL_DASHBOARD AS
SELECT 
    p.payroll_ID,
    e.fname || ' ' || e.lname AS employee_full_name,
    jd.name AS department,
    sb.amount AS salary_amount,
    sb.bonus,
    l.reason AS leave_reason,
    p.payroll_date,
    p.total_amount
FROM PAYROLL p
JOIN EMPLOYEE e ON p.emp_ID = e.emp_ID
JOIN JOB_DEPARTMENT jd ON p.job_ID = jd.job_ID
JOIN SALARY_BONUS sb ON p.salary_ID = sb.salary_ID
LEFT JOIN LEAVE l ON e.emp_ID = l.emp_ID;

PROMPT 'View VW_PAYROLL_DASHBOARD created successfully.';

-- ============================================================
-- Query: Find the top 5 payroll records by total_amount
-- ============================================================

PROMPT '';
PROMPT 'Query: Top 5 payroll records by total_amount';
PROMPT '---------------------------------------------';

SELECT *
FROM VW_PAYROLL_DASHBOARD
ORDER BY total_amount DESC
FETCH FIRST 5 ROWS ONLY;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All view tasks executed successfully!';
PROMPT '==========================================';