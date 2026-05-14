-- Department table
CREATE TABLE departments (
    dept_id   NUMBER PRIMARY KEY,
    dept_name VARCHAR2(100) NOT NULL,
    location  VARCHAR2(100)
);

-- Employee table
CREATE TABLE employees (
    emp_id    NUMBER PRIMARY KEY,
    emp_name  VARCHAR2(100) NOT NULL,
    email     VARCHAR2(100) UNIQUE,
    dept_id   NUMBER
        REFERENCES departments ( dept_id ),
    job_title VARCHAR2(100),
    salary    NUMBER(10, 2),
    hire_date DATE DEFAULT sysdate,
    status    VARCHAR2(10) DEFAULT 'ACTIVE'
);

-- Payroll table
CREATE TABLE payroll (
    payroll_id     NUMBER PRIMARY KEY,
    emp_id         NUMBER
        REFERENCES employees ( emp_id ),
    pay_month      VARCHAR2(20),
    basic_salary   NUMBER(10, 2),
    bonus          NUMBER(10, 2),
    deductions     NUMBER(10, 2),
    net_salary     NUMBER(10, 2),
    processed_date DATE DEFAULT sysdate
);

-- Audit log table (will be filled automatically by a trigger later)
CREATE TABLE salary_audit (
    audit_id   NUMBER PRIMARY KEY,
    emp_id     NUMBER,
    old_salary NUMBER(10, 2),
    new_salary NUMBER(10, 2),
    changed_by VARCHAR2(50),
    changed_on DATE DEFAULT sysdate
);

-- Sequences (auto-incrementing IDs)
CREATE SEQUENCE dept_seq START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE emp_seq START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE pay_seq START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE audit_seq START WITH 1 INCREMENT BY 1;

-- Checking whether the sequences exists or not
SELECT
    object_name,
    object_type
FROM
    user_objects
WHERE
    object_name IN ( 'EMPLOYEES', 'DEPARTMENTS', 'EMP_SEQ', 'DEPT_SEQ' )
ORDER BY
    object_type;
