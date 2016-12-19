CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_lencash(
    p_employee_id IN NUMBER)--It is only for present year that's why no p_salary_year
AS
  v_service_start_date DATE;
  v_leave_encashment   NUMBER(10);
  v_employee_count     NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status             NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  SELECT service_start_date
  INTO v_service_start_date
  FROM employee
  WHERE employee_id=p_employee_id;
  v_status        :=0;
  SELECT COUNT(*)
  INTO v_employee_count
  FROM employee
  WHERE employee_id  =p_employee_id;
  IF v_employee_count=1 THEN
    v_status        :=1;
  END IF;
  IF v_status =1 THEN
    SELECT leave_encashable
    INTO v_leave_encashment
    FROM attendance
    WHERE employee_id =p_employee_id
    AND DAY           =extract(DAY FROM sysdate)
    AND MONTH         =extract(MONTH FROM sysdate)
    AND YEAR          =extract(YEAR FROM sysdate);
    UPDATE annual_salary
    SET leave_encashed=v_leave_encashment
    WHERE employee_id =p_employee_id
    AND salary_year   =extract(YEAR FROM sysdate);
    UPDATE attendance
    SET remaining_paid_leaves=0
    WHERE employee_id        =p_employee_id
    AND YEAR BETWEEN extract(YEAR FROM v_service_start_date) AND (extract(YEAR FROM sysdate)-1)
    AND remaining_paid_leaves!=0;
    HTP.P('Record added successfully');
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
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_leaves TO PUBLIC;
show error;