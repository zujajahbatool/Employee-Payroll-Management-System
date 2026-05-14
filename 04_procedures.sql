-- Creating process_monthly_payroll procedure
CREATE OR REPLACE PROCEDURE process_monthly_payroll (
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
 
    -- Preventing the same month to run twice
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
                             || ' already processed. Skipping.');
        RETURN;
    END IF;

    FOR emp_rec IN emp_cursor LOOP
        v_bonus := calculate_bonus(emp_rec.salary, emp_rec.job_title);
        v_deduction := round(emp_rec.salary * 0.10, 2);   -- 10% tax deduction
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

        dbms_output.put_line('Emp ID: '
                             || emp_rec.emp_id
                             || ' | Basic: '
                             || emp_rec.salary
                             || ' | Bonus: '
                             || v_bonus
                             || ' | Deduction: '
                             || v_deduction
                             || ' | Net: '
                             || v_net);

    END LOOP;

    COMMIT;
    dbms_output.put_line('--- Payroll for '
                         || p_month
                         || ' completed successfully. ---');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('ERROR: ' || sqlerrm);
END;
/

-- Creating generate_payroll_report
CREATE OR REPLACE PROCEDURE generate_payroll_report (
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

    v_total_net NUMBER := 0;
    v_count     NUMBER := 0;
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

        v_total_net := v_total_net + r.net_salary;
        v_count := v_count + 1;
    END LOOP;

    dbms_output.put_line('----------------------------------------');
    dbms_output.put_line('Total Employees: ' || v_count);
    dbms_output.put_line('Total Payout:    ' || v_total_net);
    dbms_output.put_line('========================================');
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('No payroll data found for: ' || p_month);
    WHEN OTHERS THEN
        dbms_output.put_line('ERROR: ' || sqlerrm);
END;
/