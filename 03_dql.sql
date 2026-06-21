-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 03: SQL DQL
-- Task 2: Conditional SELECT Queries
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 03 Task 2: Conditional SELECT Queries';
PROMPT '==========================================';

-- ============================================================
-- Query (a): List all employees whose age is between 25 and 40,
-- ordered by last name ascending.
-- ============================================================

PROMPT '';
PROMPT 'Query (a): Employees aged 25-40, ordered by last name';
PROMPT '--------------------------------------------------------';

SELECT 
    emp_ID,
    fname || ' ' || lname AS Full_Name,
    gender,
    age,
    contact_add AS Address,
    emp_email AS Email
FROM EMPLOYEE
WHERE age BETWEEN 25 AND 40
ORDER BY lname ASC;

-- ============================================================
-- Query (b): Retrieve all payroll records where total_amount exceeds 5000,
-- showing employee name and department.
-- ============================================================

PROMPT '';
PROMPT 'Query (b): Payroll records with total_amount > 5000';
PROMPT '------------------------------------------------------';

SELECT 
    p.payroll_ID,
    e.fname || ' ' || e.lname AS Employee_Name,
    jd.name AS Department,
    p.total_amount,
    p.payroll_date AS Payroll_Date,
    p.report
FROM PAYROLL p
JOIN EMPLOYEE e ON p.emp_ID = e.emp_ID
JOIN JOB_DEPARTMENT jd ON p.job_ID = jd.job_ID
WHERE p.total_amount > 5000
ORDER BY p.total_amount DESC;

-- ============================================================
-- Query (c): Find all employees who have taken leave with reason
-- containing the word 'sick' (case-insensitive).
-- ============================================================

PROMPT '';
PROMPT 'Query (c): Employees with sick leave (case-insensitive)';
PROMPT '--------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS Employee_Name,
    l.leave_ID,
    l.leave_date,       
    l.reason
FROM EMPLOYEE e
JOIN LEAVE l ON e.emp_ID = l.emp_ID
WHERE LOWER(l.reason) LIKE '%sick%'
ORDER BY e.lname, l.leave_date;

-- ============================================================
-- Query (d): List all departments that have no employees assigned.
-- (Using NOT EXISTS)
-- ============================================================

PROMPT '';
PROMPT 'Query (d): Departments with no employees (using NOT EXISTS)';
PROMPT '------------------------------------------------------------';

SELECT 
    jd.job_ID,
    jd.job_dept,
    jd.name AS Department_Name,
    jd.description
FROM JOB_DEPARTMENT jd
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    WHERE e.job_ID = jd.job_ID
)
ORDER BY jd.name;

-- ============================================================
-- Alternative Query (d): Using LEFT OUTER JOIN (for comparison)
-- ============================================================

PROMPT '';
PROMPT 'Query (d) Alternative: Departments with no employees (using LEFT JOIN)';
PROMPT '----------------------------------------------------------------------';

SELECT 
    jd.job_ID,
    jd.job_dept,
    jd.name AS Department_Name,
    jd.description,
    COUNT(e.emp_ID) AS Employee_Count
FROM JOB_DEPARTMENT jd
LEFT JOIN EMPLOYEE e ON jd.job_ID = e.job_ID
GROUP BY jd.job_ID, jd.job_dept, jd.name, jd.description
HAVING COUNT(e.emp_ID) = 0
ORDER BY jd.name;

-- ============================================================
-- Additional Verification Queries (for testing)
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Verification - Data Counts';
PROMPT '==========================================';

-- Count employees by age range
SELECT 
    'Employees aged 25-40' AS Category,
    COUNT(*) AS Count
FROM EMPLOYEE
WHERE age BETWEEN 25 AND 40
UNION ALL
SELECT 
    'Payroll records > 5000',
    COUNT(*)
FROM PAYROLL
WHERE total_amount > 5000
UNION ALL
SELECT 
    'Employees with sick leave',
    COUNT(DISTINCT emp_ID)
FROM LEAVE
WHERE LOWER(reason) LIKE '%sick%'
UNION ALL
SELECT 
    'Departments with no employees',
    COUNT(*)
FROM JOB_DEPARTMENT jd
WHERE NOT EXISTS (
    SELECT 1 FROM EMPLOYEE e WHERE e.job_ID = jd.job_ID
);

-- ============================================================
-- Sample Result Preview (for verification)
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Sample Result Previews';
PROMPT '==========================================';

-- Preview Query (a) results
PROMPT '';
PROMPT 'Preview - Query (a) first 5 results:';
SELECT 
    emp_ID,
    fname || ' ' || lname AS Full_Name,
    age
FROM EMPLOYEE
WHERE age BETWEEN 25 AND 40
ORDER BY lname ASC
FETCH FIRST 5 ROWS ONLY;

-- Preview Query (b) results
PROMPT '';
PROMPT 'Preview - Query (b) first 5 results:';
SELECT 
    p.payroll_ID,
    e.fname || ' ' || e.lname AS Employee_Name,
    jd.name AS Department,
    p.total_amount
FROM PAYROLL p
JOIN EMPLOYEE e ON p.emp_ID = e.emp_ID
JOIN JOB_DEPARTMENT jd ON p.job_ID = jd.job_ID
WHERE p.total_amount > 5000
ORDER BY p.total_amount DESC
FETCH FIRST 5 ROWS ONLY;

-- Preview Query (c) results
PROMPT '';
PROMPT 'Preview - Query (c) results:';
SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS Employee_Name,
    l.reason
FROM EMPLOYEE e
JOIN LEAVE l ON e.emp_ID = l.emp_ID
WHERE LOWER(l.reason) LIKE '%sick%'
ORDER BY e.lname;

-- Preview Query (d) results
PROMPT '';
PROMPT 'Preview - Query (d) results (departments with no employees):';
SELECT 
    job_ID,
    name AS Department_Name,
    job_dept
FROM JOB_DEPARTMENT jd
WHERE NOT EXISTS (
    SELECT 1 FROM EMPLOYEE e WHERE e.job_ID = jd.job_ID
)
ORDER BY name;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All queries executed successfully!';
PROMPT '==========================================';