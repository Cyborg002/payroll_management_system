CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_attendance(
    p_employee_id IN NUMBER,
    p_day         IN NUMBER,
    p_month       IN NUMBER,
    p_year        IN NUMBER,
    p_status      IN VARCHAR2,
    p_mode        IN VARCHAR2)
AS
  v_old_status VARCHAR2(10);
  v_employee_count NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status         NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  v_status          :=0;
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
      INTO attendance
        (
          employee_id,
          status
        )
        VALUES
        (
          p_employee_id,
          p_status
        );
        enter_and_maintain_leaves(p_employee_id);
      HTP.P('Record added successfully');
    ELSIF lower(p_mode)='update' THEN
      SELECT p_status
      INTO v_old_status
      FROM attendance
      WHERE employee_id= p_employee_id
      AND day=p_day
      AND month=p_month
      AND year  =p_year;
      IF SQL%NOTFOUND --why to use it when exception block is present
        THEN
        HTP.P('invalid employee id and/or date');
      ELSE
        UPDATE attendance
        SET status=NVL(p_status,v_old_status)
      WHERE employee_id= p_employee_id
      AND day=p_day
      AND month=p_month
      AND year  =p_year;
      enter_and_maintain_leaves(p_employee_id);
        HTP.P('Record Updated');
      END IF;
    ELSE
      HTP.P('invalid mode') ;
    END IF;
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