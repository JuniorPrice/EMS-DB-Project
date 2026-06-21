-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 06: Subqueries
-- Tasks 1 & 2: Single-Row and Multi-Row Subqueries
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 06: Subqueries';
PROMPT 'Tasks 1 & 2: Single-Row and Multi-Row Subqueries';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: Single-Row Subquery
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: Single-Row Subquery';
PROMPT '==========================================';

-- ============================================================
-- Query 1(a): Find all employees whose salary is greater than 
-- the average salary of the entire company
-- ============================================================

PROMPT '';
PROMPT 'Query 1(a): Employees with salary > company average';
PROMPT '----------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Employee Name",
    jd.name AS "Department",
    sb.amount AS "Salary Amount",
    TO_CHAR(sb.amount, 'FM$999,999.00') AS "Formatted Salary",
    ROUND((SELECT AVG(sb2.amount) FROM SALARY_BONUS sb2), 2) AS "Company Average"
FROM EMPLOYEE e
JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
WHERE sb.amount > (
    SELECT AVG(sb2.amount)
    FROM SALARY_BONUS sb2
)
ORDER BY sb.amount DESC;

-- ============================================================
-- Query 1(b): Retrieve the department with the highest total payroll amount
-- ============================================================

PROMPT '';
PROMPT 'Query 1(b): Department with the highest total payroll';
PROMPT '-----------------------------------------------------';

-- Show the top department with details
SELECT 
    jd.job_ID,
    jd.name AS "Department Name",
    jd.job_dept AS "Dept Code",
    SUM(p.total_amount) AS "Total Payroll",
    TO_CHAR(SUM(p.total_amount), 'FM$999,999.00') AS "Formatted Total",
    COUNT(p.payroll_ID) AS "Number of Payroll Records"
FROM JOB_DEPARTMENT jd
JOIN PAYROLL p ON jd.job_ID = p.job_ID
GROUP BY jd.job_ID, jd.name, jd.job_dept
HAVING SUM(p.total_amount) = (
    SELECT MAX(SUM(p2.total_amount))
    FROM PAYROLL p2
    GROUP BY p2.job_ID
);

-- ============================================================
-- TASK 2: Multi-Row Subquery with IN / ANY / ALL
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: Multi-Row Subquery with IN / ANY / ALL';
PROMPT '==========================================';

-- ============================================================
-- Query 2(a): List all employees who work in departments that 
-- have at least one salary record with a bonus greater than 500
-- ============================================================

PROMPT '';
PROMPT 'Query 2(a): Employees in departments with bonus > 500 (using IN)';
PROMPT '----------------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Employee Name",
    jd.name AS "Department",
    jd.job_dept AS "Dept Code",
    sb.amount AS "Salary",
    TO_CHAR(sb.amount, 'FM$999,999.00') AS "Formatted Salary",
    sb.bonus AS "Bonus Amount"
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
WHERE jd.job_ID IN (
    SELECT DISTINCT sb2.job_ID
    FROM SALARY_BONUS sb2
    WHERE sb2.bonus > 500
)
ORDER BY jd.name, e.lname;

-- ============================================================
-- Query 2(b): Find employees whose salary is greater than ALL 
-- salaries in the 'Maintenance' department
-- ============================================================

PROMPT '';
PROMPT 'Query 2(b): Employees with salary > ALL salaries in Finance (There is no Maintenance Department) ';
PROMPT '--------------------------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Employee Name",
    jd.name AS "Department",
    sb.amount AS "Salary Amount",
    TO_CHAR(sb.amount, 'FM$999,999.00') AS "Formatted Salary",
    (
        SELECT MAX(sb2.amount)
        FROM SALARY_BONUS sb2
        JOIN JOB_DEPARTMENT jd2 ON sb2.job_ID = jd2.job_ID
        WHERE LOWER(jd2.job_dept) = 'mkt' 
    ) AS "Marketing Dept Max Salary"
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
WHERE sb.amount > ALL (
    SELECT sb2.amount
    FROM SALARY_BONUS sb2
    JOIN JOB_DEPARTMENT jd2 ON sb2.job_ID = jd2.job_ID
    WHERE LOWER(jd2.job_dept) = 'mkt'  
)
ORDER BY sb.amount DESC;

-- ============================================================
-- Query 2(c): Find employees whose salary is greater than ANY 
-- salary in the 'HR' department
-- ============================================================

PROMPT '';
PROMPT 'Query 2(c): Employees with salary > ANY salary in HR (using ANY)';
PROMPT '----------------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Employee Name",
    jd.name AS "Department",
    sb.amount AS "Salary Amount",
    TO_CHAR(sb.amount, 'FM$999,999.00') AS "Formatted Salary",
    (
        SELECT MIN(sb2.amount)
        FROM SALARY_BONUS sb2
        JOIN EMPLOYEE e2 ON sb2.salary_ID = e2.salary_ID
        JOIN JOB_DEPARTMENT jd2 ON e2.job_ID = jd2.job_ID
        WHERE LOWER(jd2.name) = 'hr'
    ) AS "HR Dept Min Salary"
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
WHERE sb.amount > ANY (
    SELECT sb2.amount
    FROM SALARY_BONUS sb2
    JOIN EMPLOYEE e2 ON sb2.salary_ID = e2.salary_ID
    JOIN JOB_DEPARTMENT jd2 ON e2.job_ID = jd2.job_ID
    WHERE LOWER(jd2.name) = 'hr'
)
ORDER BY sb.amount DESC;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All subquery tasks executed successfully!';
PROMPT '==========================================';