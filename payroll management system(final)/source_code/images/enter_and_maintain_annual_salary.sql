CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_annual_sal(
    p_employee_id             IN NUMBER,
    p_basic                   IN NUMBER,
    p_hra                     IN NUMBER, --50% of basic
    p_conveyance              IN NUMBER, --Rs.1500*12 per year
    p_medical                 IN NUMBER, --15k per year
    p_lta                     IN NUMBER, --20k per year
    p_monthly_bonus           IN NUMBER, --20% of basic
    p_shift_allowance         IN NUMBER, --Rs.0
    p_additional_personal_pay IN NUMBER, --80% of basic
    p_salary_year             IN NUMBER,
    p_mode                    IN VARCHAR2)
AS
  v_old_basic                   NUMBER(10);
  v_old_hra                     NUMBER(10,2); --50% of basic
  v_old_conveyance              NUMBER(10,2); --Rs.1500*12 per year
  v_old_medical                 NUMBER(10,2); --15k per year
  v_old_lta                     NUMBER(10,2); --20k per year
  v_old_monthly_bonus           NUMBER(10,2); --20% of basic
  v_old_shift_allowance         NUMBER(10,2); --Rs.0
  v_old_additional_personal_pay NUMBER(10,2); --80% of basic
  v_employee_count              NUMBER(10);   --need to use count for all foreign keys to check integrity constraint
  v_status                      NUMBER(10);
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
  IF v_status       =1 THEN
    IF lower(p_mode)='insert' THEN
      INSERT
      INTO annual_salary
        (
          employee_id,
          basic,
          hra,
          conveyance,
          medical,
          lta,
          monthly_bonus,
          shift_allowance,
          additional_personal_pay
        )
        VALUES
        (
          employee_id_seq.nextval,
          p_basic,
          p_hra,                    --50% of basic
          p_conveyance,             --Rs.1500*12 per year
          p_medical,                --15k per year
          p_lta,                    --20k per year
          p_monthly_bonus,          --20% of basic
          p_shift_allowance,        --Rs.0
          p_additional_personal_pay --80% of basic
        );
      HTP.P('Record added successfully');
    ELSIF lower(p_mode)='update' THEN
      SELECT basic,
        hra,
        conveyance,
        medical,
        lta,
        monthly_bonus,
        shift_allowance,
        additional_personal_pay
      INTO v_old_basic,
        v_old_hra,                    --50% of basic
        v_old_conveyance,             --Rs.1500*12 per year
        v_old_medical,                --15k per year
        v_old_lta,                    --20k per year
        v_old_monthly_bonus,          --20% of basic
        v_old_shift_allowance,        --Rs.0
        v_old_additional_personal_pay --80% of basic
      FROM annual_salary
      WHERE employee_id= p_employee_id
      AND salary_year  =p_salary_year;
      IF SQL%NOTFOUND --why to use it when exception block is present
        THEN
        HTP.P('invalid employee id and/or salary year');
      ELSE
        UPDATE annual_salary
        SET basic                =NVL(p_basic,v_old_basic),
          hra                    =NVL(p_hra,v_old_hra),
          conveyance             =NVL(p_conveyance,v_old_conveyance),
          medical                =NVL(p_medical,v_old_medical),
          lta                    =NVL(p_lta,v_old_lta),
          monthly_bonus          =NVL(p_monthly_bonus,v_old_monthly_bonus),
          shift_allowance        =NVL(p_shift_allowance,v_old_shift_allowance),
          additional_personal_pay=NVL(p_additional_personal_pay,v_old_additional_personal_pay)
        WHERE employee_id        = p_employee_id
        AND salary_year          =p_salary_year;
        enter_and_maintain_tax(p_employee_id,p_salary_year);
        HTP.P('Record Updated');
      END IF;
    ELSE
      HTP.P('invalid mode') ;
    END IF;
  ELSE
    HTP.P('no such employee is present as given in employee_id');
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
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_annual_sal TO PUBLIC;
show error;