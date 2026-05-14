-- Inserting departments sample data
INSERT INTO departments VALUES (
    dept_seq.NEXTVAL,
    'Engineering',
    'New York'
);

INSERT INTO departments VALUES (
    dept_seq.NEXTVAL,
    'Finance',
    'Chicago'
);

INSERT INTO departments VALUES (
    dept_seq.NEXTVAL,
    'HR',
    'Austin'
);

COMMIT;

-- Check the data exists or not
SELECT
    *
FROM
    departments;

-- Declaration
DECLARE
    TYPE name_list IS
        TABLE OF VARCHAR2(50);
    TYPE job_list IS
        TABLE OF VARCHAR2(50);
    TYPE id_list IS
        TABLE OF NUMBER;
    v_firstnames name_list := name_list('James', 'Sarah', 'Mohammed', 'Priya', 'Carlos',
                                       'Emily', 'Omar', 'Fatima', 'Daniel', 'Aisha',
                                       'Bilal', 'Zara', 'Nathan', 'Sofia', 'Tariq');
    v_lastnames  name_list := name_list('Khan', 'Williams', 'Ahmed', 'Patel', 'Garcia',
                                      'Johnson', 'Ali', 'Brown', 'Raza', 'Smith',
                                      'Malik', 'Chen', 'Davis', 'Hussain', 'Lopez');
    v_jobs       job_list := job_list('Software Engineer', 'Sr. Developer', 'Analyst', 'HR Manager', 'Finance Lead',
                               'QA Engineer', 'DevOps Engineer', 'Sr. Analyst', 'Team Lead', 'Intern');
    v_dept_ids   id_list;
    v_fname      VARCHAR2(50);
    v_lname      VARCHAR2(50);
    v_job        VARCHAR2(50);
    v_salary     NUMBER;
    v_dept       NUMBER;
    v_fi         NUMBER;
    v_li         NUMBER;
    v_ji         NUMBER;
BEGIN
   -- NEW: Load actual dept_ids from the table at runtime
    SELECT
        dept_id
    BULK COLLECT
    INTO v_dept_ids
    FROM
        departments;

    FOR i IN 1..20 LOOP
        v_fi := trunc(dbms_random.value(1, v_firstnames.count + 1));

        v_li := trunc(dbms_random.value(1, v_lastnames.count + 1));

        v_ji := trunc(dbms_random.value(1, v_jobs.count + 1));

        v_fname := v_firstnames(v_fi);
        v_lname := v_lastnames(v_li);
        v_job := v_jobs(v_ji);
        v_salary := round(dbms_random.value(40000, 500000), -3);

      -- Pick a random index from the real dept_ids list
        v_dept := v_dept_ids(trunc(dbms_random.value(1, v_dept_ids.count + 1)));

        INSERT INTO employees (
            emp_id,
            emp_name,
            email,
            dept_id,
            job_title,
            salary,
            hire_date,
            status
        ) VALUES (
            emp_seq.NEXTVAL,
            v_fname
            || ' '
            || v_lname,
            lower(v_fname)
            || '.'
            || lower(v_lname)
            || i
            || '@company.com',
            v_dept,
            v_job,
            v_salary,
            sysdate - trunc(dbms_random.value(30, 1500)),
            'ACTIVE'
        );

    END LOOP;

    COMMIT;
    dbms_output.put_line('20 employees generated and inserted successfully.');
END;
/

-- See all employees with their departments
SELECT
    e.emp_id,
    e.emp_name,
    e.job_title,
    e.salary,
    d.dept_name,
    e.hire_date
FROM
         employees e
    JOIN departments d ON e.dept_id = d.dept_id
ORDER BY
    e.dept_id,
    e.salary DESC;

-- Quick summary by departments
SELECT
    d.dept_name,
    COUNT(e.emp_id)         AS headcount,
    round(AVG(e.salary), 2) AS avg_salary,
    MIN(e.salary)           AS min_salary,
    MAX(e.salary)           AS max_salary
FROM
         employees e
    JOIN departments d ON e.dept_id = d.dept_id
GROUP BY
    d.dept_name;
