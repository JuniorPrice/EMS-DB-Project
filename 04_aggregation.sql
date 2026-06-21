-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 04: Aggregation Functions
-- Tasks 1 & 2: Basic Aggregation and GROUP BY with HAVING
-- Author: Ya'Rab Amamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 04: Aggregation Functions';
PROMPT 'Tasks 1 & 2: Basic Aggregation and GROUP BY with HAVING';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: Basic Aggregation
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: Basic Aggregation';
PROMPT '==========================================';

-- ============================================================
-- Query 1(a): Total number of employees in each department
-- ============================================================

PROMPT '';
PROMPT 'Query 1(a): Total number of employees in each department';
PROMPT '----------------------------------------------------------';

SELECT 
    jd.job_ID,
    jd.name AS Department_Name,
    jd.job_dept AS Department_Code,
    COUNT(e.emp_ID) AS Total_Employees
FROM JOB_DEPARTMENT jd
LEFT JOIN EMPLOYEE e ON jd.job_ID = e.job_ID
GROUP BY jd.job_ID, jd.name, jd.job_dept
ORDER BY Total_Employees DESC, jd.name;

-- ============================================================
-- Query 1(b): Minimum, maximum, and average salary across all records
-- ============================================================

PROMPT '';
PROMPT 'Query 1(b): Salary statistics (Min, Max, Average)';
PROMPT '--------------------------------------------------';

SELECT 
    ROUND(MIN(sb.amount), 2) AS Minimum_Salary,
    ROUND(MAX(sb.amount), 2) AS Maximum_Salary,
    ROUND(AVG(sb.amount), 2) AS Average_Salary,
    COUNT(sb.salary_ID) AS Total_Salary_Records
FROM SALARY_BONUS sb;

-- ============================================================
-- Query 1(c): Total bonus paid out across the entire company
-- ============================================================

PROMPT '';
PROMPT 'Query 1(c): Total bonus paid out across the entire company';
PROMPT '-----------------------------------------------------------';

SELECT 
    SUM(sb.bonus) AS Total_Bonus_Paid,
    ROUND(AVG(sb.bonus), 2) AS Average_Bonus,
    MIN(sb.bonus) AS Minimum_Bonus,
    MAX(sb.bonus) AS Maximum_Bonus
FROM SALARY_BONUS sb;

-- ============================================================
-- TASK 2: GROUP BY with HAVING
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: GROUP BY with HAVING';
PROMPT '==========================================';

-- ============================================================
-- Query 2(a): List departments where the average employee age exceeds 30
-- ============================================================

PROMPT '';
PROMPT 'Query 2(a): Departments with average employee age > 30';
PROMPT '-------------------------------------------------------';

SELECT 
    jd.job_ID,
    jd.name AS Department_Name,
    jd.job_dept AS Department_Code,
    COUNT(e.emp_ID) AS Number_of_Employees,
    ROUND(AVG(e.age), 2) AS Average_Age,
    MIN(e.age) AS Youngest_Employee,
    MAX(e.age) AS Oldest_Employee
FROM JOB_DEPARTMENT jd
JOIN EMPLOYEE e ON jd.job_ID = e.job_ID
GROUP BY jd.job_ID, jd.name, jd.job_dept
HAVING AVG(e.age) > 30
ORDER BY Average_Age DESC;

-- ============================================================
-- Query 2(b): Show all job titles where more than 2 employees 
-- share that qualification position
-- ============================================================

PROMPT '';
PROMPT 'Query 2(b): Qualification positions with more than 2 employees';
PROMPT '---------------------------------------------------------------';

SELECT 
    q.position AS Qualification_Position,
    COUNT(DISTINCT q.emp_ID) AS Number_of_Employees,
    MIN(e.age) AS Youngest_Employee_Age,
    MAX(e.age) AS Oldest_Employee_Age,
    ROUND(AVG(e.age), 2) AS Average_Age
FROM QUALIFICATION q
JOIN EMPLOYEE e ON q.emp_ID = e.emp_ID
GROUP BY q.position
HAVING COUNT(DISTINCT q.emp_ID) > 2
ORDER BY Number_of_Employees DESC, q.position;

-- ============================================================
-- Query 2(c): Find months where the total payroll amount exceeds 20,000
-- ============================================================

PROMPT '';
PROMPT 'Query 2(c): Months with total payroll exceeding 20,000';
PROMPT '-------------------------------------------------------';

SELECT 
    TO_CHAR(p.payroll_date, 'YYYY-MM') AS Payroll_Month,
    TO_CHAR(p.payroll_date, 'Month YYYY') AS Month_Name,
    COUNT(p.payroll_ID) AS Number_of_Payroll_Records,
    SUM(p.total_amount) AS Total_Payroll_Amount,
    ROUND(AVG(p.total_amount), 2) AS Average_Payroll_Per_Record
FROM PAYROLL p
GROUP BY TO_CHAR(p.payroll_date, 'YYYY-MM'), TO_CHAR(p.payroll_date, 'Month YYYY')
HAVING SUM(p.total_amount) > 20000
ORDER BY Payroll_Month;

-- ============================================================
-- ADDITIONAL INSIGHT QUERIES (for verification and business analysis)
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Additional Verification Queries';
PROMPT '==========================================';

-- ============================================================
-- Department Salary Summary (Bonus insight)
-- ============================================================

PROMPT '';
PROMPT 'Department Salary Summary:';
PROMPT '--------------------------';

SELECT 
    jd.name AS Department_Name,
    COUNT(sb.salary_ID) AS Salary_Records,
    ROUND(MIN(sb.amount), 2) AS Min_Salary,
    ROUND(MAX(sb.amount), 2) AS Max_Salary,
    ROUND(AVG(sb.amount), 2) AS Avg_Salary,
    ROUND(SUM(sb.bonus), 2) AS Total_Bonus
FROM JOB_DEPARTMENT jd
JOIN SALARY_BONUS sb ON jd.job_ID = sb.job_ID
GROUP BY jd.job_ID, jd.name
ORDER BY Avg_Salary DESC;

-- ============================================================
-- Employee Age Distribution Summary 
-- ============================================================

PROMPT '';
PROMPT 'Employee Age Distribution:';
PROMPT '--------------------------';

SELECT 
    CASE 
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 30 THEN '25-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE 'Over 50'
    END AS Age_Group,
    COUNT(emp_ID) AS Number_of_Employees,
    ROUND(AVG(age), 2) AS Average_Age,
    MIN(age) AS Min_Age,
    MAX(age) AS Max_Age
FROM EMPLOYEE
GROUP BY 
    CASE 
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 30 THEN '25-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE 'Over 50'
    END
ORDER BY MIN(age);

-- ============================================================
-- Department Payroll Summary (Bonus insight)
-- ============================================================

PROMPT '';
PROMPT 'Department Payroll Summary:';
PROMPT '---------------------------';

SELECT 
    jd.name AS Department_Name,
    COUNT(DISTINCT p.emp_ID) AS Unique_Employees,
    COUNT(p.payroll_ID) AS Payroll_Records,
    ROUND(SUM(p.total_amount), 2) AS Total_Payroll,
    ROUND(AVG(p.total_amount), 2) AS Average_Payroll_Per_Record
FROM JOB_DEPARTMENT jd
JOIN PAYROLL p ON jd.job_ID = p.job_ID
GROUP BY jd.job_ID, jd.name
ORDER BY Total_Payroll DESC;

-- ============================================================
-- Verification Counts
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Verification - Query Counts';
PROMPT '==========================================';

SELECT 
    'Departments' AS Category,
    COUNT(*) AS Total
FROM JOB_DEPARTMENT
UNION ALL
SELECT 
    'Employees',
    COUNT(*)
FROM EMPLOYEE
UNION ALL
SELECT 
    'Salary Records',
    COUNT(*)
FROM SALARY_BONUS
UNION ALL
SELECT 
    'Payroll Records',
    COUNT(*)
FROM PAYROLL
UNION ALL
SELECT 
    'Qualification Records',
    COUNT(*)
FROM QUALIFICATION
UNION ALL
SELECT 
    'Leave Records',
    COUNT(*)
FROM LEAVE;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All aggregation queries executed successfully!';
PROMPT '==========================================';