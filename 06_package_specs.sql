-- Ceating Package Specs
CREATE OR REPLACE PACKAGE payroll_pkg AS

    -- Adding new employee with validation
    PROCEDURE add_employee (
        p_name    VARCHAR2,
        p_email   VARCHAR2,
        p_dept_id NUMBER,
        p_job     VARCHAR2,
        p_salary  NUMBER
    );
    
    -- Process payroll for all active employees in a given month
    PROCEDURE process_monthly_payroll (
        p_month IN VARCHAR2
    );
    
    -- Generating a formatted payroll report
    PROCEDURE generate_payroll_report (
        p_month IN VARCHAR2
    );
    
    -- Calculates bonus based on salary and job
    FUNCTION calculate_bonus (
        p_salary    IN NUMBER,
        p_job_title IN VARCHAR2
    ) RETURN NUMBER;
    
    -- Return total paayout amount for a given month
    FUNCTION get_total_payout (
        p_month IN VARCHAR2
    ) RETURN NUMBER;

END payroll_pkg;
/

-- Verifying payroll_pkg before moving onto the pkg body
SELECT
    object_name,
    object_type,
    status
FROM
    user_objects
WHERE
    object_name = 'PAYROLL_PKG';