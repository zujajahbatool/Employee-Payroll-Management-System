-- Creating salary audit trigger
CREATE OR REPLACE TRIGGER trg_salary_audit BEFORE
    UPDATE OF salary ON employees
    FOR EACH ROW
    WHEN ( old.salary != new.salary ) -- only fires if salary actually changed
BEGIN
    INSERT INTO salary_audit (
        audit_id,
        emp_id,
        old_salary,
        new_salary,
        changed_by,
        changed_on
    ) VALUES (
        audit_seq.NEXTVAL,
        :old.emp_id,
        :old.salary,
        :new.salary,
        user,
        sysdate
    );

END;
/

-- Verify trigger is VALID
SELECT object_name, status
FROM user_objects
WHERE object_name = 'TRG_SALARY_AUDIT';