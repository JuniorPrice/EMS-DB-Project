-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Capstone Project
-- Section 08: Stored Procedures & Functions
-- Tasks 1 & 2: Procedure - Add New Employee and Function - Calculate Net Salary
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;
SET PAGESIZE 50;

PROMPT '==========================================';
PROMPT 'Section 08: Stored Procedures & Functions';
PROMPT 'Tasks 1 & 2: Procedure and Function';
PROMPT '==========================================';

-- ============================================================
-- TASK 1: Procedure - Add New Employee
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 1: Procedure - Add New Employee';
PROMPT '==========================================';

-- ============================================================
-- Create stored procedure SP_ADD_EMPLOYEE with IN parameters 
-- for all EMPLOYEE columns (except emp_ID which is auto-generated)
-- ============================================================

CREATE OR REPLACE PROCEDURE SP_ADD_EMPLOYEE (
    p_fname        IN EMPLOYEE.fname%TYPE,
    p_lname        IN EMPLOYEE.lname%TYPE,
    p_gender       IN EMPLOYEE.gender%TYPE,
    p_age          IN EMPLOYEE.age%TYPE,
    p_contact_add  IN EMPLOYEE.contact_add%TYPE,
    p_emp_email    IN EMPLOYEE.emp_email%TYPE,
    p_emp_pass     IN EMPLOYEE.emp_pass%TYPE,
    p_job_ID       IN EMPLOYEE.job_ID%TYPE,
    p_salary_ID    IN EMPLOYEE.salary_ID%TYPE
)
AS
    v_emp_id       EMPLOYEE.emp_ID%TYPE;
    v_email_count  NUMBER;
BEGIN
    -- Validate that emp_email is not already in use
    SELECT COUNT(*)
    INTO v_email_count
    FROM EMPLOYEE
    WHERE emp_email = p_emp_email;
    
    IF v_email_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Email ' || p_emp_email || ' already exists in the system.');
    END IF;
    
    -- Insert the new employee record using sequence
    SELECT seq_employee.NEXTVAL INTO v_emp_id FROM DUAL;
    
    INSERT INTO EMPLOYEE (
        emp_ID, fname, lname, gender, age, contact_add, 
        emp_email, emp_pass, job_ID, salary_ID
    ) VALUES (
        v_emp_id, p_fname, p_lname, p_gender, p_age, p_contact_add,
        p_emp_email, p_emp_pass, p_job_ID, p_salary_ID
    );
    
    -- Print confirmation message
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Employee added successfully!');
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_emp_id);
    DBMS_OUTPUT.PUT_LINE('Name: ' || p_fname || ' ' || p_lname);
    DBMS_OUTPUT.PUT_LINE('Email: ' || p_emp_email);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
END SP_ADD_EMPLOYEE;
/

PROMPT 'Procedure SP_ADD_EMPLOYEE created successfully.';

-- ============================================================
-- Test the procedure - First call (should succeed)
-- ============================================================

PROMPT '';
PROMPT 'Test 1: Adding new employee (should succeed)';
PROMPT '----------------------------------------------';

BEGIN
    SP_ADD_EMPLOYEE(
        p_fname => 'Test',
        p_lname => 'User',
        p_gender => 'M',
        p_age => 30,
        p_contact_add => '123 Test St, Test City',
        p_emp_email => 'test.user@company.com',
        p_emp_pass => 'testpass123',
        p_job_ID => 1,
        p_salary_ID => 1
    );
END;
/

-- ============================================================
-- Test the procedure - Second call with same email (will fail)
-- ============================================================

PROMPT '';
PROMPT 'Test 2: Adding employee with duplicate email (will fail)';
PROMPT '----------------------------------------------------------';

BEGIN
    SP_ADD_EMPLOYEE(
        p_fname => 'Duplicate',
        p_lname => 'Test',
        p_gender => 'F',
        p_age => 25,
        p_contact_add => '456 Test Ave, Test City',
        p_emp_email => 'test.user@company.com',  -- Same email as above
        p_emp_pass => 'duplicate123',
        p_job_ID => 2,
        p_salary_ID => 2
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- ============================================================
-- TASK 2: Function - Calculate Net Salary
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'TASK 2: Function - Calculate Net Salary';
PROMPT '==========================================';

-- ============================================================
-- Create function FN_NET_SALARY that accepts emp_ID as input
-- and returns the employee's net salary (amount + bonus)
-- ============================================================

CREATE OR REPLACE FUNCTION FN_NET_SALARY (
    p_emp_id IN EMPLOYEE.emp_ID%TYPE
)
RETURN NUMBER
AS
    v_net_salary  NUMBER;
BEGIN
    SELECT sb.amount + sb.bonus
    INTO v_net_salary
    FROM EMPLOYEE e
    JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
    WHERE e.emp_ID = p_emp_id;
    
    RETURN v_net_salary;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END FN_NET_SALARY;
/

PROMPT 'Function FN_NET_SALARY created successfully.';

-- ============================================================
-- Use the function in a SELECT query to display all employees 
-- with their calculated net salary, ordered highest to lowest
-- ============================================================

PROMPT '';
PROMPT 'Query: All employees with net salary (ordered highest to lowest)';
PROMPT '----------------------------------------------------------------';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS "Employee Name",
    jd.name AS "Department",
    sb.amount AS "Base Salary",
    sb.bonus AS "Bonus",
    FN_NET_SALARY(e.emp_ID) AS "Net Salary"
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
ORDER BY FN_NET_SALARY(e.emp_ID) DESC NULLS LAST;

-- ============================================================
-- Verification Queries
-- ============================================================

PROMPT '';
PROMPT '==========================================';
PROMPT 'Verification - Procedure and Function Created';
PROMPT '==========================================';

-- Verify procedure exists
SELECT 
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN ('SP_ADD_EMPLOYEE', 'FN_NET_SALARY')
AND object_type IN ('PROCEDURE', 'FUNCTION')
ORDER BY object_type;

-- Show procedure source code
PROMPT '';
PROMPT 'SP_ADD_EMPLOYEE source:';
SELECT text 
FROM user_source 
WHERE name = 'SP_ADD_EMPLOYEE' 
ORDER BY line;

-- Show function source code
PROMPT '';
PROMPT 'FN_NET_SALARY source:';
SELECT text 
FROM user_source 
WHERE name = 'FN_NET_SALARY' 
ORDER BY line;

-- Verify net salary calculation for all employees
PROMPT '';
PROMPT 'Net Salary Calculation Summary:';
SELECT 
    COUNT(*) AS "Total Employees",
    ROUND(MIN(FN_NET_SALARY(emp_ID)), 2) AS "Min Net Salary",
    ROUND(MAX(FN_NET_SALARY(emp_ID)), 2) AS "Max Net Salary",
    ROUND(AVG(FN_NET_SALARY(emp_ID)), 2) AS "Avg Net Salary"
FROM EMPLOYEE;

PROMPT '';
PROMPT '==========================================';
PROMPT 'All procedure and function tasks executed successfully!';
PROMPT '==========================================';