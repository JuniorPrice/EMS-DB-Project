-- ============================================================
-- EMPLOYEE MANAGEMENT SYSTEM - Complete Setup Script
-- Section: 01 -> Task 03 
-- Section: 03 -> Task 01
-- Author: Ya'Rab Almamari
-- Date: 20/6/2026
-- Database: Oracle 19c+
-- ============================================================

SET SERVEROUTPUT ON;
SET LINESIZE 150;

-- ============================================================
-- PART 1: CREATE TABLES (Section 01 Task 3)
-- ============================================================

PROMPT '==========================================';
PROMPT 'Creating Tables...';
PROMPT '==========================================';

-- Drop tables if they exist (for clean re-run in correct order)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PAYROLL CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE LEAVE CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE QUALIFICATION CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE EMPLOYEE CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE SALARY_BONUS CASCADE CONSTRAINTS PURGE';
    EXECUTE IMMEDIATE 'DROP TABLE JOB_DEPARTMENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- 1. Create JOB_DEPARTMENT table
CREATE TABLE JOB_DEPARTMENT (
    job_ID      NUMBER          PRIMARY KEY,
    job_dept    VARCHAR2(10)    NOT NULL,
    name        VARCHAR2(50)    NOT NULL,
    description VARCHAR2(200),
    max_salary  NUMBER(10,2)    CHECK (max_salary > 0),
    min_salary  NUMBER(10,2)    CHECK (min_salary > 0),
    -- Table-level constraint that can reference multiple columns
    CONSTRAINT chk_salary_range CHECK (min_salary <= max_salary)
);

-- 2. Create SALARY_BONUS table
CREATE TABLE SALARY_BONUS (
    salary_ID   NUMBER          PRIMARY KEY,
    amount      NUMBER(10,2)    NOT NULL CHECK (amount > 0),
    annual      NUMBER(12,2)    NOT NULL,
    bonus       NUMBER(10,2)    DEFAULT 0,
    job_ID      NUMBER          NOT NULL,
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) 
        REFERENCES JOB_DEPARTMENT(job_ID)
);

-- 3. Create EMPLOYEE table
CREATE TABLE EMPLOYEE (
    emp_ID      NUMBER          PRIMARY KEY,
    fname       VARCHAR2(50)    NOT NULL,
    lname       VARCHAR2(50)    NOT NULL,
    gender      CHAR(1)         NOT NULL CHECK (gender IN ('M', 'F')),
    age         NUMBER(3)       CHECK (age >= 18 AND age <= 100),
    contact_add VARCHAR2(200)   NOT NULL,
    emp_email   VARCHAR2(100)   NOT NULL UNIQUE,
    emp_pass    VARCHAR2(50)    NOT NULL,
    job_ID      NUMBER          NOT NULL,
    salary_ID   NUMBER          NOT NULL,
    CONSTRAINT fk_emp_job FOREIGN KEY (job_ID) 
        REFERENCES JOB_DEPARTMENT(job_ID),
    CONSTRAINT fk_emp_salary FOREIGN KEY (salary_ID) 
        REFERENCES SALARY_BONUS(salary_ID)
);

-- 4. Create QUALIFICATION table
CREATE TABLE QUALIFICATION (
    qual_ID     NUMBER          PRIMARY KEY,
    position    VARCHAR2(50)    NOT NULL,
    requirements VARCHAR2(200),
    date_in     DATE            NOT NULL,
    emp_ID      NUMBER          NOT NULL,
    CONSTRAINT fk_qual_emp FOREIGN KEY (emp_ID) 
        REFERENCES EMPLOYEE(emp_ID)
);

-- 5. Create LEAVE table
CREATE TABLE LEAVE (
    leave_ID    NUMBER          PRIMARY KEY,
    leave_date        DATE            NOT NULL,
    reason      VARCHAR2(200)   NOT NULL,
    emp_ID      NUMBER          NOT NULL,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) 
        REFERENCES EMPLOYEE(emp_ID)
);

-- 6. Create PAYROLL table
CREATE TABLE PAYROLL (
    payroll_ID  NUMBER          PRIMARY KEY,
    payroll_date        DATE            NOT NULL,
    report      VARCHAR2(100)   NOT NULL,
    total_amount NUMBER(10,2)   NOT NULL CHECK (total_amount > 0),
    job_ID      NUMBER          NOT NULL,
    emp_ID      NUMBER          NOT NULL,
    salary_ID   NUMBER          NOT NULL,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) 
        REFERENCES JOB_DEPARTMENT(job_ID),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) 
        REFERENCES EMPLOYEE(emp_ID),
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) 
        REFERENCES SALARY_BONUS(salary_ID)
);

PROMPT 'All tables created successfully!';

-- ============================================================
-- PART 2: CREATE SEQUENCES
-- ============================================================

PROMPT '==========================================';
PROMPT 'Creating Sequences...';
PROMPT '==========================================';

-- Drop sequences if they exist
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_job_dept';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_salary_bonus';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_qualification';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_employee';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_payroll';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leave';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create sequences for each table
CREATE SEQUENCE seq_job_dept START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_salary_bonus START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_qualification START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_employee START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_payroll START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_leave START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

PROMPT 'All sequences created successfully!';

-- ============================================================
-- PART 3: INSERT SEED DATA (Section 03 Task 1)
-- ============================================================

PROMPT '==========================================';
PROMPT 'Inserting Seed Data...';
PROMPT '==========================================';

BEGIN
    -- Insert JOB_DEPARTMENT records (5 departments)
    INSERT INTO JOB_DEPARTMENT (job_ID, job_dept, name, description, max_salary, min_salary)
    VALUES (seq_job_dept.NEXTVAL, 'ENG', 'Engineering', 'Software development and engineering team', 120000, 60000);
    
    INSERT INTO JOB_DEPARTMENT (job_ID, job_dept, name, description, max_salary, min_salary)
    VALUES (seq_job_dept.NEXTVAL, 'FIN', 'Finance', 'Financial management and accounting', 110000, 55000);
    
    INSERT INTO JOB_DEPARTMENT (job_ID, job_dept, name, description, max_salary, min_salary)
    VALUES (seq_job_dept.NEXTVAL, 'HR', 'Human Resources', 'Talent acquisition and employee relations', 95000, 45000);
    
    INSERT INTO JOB_DEPARTMENT (job_ID, job_dept, name, description, max_salary, min_salary)
    VALUES (seq_job_dept.NEXTVAL, 'MKT', 'Marketing', 'Marketing strategy and brand management', 105000, 50000);
    
    INSERT INTO JOB_DEPARTMENT (job_ID, job_dept, name, description, max_salary, min_salary)
    VALUES (seq_job_dept.NEXTVAL, 'IT', 'Information Technology', 'IT infrastructure and support', 115000, 58000);

    -- Insert SALARY_BONUS records (5 records)
    INSERT INTO SALARY_BONUS (salary_ID, amount, annual, bonus, job_ID)
    VALUES (seq_salary_bonus.NEXTVAL, 65000, 780000, 5000, 1);
    
    INSERT INTO SALARY_BONUS (salary_ID, amount, annual, bonus, job_ID)
    VALUES (seq_salary_bonus.NEXTVAL, 72000, 864000, 7000, 2);
    
    INSERT INTO SALARY_BONUS (salary_ID, amount, annual, bonus, job_ID)
    VALUES (seq_salary_bonus.NEXTVAL, 58000, 696000, 4000, 3);
    
    INSERT INTO SALARY_BONUS (salary_ID, amount, annual, bonus, job_ID)
    VALUES (seq_salary_bonus.NEXTVAL, 68000, 816000, 6000, 4);
    
    INSERT INTO SALARY_BONUS (salary_ID, amount, annual, bonus, job_ID)
    VALUES (seq_salary_bonus.NEXTVAL, 75000, 900000, 8000, 5);

    -- Insert EMPLOYEE records (10 employees)
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'John', 'Smith', 'M', 35, '123 Main St, New York, NY 10001', 'john.smith@company.com', 'pass123', 1, 1);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Mary', 'Johnson', 'F', 42, '456 Oak Ave, Chicago, IL 60601', 'mary.johnson@company.com', 'pass456', 2, 2);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Robert', 'Williams', 'M', 28, '789 Pine St, San Francisco, CA 94101', 'robert.williams@company.com', 'pass789', 3, 3);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Patricia', 'Brown', 'F', 39, '321 Elm Blvd, Dallas, TX 75201', 'patricia.brown@company.com', 'pass321', 4, 4);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'James', 'Davis', 'M', 31, '654 Maple Dr, Boston, MA 02101', 'james.davis@company.com', 'pass654', 5, 5);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Jennifer', 'Miller', 'F', 45, '987 Cedar Ln, Seattle, WA 98101', 'jennifer.miller@company.com', 'pass987', 1, 1);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Michael', 'Wilson', 'M', 26, '147 Birch Way, Miami, FL 33101', 'michael.wilson@company.com', 'pass147', 2, 2);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Elizabeth', 'Moore', 'F', 33, '258 Spruce Ct, Denver, CO 80201', 'elizabeth.moore@company.com', 'pass258', 3, 3);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'William', 'Taylor', 'M', 50, '369 Willow St, Phoenix, AZ 85001', 'william.taylor@company.com', 'pass369', 4, 4);
    
    INSERT INTO EMPLOYEE (emp_ID, fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID)
    VALUES (seq_employee.NEXTVAL, 'Sarah', 'Anderson', 'F', 29, '741 Oak Park, Atlanta, GA 30301', 'sarah.anderson@company.com', 'pass741', 5, 5);

    -- Insert QUALIFICATION records (5 records)
    INSERT INTO QUALIFICATION (qual_ID, position, requirements, date_in, emp_ID)
    VALUES (seq_qualification.NEXTVAL, 'Senior Developer', 'BSc Computer Science, 5+ years experience', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 1);
    
    INSERT INTO QUALIFICATION (qual_ID, position, requirements, date_in, emp_ID)
    VALUES (seq_qualification.NEXTVAL, 'Financial Analyst', 'CPA Certification, 3+ years finance experience', TO_DATE('2019-06-20', 'YYYY-MM-DD'), 2);
    
    INSERT INTO QUALIFICATION (qual_ID, position, requirements, date_in, emp_ID)
    VALUES (seq_qualification.NEXTVAL, 'HR Specialist', 'PHR Certification, 4+ years HR experience', TO_DATE('2021-03-10', 'YYYY-MM-DD'), 3);
    
    INSERT INTO QUALIFICATION (qual_ID, position, requirements, date_in, emp_ID)
    VALUES (seq_qualification.NEXTVAL, 'Marketing Manager', 'MBA Marketing, 7+ years experience', TO_DATE('2018-11-01', 'YYYY-MM-DD'), 4);
    
    INSERT INTO QUALIFICATION (qual_ID, position, requirements, date_in, emp_ID)
    VALUES (seq_qualification.NEXTVAL, 'IT Administrator', 'CCNA Certification, 5+ years IT experience', TO_DATE('2020-08-25', 'YYYY-MM-DD'), 5);

    -- Insert LEAVE records (5 records)
    INSERT INTO LEAVE (leave_ID, leave_date, reason, emp_ID)
    VALUES (seq_leave.NEXTVAL, TO_DATE('2025-12-15', 'YYYY-MM-DD'), 'Annual vacation', 1);
    
    INSERT INTO LEAVE (leave_ID, leave_date, reason, emp_ID)
    VALUES (seq_leave.NEXTVAL, TO_DATE('2026-01-05', 'YYYY-MM-DD'), 'Sick leave', 2);
    
    INSERT INTO LEAVE (leave_ID, leave_date, reason, emp_ID)
    VALUES (seq_leave.NEXTVAL, TO_DATE('2025-11-20', 'YYYY-MM-DD'), 'Personal day', 3);
    
    INSERT INTO LEAVE (leave_ID, leave_date, reason, emp_ID)
    VALUES (seq_leave.NEXTVAL, TO_DATE('2026-02-10', 'YYYY-MM-DD'), 'Medical appointment', 4);
    
    INSERT INTO LEAVE (leave_ID, leave_date, reason, emp_ID)
    VALUES (seq_leave.NEXTVAL, TO_DATE('2025-10-30', 'YYYY-MM-DD'), 'Family emergency', 5);

    -- Insert PAYROLL records (8 records)
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-01-31', 'YYYY-MM-DD'), 'January 2026 Payroll', 5800, 1, 1, 1);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-01-31', 'YYYY-MM-DD'), 'January 2026 Payroll', 6500, 2, 2, 2);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-01-31', 'YYYY-MM-DD'), 'January 2026 Payroll', 5200, 3, 3, 3);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-02-28', 'YYYY-MM-DD'), 'February 2026 Payroll', 6100, 4, 4, 4);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-02-28', 'YYYY-MM-DD'), 'February 2026 Payroll', 5400, 5, 5, 5);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-03-31', 'YYYY-MM-DD'), 'March 2026 Payroll', 6200, 1, 6, 1);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-03-31', 'YYYY-MM-DD'), 'March 2026 Payroll', 5900, 2, 7, 2);
    
    INSERT INTO PAYROLL (payroll_ID, payroll_date, report, total_amount, job_ID, emp_ID, salary_ID)
    VALUES (seq_payroll.NEXTVAL, TO_DATE('2026-03-31', 'YYYY-MM-DD'), 'March 2026 Payroll', 5600, 3, 8, 3);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('All data inserted successfully!');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        RAISE;
END;
/

-- ============================================================
-- PART 4: VERIFICATION
-- ============================================================

PROMPT '==========================================';
PROMPT 'Data Insertion Summary';
PROMPT '==========================================';

SELECT 'JOB_DEPARTMENT' AS Table_Name, COUNT(*) AS Record_Count FROM JOB_DEPARTMENT
UNION ALL
SELECT 'SALARY_BONUS', COUNT(*) FROM SALARY_BONUS
UNION ALL
SELECT 'EMPLOYEE', COUNT(*) FROM EMPLOYEE
UNION ALL
SELECT 'QUALIFICATION', COUNT(*) FROM QUALIFICATION
UNION ALL
SELECT 'LEAVE', COUNT(*) FROM LEAVE
UNION ALL
SELECT 'PAYROLL', COUNT(*) FROM PAYROLL;

PROMPT '==========================================';
PROMPT 'Sample Employee Data:';
PROMPT '==========================================';

SELECT 
    e.emp_ID,
    e.fname || ' ' || e.lname AS Full_Name,
    jd.name AS Department,
    sb.amount AS Salary_Amount,
    sb.bonus AS Bonus_Amount,
    sb.amount + sb.bonus AS Total_Compensation
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT jd ON e.job_ID = jd.job_ID
JOIN SALARY_BONUS sb ON e.salary_ID = sb.salary_ID
ORDER BY e.emp_ID;

PROMPT '==========================================';
PROMPT 'Setup Complete!';
PROMPT '==========================================';