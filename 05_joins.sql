-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 05: Joins
-- Tasks 1 & 2: INNER JOIN and LEFT OUTER JOIN
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 50;
SET COLSEP ' | ';

PROMPT '==========================================';
PROMPT 'Section 05: Joins';
PROMPT 'Tasks 1 & 2: INNER JOIN and LEFT OUTER JOIN';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: INNER JOIN - Employee Full Profile
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: INNER JOIN - Employee Full Profile';
PROMPT '==========================================';

-- ============================================================
-- Query 1: Complete employee profile using INNER JOINs
-- Columns: emp_ID, full name, department name, job title,
--          salary amount, latest leave date
-- Filter: only employees who have both a payroll record 
--         AND a qualification record
-- ============================================================

PROMPT '';
PROMPT 'Query 1: Employee Full Profile (with Payroll AND Qualification)';
PROMPT '----------------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Full Name",
    jd.name AS "Department",
    q.position AS "Job Title",
    sb.amount AS "Salary Amount",
    TO_CHAR(sb.amount, 'FM$999,999.00') AS "Formatted Salary",
    p.payroll_date AS "Payroll Date",        
    l.leave_date                    
FROM EMPLOYEE e
INNER JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
INNER JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
INNER JOIN QUALIFICATION q ON e.emp_ID = q.emp_ID
INNER JOIN PAYROLL p ON e.emp_ID = p.emp_ID
LEFT JOIN LEAVE l ON e.emp_ID = l.emp_ID  
ORDER BY e.lname, l.leave_date;  

-- ============================================================
-- Alternative Query 1: Using INNER JOIN instead of EXISTS
-- (Shows same results but with different approach)
-- ============================================================

PROMPT '';
PROMPT 'Query 1 Alternative: Using INNER JOIN with DISTINCT';
PROMPT '----------------------------------------------------';

SELECT
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Full Name",
    jd.name AS "Department",
    q.position AS "Job Title",
    sb.amount AS "Salary Amount",
    TO_CHAR(sb.amount, 'FM$999,999.00') AS "Formatted Salary",
    (
        SELECT MAX(l.leave_date)
        FROM LEAVE l
        WHERE l.emp_ID = e.emp_ID
    ) AS "Latest Leave Date"
FROM EMPLOYEE e
INNER JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
INNER JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
INNER JOIN QUALIFICATION q ON e.emp_ID = q.emp_ID
INNER JOIN PAYROLL p ON e.emp_ID = p.emp_ID
ORDER BY e.lname, e.emp_ID;

-- ============================================================
-- TASK 2: LEFT OUTER JOIN - Missing Records
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: LEFT OUTER JOIN - Missing Records';
PROMPT '==========================================';

-- ============================================================
-- Query 2(a): List all employees who have never taken any leave
-- (no matching LEAVE record)
-- ============================================================

PROMPT '';
PROMPT 'Query 2(a): Employees who have never taken leave';
PROMPT '-------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Full Name",
    e.gender,
    e.age,
    jd.name AS "Department",
    jd.job_dept AS "Dept Code",
    COUNT(l.leave_ID) AS "Leave Count"
FROM EMPLOYEE e
LEFT JOIN LEAVE l ON e.emp_ID = l.emp_ID
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
GROUP BY e.emp_ID, e.fname, e.lname, e.gender, e.age, jd.name, jd.job_dept
HAVING COUNT(l.leave_ID) = 0
ORDER BY e.lname, e.emp_ID;

-- ============================================================
-- Alternative Query 2(a): Using NOT EXISTS (more efficient)
-- ============================================================

PROMPT '';
PROMPT 'Query 2(a) Alternative: Employees with no leave (using NOT EXISTS)';
PROMPT '------------------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Full Name",
    e.gender,
    e.age,
    jd.name AS "Department",
    jd.job_dept AS "Dept Code"
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
WHERE NOT EXISTS (
    SELECT 1
    FROM LEAVE l
    WHERE l.emp_ID = e.emp_ID
)
ORDER BY e.lname, e.emp_ID;

-- ============================================================
-- Query 2(b): List all departments that have no salary/bonus 
-- records associated with them
-- ============================================================

PROMPT '';
PROMPT 'Query 2(b): Departments with no salary/bonus records';
PROMPT '-----------------------------------------------------';

SELECT 
    jd.job_ID,
    jd.job_dept AS "Dept Code",
    jd.name AS "Department Name",
    jd.description,
    COUNT(sb.salary_ID) AS "Salary Records Count"
FROM JOB_DEPARTMENT jd
LEFT JOIN SALARY_BONUS sb ON jd.job_ID = sb.job_ID
GROUP BY jd.job_ID, jd.job_dept, jd.name, jd.description
HAVING COUNT(sb.salary_ID) = 0
ORDER BY jd.name;

-- ============================================================
-- Alternative Query 2(b): Using NOT EXISTS
-- ============================================================

PROMPT '';
PROMPT 'Query 2(b) Alternative: Departments with no salary records (NOT EXISTS)';
PROMPT '----------------------------------------------------------------------';

SELECT 
    jd.job_ID,
    jd.job_dept AS "Dept Code",
    jd.name AS "Department Name",
    jd.description
FROM JOB_DEPARTMENT jd
WHERE NOT EXISTS (
    SELECT 1
    FROM SALARY_BONUS sb
    WHERE sb.job_ID = jd.job_ID
)
ORDER BY jd.name;

-- ============================================================
-- ADDITIONAL VERIFICATION QUERIES
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Verification - Data Summary';
PROMPT '==========================================';

-- Count employees with both payroll and qualification
PROMPT '';
PROMPT 'Employees with both Payroll AND Qualification:';
SELECT COUNT(DISTINCT e.emp_ID) AS "Count"
FROM EMPLOYEE e
WHERE EXISTS (SELECT 1 FROM PAYROLL p WHERE p.emp_ID = e.emp_ID)
AND EXISTS (SELECT 1 FROM QUALIFICATION q WHERE q.emp_ID = e.emp_ID);

-- Count employees with no leave
PROMPT '';
PROMPT 'Employees with NO leave records:';
SELECT COUNT(*) AS "Count"
FROM EMPLOYEE e
WHERE NOT EXISTS (SELECT 1 FROM LEAVE l WHERE l.emp_ID = e.emp_ID);

-- Count departments with no salary records
PROMPT '';
PROMPT 'Departments with NO salary records:';
SELECT COUNT(*) AS "Count"
FROM JOB_DEPARTMENT jd
WHERE NOT EXISTS (SELECT 1 FROM SALARY_BONUS sb WHERE sb.job_ID = jd.job_ID);

-- ============================================================
-- Detailed Employee Leave Status (Bonus Insight)
-- ============================================================

PROMPT '';
PROMPT 'Employee Leave Status Summary:';
PROMPT '------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Full Name",
    jd.name AS "Department",
    COUNT(l.leave_ID) AS "Total Leave Days",
    CASE 
        WHEN COUNT(l.leave_ID) = 0 THEN 'No Leave Taken'
        WHEN COUNT(l.leave_ID) <= 2 THEN 'Minimal Leave'
        WHEN COUNT(l.leave_ID) <= 5 THEN 'Moderate Leave'
        ELSE 'Frequent Leave'
    END AS "Leave Category"
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
LEFT JOIN LEAVE l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.fname, e.lname, jd.name
ORDER BY COUNT(l.leave_ID) DESC, e.lname;

-- ============================================================
-- Department Salary Record Status
-- ============================================================

PROMPT '';
PROMPT 'Department Salary Record Status:';
PROMPT '---------------------------------';

SELECT 
    jd.job_ID,
    jd.name AS "Department",
    jd.job_dept AS "Code",
    COUNT(sb.salary_ID) AS "Salary Records",
    CASE 
        WHEN COUNT(sb.salary_ID) = 0 THEN 'No Salary Records ❌'
        WHEN COUNT(sb.salary_ID) = 1 THEN 'Minimal Records'
        ELSE 'Has Records ✅'
    END AS "Status"
FROM JOB_DEPARTMENT jd
LEFT JOIN SALARY_BONUS sb ON jd.job_ID = sb.job_ID
GROUP BY jd.job_ID, jd.name, jd.job_dept
ORDER BY COUNT(sb.salary_ID) DESC;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All join queries executed successfully!';
PROMPT '==========================================';