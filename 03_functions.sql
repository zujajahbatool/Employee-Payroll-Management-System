-- Creating calculate_bonus function first
CREATE OR REPLACE FUNCTION calculate_bonus (
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
END;
/

-- Test it's working
SELECT
    emp_name,
    job_title,
    salary,
    calculate_bonus(salary, job_title) AS bonus
FROM
    employees;