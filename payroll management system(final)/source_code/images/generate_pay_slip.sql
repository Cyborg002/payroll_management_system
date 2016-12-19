CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE generate_pay_slip(
    p_employee_id  IN NUMBER,
    p_date         IN OUT DATE,
    p_lencash_mode IN NUMBER)
AS
  v_first_name              VARCHAR2(100);
  v_last_name               VARCHAR2(100);
  v_employee_type           VARCHAR2(100);
  v_designation             VARCHAR2(100);
  v_ESI_no                  VARCHAR2(12);
  v_PAN                     VARCHAR2(10);
  v_PF_no                   VARCHAR2(18);
  v_PF_UAN_no               NUMBER(12);
  v_bank                    VARCHAR2(20);
  v_bank_ac_no              NUMBER(16);
  v_service_start_date      DATE;
  v_service_end_date        DATE;
  v_department_id_1         NUMBER(10);
  v_department_id_2         NUMBER(10);
  v_department_name_1       VARCHAR2(100);
  v_department_name_2       VARCHAR2(100);
  v_basic                   NUMBER(10);
  v_hra                     NUMBER(10,2); --50% of basic
  v_conveyance              NUMBER(10,2); --Rs.1500*12 per year
  v_medical                 NUMBER(10,2); --15k per year
  v_lta                     NUMBER(10,2); --20k per year
  v_monthly_bonus           NUMBER(10,2); --20% of basic
  v_shift_allowance         NUMBER(10,2); --Rs.0
  v_additional_personal_pay NUMBER(10,2); --80% of basic
  v_leave_encashed          NUMBER(10);
  v_lencash_days            NUMBER(10);
  v_lpe                     NUMBER(1);
  v_sum                     NUMBER(10,2);
  v_sum_new                 NUMBER(10,2);
  v_loss_of_pay             NUMBER(10,2);
  v_esi                     NUMBER(10,2);
  v_epf                     NUMBER(10,2);
  v_profession_tax          NUMBER(10,2);
  v_tds                     NUMBER(10,2);
  v_tds_new                 NUMBER(10,2);
  v_tds_month               NUMBER(10,2);
  v_gross_earning           NUMBER(10,2); --15k per year
  v_gross_deduction         NUMBER(10,2);
  v_net_pay                 NUMBER(10,2);
  v_days_payable            NUMBER(2);
  v_calendar_days           NUMBER(2);
  v_empattend_count         NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status                  NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  p_date   :=add_months(last_day(p_date),-1)+1;
  v_status :=0;
  SELECT COUNT(*)
  INTO v_empattend_count
  FROM attendance
  WHERE employee_id    =p_employee_id
  AND YEAR             =extract(YEAR FROM p_date)
  AND MONTH            = extract(MONTH FROM p_date)-1;
  IF v_empattend_count >0 THEN
    v_status          :=1;
  END IF;
  IF v_status =1 THEN
    SELECT basic+ hra+ conveyance+ medical+ lta+ monthly_bonus+ shift_allowance+ additional_personal_pay
    INTO v_sum
    FROM annual_salary
    WHERE employee_id            =p_employee_id
    AND salary_year              =extract(YEAR FROM p_date);
    IF extract(YEAR FROM p_date) =extract(YEAR FROM sysdate) THEN
      IF lower(p_lencash_mode)   ='yes' THEN
        enter_and_maintain_lencash(p_employee_id);
        SELECT basic+ hra+ conveyance+ medical+ lta+ monthly_bonus+ shift_allowance+ additional_personal_pay+leave_encashed
        INTO v_sum_new
        FROM annual_salary
        WHERE employee_id =p_employee_id
        AND salary_year   =extract(YEAR FROM p_date);
        UPDATE deduction
        SET tds                  =get_tds(p_employee_id,extract(YEAR FROM p_date),v_sum_new)
        WHERE employee_id        =p_employee_id
        AND salary_year          =extract(YEAR FROM p_date);
      ELSIF lower(p_lencash_mode)='no' THEN
        v_sum_new               :=v_sum;
      ELSE
        HTP.P('Invalid Input for p_lencash_mode');
      END IF;
    ELSE
      SELECT leave_encashed
      INTO v_leave_encashed
      FROM annual_salary
      WHERE employee_id   =p_employee_id
      AND salary_year     =extract(YEAR FROM p_date);
      v_lpe              :=0;
      IF v_leave_encashed!=0 THEN
        SELECT COUNT(*)
        INTO v_lpe
        FROM
          (SELECT *
          FROM attendance
          WHERE employee_id   =p_employee_id
          AND YEAR            =extract(YEAR FROM p_date)
          AND leave_encashable=0
          AND MONTH           =extract(MONTH FROM p_date)+1
          AND DAY             =1
          INTERSECT
          SELECT *
          FROM attendance
          WHERE employee_id    =p_employee_id
          AND YEAR             =extract(YEAR FROM p_date)
          AND leave_encashable!=0
          AND MONTH            =extract(MONTH FROM p_date)
          AND DAY              =1
          );
      END IF;
      IF v_lpe    =1 THEN
        v_sum_new:=v_sum+v_leave_encashed;
      ELSE
        v_sum_new:=v_sum;
      END IF;
    END IF;
    v_tds      :=get_tds(p_employee_id,extract(YEAR FROM p_date),v_sum);
    v_tds_new  :=get_tds(p_employee_id,extract(YEAR FROM p_date),v_sum_new)-v_tds;
    v_tds_month:=(v_tds                                                    /12)+v_tds_new;
  ELSE
    HTP.P('no such employee is present in attendance table');
  END IF;
  ------------------------------------------------X---------X---------X------------X-----------------X---------------------X----------------------------------------
  SELECT first_name,
    last_name,
    employee_type,
    designation,
    esi_no,
    PAN,
    PF_no,
    PF_UAN_no,
    bank,
    bank_ac_no,
    service_start_date,
    service_end_date,
    department_id_1,
    department_id_2
  INTO v_first_name,
    v_last_name,
    v_employee_type,
    v_designation,
    v_ESI_no,
    v_PAN,
    v_PF_no,
    v_PF_UAN_no,
    v_bank,
    v_bank_ac_no,
    v_service_start_date,
    v_service_end_date,
    v_department_id_1,
    v_department_id_2
  FROM employee
  WHERE employee_id=p_employee_id;
  SELECT department_name
  INTO v_department_name_1
  FROM department
  WHERE department_id=v_department_id_1;
  SELECT department_name
  INTO v_department_name_2
  FROM department
  WHERE department_id=v_department_id_2;
  SELECT basic,
    hra,
    conveyance,
    medical,
    lta,
    monthly_bonus,
    shift_allowance,
    additional_personal_pay,
    leave_encashed
  INTO v_basic,
    v_hra,
    v_conveyance,
    v_medical,
    v_lta,
    v_monthly_bonus,
    v_shift_allowance,
    v_additional_personal_pay,
    v_leave_encashed
  FROM annual_salary
  WHERE employee_id=p_employee_id
  AND salary_year  =extract(YEAR FROM p_date);
  v_lencash_days  :=v_leave_encashed/1000;
  SELECT esi,
    epf,
    profession_tax
  INTO v_esi,
    v_epf,
    v_profession_tax
  FROM deduction
  WHERE employee_id=p_employee_id
  AND salary_year  =extract(YEAR FROM p_date);
  SELECT loss_of_pay
  INTO v_loss_of_pay
  FROM attendance
  WHERE employee_id =p_employee_id
  AND YEAR          =extract(YEAR FROM p_date)
  AND MONTH         =extract(MONTH FROM p_date)                  -1
  AND DAY           =extract(DAY FROM last_day(add_months(p_date,-1)));
  v_calendar_days  :=extract(DAY FROM last_day(add_months(p_date,-1)));
  v_days_payable   :=v_calendar_days                             -(v_loss_of_pay/1000);
  v_gross_earning  :=(v_sum)                                     /12+v_leave_encashed;
  v_gross_deduction:=(v_esi                                      +v_epf+v_profession_tax)/12+v_tds_month+v_loss_of_pay;
  v_net_pay        :=v_gross_earning                             -v_gross_deduction;
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