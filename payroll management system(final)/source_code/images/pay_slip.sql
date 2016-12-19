CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE payslip(
    p_employee_id IN NUMBER,
    p_month       IN NUMBER,
    p_year        IN NUMBER,
    p_lencash     IN VARCHAR2)
AS
  v_basic                   NUMBER(10);
  v_hra                     NUMBER(10,2); --50% of basic
  v_conveyance              NUMBER(10,2); --Rs.1500*12 per year
  v_medical                 NUMBER(10,2); --15k per year
  v_lta                     NUMBER(10,2); --20k per year
  v_monthly_bonus           NUMBER(10,2); --20% of basic
  v_shift_allowance         NUMBER(10,2); --Rs.0
  v_additional_personal_pay NUMBER(10,2); --80% of basic
  v_leave_encashed          NUMBER(10);
  v_employee_count          NUMBER(10);
  v_status                  NUMBER(10);
  v_earning                 NUMBER(10);
  v_esi                     NUMBER(10,2);
  v_epf                     NUMBER(10,2);
  v_profession_tax          NUMBER(10,2);
  v_tds                     NUMBER(10,2);
  v_deduction               NUMBER(10);
  v_net_pay                 NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  v_status :=0;
  SELECT COUNT(*)
  INTO v_employee_count
  FROM employee
  WHERE employee_id  =p_employee_id;
  IF v_employee_count=1 THEN
    v_status        :=1;
  END IF;
  IF v_status          =1 THEN
    IF lower(p_lencash)='yes' THEN
      enter_and_maintain_lencash(p_employee_id);
    END IF;
    SELECT basic             /12,
      hra                    /12,
      conveyance             /12,
      medical                /12,
      lta                    /12,
      monthly_bonus          /12,
      shift_allowance        /12,
      additional_personal_pay/12,
      leave_encashed         /12
    INTO v_basic,
      v_hra,                     --50% of basic
      v_conveyance,              --Rs.1500*12 per year
      v_medical,                 --15k per year
      v_lta,                     --20k per year
      v_monthly_bonus,           --20% of basic
      v_shift_allowance,         --Rs.0
      v_additional_personal_pay, --80% of basic
      v_leave_encashed
    FROM annual_salary
    WHERE employee_id= p_employee_id
    AND salary_year  =p_year;
    v_earning       :=v_basic+ v_hra+ v_conveyance + v_medical + v_lta + v_monthly_bonus + v_shift_allowance + v_additional_personal_pay+ v_leave_encashed;
    SELECT esi,
      epf,
      profession_tax,
      tds
    INTO v_esi,
      v_epf,
      v_profession_tax,
      v_tds
    FROM deduction
    WHERE employee_id=p_employee_id
    AND salary_year  =p_year;
    v_deduction     :=v_esi    +v_epf+v_profession_tax+v_tds;
    v_net_pay       :=v_earning-v_deduction;
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
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_attendance TO PUBLIC;
show error;