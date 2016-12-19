CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_tax(
    p_employee_id IN NUMBER,
    p_salary_year IN NUMBER)
AS
  v_basic        NUMBER(10);
  v_hra          NUMBER(10,2); --50% of basic
  v_conveyance   NUMBER(10,2); --Rs.1500*12 per year
  v_medical      NUMBER(10,2); --15k per year
  v_tds          NUMBER(10,2);
  v_sum          NUMBER(10,2);
  v_empsal_count NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status       NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  SELECT basic,
    hra,
    conveyance,
    medical
  INTO v_basic,
    v_hra,
    v_conveyance,
    v_medical
  FROM annual_salary
  WHERE employee_id=p_employee_id
  AND salary_year  =p_salary_year;
  SELECT basic+ hra+ conveyance+ medical+ lta+ monthly_bonus+ shift_allowance+ additional_personal_pay+leave_encashed
  INTO v_sum
  FROM annual_salary
  WHERE employee_id=p_employee_id
  AND salary_year  =p_salary_year;
  v_status        :=0;
  SELECT COUNT(*)
  INTO v_empsal_count
  FROM annual_salary
  WHERE employee_id =p_employee_id
  AND salary_year   =p_salary_year;
  IF v_empsal_count =1 THEN
    v_status       :=1;
  END IF;
  IF v_status =1 THEN
    IF v_sum <=15000*12 THEN
      UPDATE deduction
      SET esi          =0.0175*v_basic
      WHERE employee_id=p_employee_id
      AND salary_year  =p_salary_year;
    ELSE
      UPDATE deduction
      SET esi          =0
      WHERE employee_id=p_employee_id
      AND salary_year  =p_salary_year;
    END IF;
    UPDATE deduction
    SET epf          =0.12  *v_basic,
      tax_exemption  = v_hra+v_conveyance+v_medical,
      tds            =get_tds(p_employee_id,p_salary_year,v_sum)
    WHERE employee_id=p_employee_id
    AND salary_year  =p_salary_year;
  ELSE
    HTP.P('no such employee is present as given');
  END IF;
  COMMIT;
  page_formatting('AFTER');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  HTP.P(SQLCODE||' '||SQLERRM);
WHEN TOO_MANY_ROWS THEN
  HTP.P(SQLCODE||' '||SQLERRM);
WHEN OTHERS THEN
  HTP.P(SQLCODE||' '||SQLERRM);
END;
/
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_tax TO PUBLIC;
show error;