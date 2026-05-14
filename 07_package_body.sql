-- Creating package body
CREATE OR REPLACE PACKAGE BODY payroll_pkg AS

    -- Private helper function
    FUNCTION dept_exists (
        p_dept_id IN NUMBER
    ) RETURN BOOLEAN AS
        v_count NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO v_count
        FROM
            departments
        WHERE
            dept_id = p_dept_id;

        RETURN v_count > 0;
    END dept_exists;

    PROCEDURE add_employee (
        p_name    IN VARCHAR2,
        p_email   IN VARCHAR2,
        p_dept_id IN NUMBER,
        p_job     IN VARCHAR2,
        p_salary  IN NUMBER
    ) AS
    BEGIN
        IF NOT dept_exists(p_dept_id) THEN
            raise_application_error(-20001, 'Department ID '
                                            || p_dept_id
                                            || ' does not exist.');
        END IF;

        IF p_salary <= 0 THEN
            raise_application_error(-20002, 'Salary must be greater than zero.');
        END IF;
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
            p_name,
            p_email,
            p_dept_id,
            p_job,
            p_salary,
            sysdate,
            'ACTIVE'
        );

        COMMIT;
        dbms_output.put_line('Employee added: ' || p_name);
    EXCEPTION
        WHEN dup_val_on_index THEN
            dbms_output.put_line('ERROR: Email already in use — ' || p_email);
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('ERROR: ' || sqlerrm);
    END add_employee;
        
        -- Calculate bonus function
    FUNCTION calculate_bonus (
        p_salary    IN NUMBER,
        p_job_title IN VARCHAR2
    ) RETURN NUMBER AS
        v_bonus NUMBER;
    BEGIN
        IF p_job_title LIKE '%Sr%' OR p_job_title LIKE '%Senior%' OR p_job_title LIKE '%Lead%' THEN
            v_bonus := p_salary * 0.20;
        ELSIF p_job_title LIKE '%Manager%' THEN
            v_bonus := p_salary * 0.25;
        ELSIF p_job_title LIKE '%Intern%' THEN
            v_bonus := p_salary * 0.05;
        ELSE
            v_bonus := p_salary * 0.10;
        END IF;

        RETURN round(v_bonus, 2);
    END calculate_bonus;

        -- Process monthly payroll 
    PROCEDURE process_monthly_payroll (
        p_month IN VARCHAR2
    ) AS

        CURSOR emp_cursor IS
        SELECT
            emp_id,
            salary,
            job_title
        FROM
            employees
        WHERE
            status = 'ACTIVE';

        v_bonus             NUMBER;
        v_deduction         NUMBER;
        v_net               NUMBER;
        v_already_processed NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO v_already_processed
        FROM
            payroll
        WHERE
            pay_month = p_month;

        IF v_already_processed > 0 THEN
            dbms_output.put_line('WARNING: Payroll for '
                                 || p_month
                                 || ' already exists. Skipping.');
            RETURN;
        END IF;

        FOR emp_rec IN emp_cursor LOOP
            v_bonus := calculate_bonus(emp_rec.salary, emp_rec.job_title);
            v_deduction := round(emp_rec.salary * 0.10, 2);
            v_net := emp_rec.salary + v_bonus - v_deduction;
            INSERT INTO payroll (
                payroll_id,
                emp_id,
                pay_month,
                basic_salary,
                bonus,
                deductions,
                net_salary,
                processed_date
            ) VALUES (
                pay_seq.NEXTVAL,
                emp_rec.emp_id,
                p_month,
                emp_rec.salary,
                v_bonus,
                v_deduction,
                v_net,
                sysdate
            );

        END LOOP;

        COMMIT;
        dbms_output.put_line('Payroll processed for: ' || p_month);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            dbms_output.put_line('ERROR: ' || sqlerrm);
    END process_monthly_payroll;
        
        -- Generate payroll report
    PROCEDURE generate_payroll_report (
        p_month IN VARCHAR2
    ) AS

        CURSOR report_cursor IS
        SELECT
            e.emp_name,
            d.dept_name,
            p.basic_salary,
            p.bonus,
            p.deductions,
            p.net_salary
        FROM
                 payroll p
            JOIN employees   e ON p.emp_id = e.emp_id
            JOIN departments d ON e.dept_id = d.dept_id
        WHERE
            p.pay_month = p_month
        ORDER BY
            d.dept_name,
            p.net_salary DESC;

        v_total NUMBER := 0;
        v_count NUMBER := 0;
    BEGIN
        dbms_output.put_line('========================================');
        dbms_output.put_line('  PAYROLL REPORT: ' || p_month);
        dbms_output.put_line('========================================');
        FOR r IN report_cursor LOOP
            dbms_output.put_line(rpad(r.emp_name, 22)
                                 || rpad(r.dept_name, 14)
                                 || ' Basic: '
                                 || lpad(r.basic_salary, 8)
                                 || ' Bonus: '
                                 || lpad(r.bonus, 7)
                                 || ' Net: '
                                 || lpad(r.net_salary, 9));

            v_total := v_total + r.net_salary;
            v_count := v_count + 1;
        END LOOP;

        dbms_output.put_line('----------------------------------------');
        dbms_output.put_line('Total Employees : ' || v_count);
        dbms_output.put_line('Total Payout    : ' || v_total);
        dbms_output.put_line('========================================');
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('ERROR: ' || sqlerrm);
    END generate_payroll_report;
        
        -- Get total payout
    FUNCTION get_total_payout (
        p_month IN VARCHAR2
    ) RETURN NUMBER AS
        v_total NUMBER;
    BEGIN
        SELECT
            nvl(SUM(net_salary), 0)
        INTO v_total
        FROM
            payroll
        WHERE
            pay_month = p_month;

        RETURN v_total;
    END get_total_payout;

END payroll_pkg;
/

-- Verify both spec and body are VALID
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'PAYROLL_PKG'
ORDER BY object_type;