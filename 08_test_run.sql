-- 1. Process MAY-2026 payroll (standalone procedure)
EXEC process_monthly_payroll('MAY-2026');

-- 2. Verify payroll records
SELECT e.emp_name, p.pay_month, p.basic_salary,
       p.bonus, p.deductions, p.net_salary
FROM payroll p
JOIN employees e ON p.emp_id = e.emp_id
ORDER BY p.net_salary DESC;

-- 3. Generate standalone report
EXEC generate_payroll_report('MAY-2026');

-- 4. Test audit trigger — update a salary
UPDATE employees SET salary = 99000 WHERE emp_id = 17;
COMMIT;

-- 5. Check audit log
SELECT a.audit_id, e.emp_name,
       a.old_salary, a.new_salary,
       a.new_salary - a.old_salary AS change_amount,
       a.changed_by, a.changed_on
FROM salary_audit a
JOIN employees e ON a.emp_id = e.emp_id;

-- 6. Confirm trigger ignores non-salary updates
UPDATE employees SET status = 'ACTIVE' WHERE emp_id = 17;
COMMIT;
SELECT COUNT(*) AS audit_count FROM salary_audit;  -- should still be 1

-- 7. Add employee via package
EXEC payroll_pkg.add_employee('Sara Malik', 'sara.malik@company.com', 2, 'Finance Lead', 78000);

-- 8. Process JUN-2026 via package
EXEC payroll_pkg.process_monthly_payroll('JUN-2026');

-- 9. Generate report via package
EXEC payroll_pkg.generate_payroll_report('JUN-2026');

-- 10. Get total payout via package function
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Total Payout for JUN-2026: ' || payroll_pkg.get_total_payout('JUN-2026')
    );
END;
/

-- 11. Confirm private function is inaccessible (this SHOULD fail — that's correct)
BEGIN
    IF payroll_pkg.dept_exists(1) THEN
        DBMS_OUTPUT.PUT_LINE('exists');
    END IF;
END;
/

-- 12. Final status check — everything should be VALID
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','TRIGGER')
ORDER BY object_type, object_name;