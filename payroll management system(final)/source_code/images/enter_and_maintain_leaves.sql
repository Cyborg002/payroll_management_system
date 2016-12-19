CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_leaves(
    p_employee_id IN NUMBER)
AS
  v_leaves_taken          NUMBER(2);
  v_monthly_leaves        NUMBER(2);
  v_remaining_paid_leaves NUMBER(2);
  v_previous_paid_leaves  NUMBER(10);
  v_service_start_date    DATE;
  v_employee_count        NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status                NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  SELECT COUNT(*)
  INTO v_leaves_taken
  FROM attendance
  WHERE employee_id=p_employee_id
  AND lower(status)='absent'
  AND YEAR         =extract(YEAR FROM sysdate);
  SELECT COUNT(*)
  INTO v_monthly_leaves
  FROM attendance
  WHERE employee_id=p_employee_id
  AND lower(status)='absent'
  AND MONTH        =extract(MONTH FROM sysdate)
  AND YEAR         =extract(YEAR FROM sysdate);
  SELECT service_start_date
  INTO v_service_start_date
  FROM employee
  WHERE employee_id=p_employee_id;
  SELECT sum(remaining_paid_leaves)
  INTO v_previous_paid_leaves
  FROM attendance
  WHERE employee_id=p_employee_id 
  AND year BETWEEN extract(YEAR FROM v_service_start_date) AND (extract(YEAR FROM sysdate)-1)
  AND remaining_paid_leaves!=0;
  v_status        :=0;
  SELECT COUNT(*)
  INTO v_employee_count
  FROM employee
  WHERE employee_id  =p_employee_id;
  IF v_employee_count=1 THEN
    v_status        :=1;
  END IF;
  IF v_status         =1 THEN
    IF v_leaves_taken<=10 THEN
      UPDATE attendance
      SET remaining_unpaid_leaves=(10-v_leaves_taken),
        remaining_paid_leaves    =15
      WHERE employee_id          =p_employee_id
      AND DAY                    =extract(DAY FROM sysdate)
      AND MONTH                  =extract(MONTH FROM sysdate)
      AND YEAR                   =extract(YEAR FROM sysdate);
    ELSE
      UPDATE attendance
      SET remaining_unpaid_leaves=0
      WHERE employee_id          =p_employee_id
      AND DAY                    =extract(DAY FROM sysdate)
      AND MONTH                  =extract(MONTH FROM sysdate)
      AND YEAR                   =extract(YEAR FROM sysdate);
    END IF;
    IF v_leaves_taken>=10 AND v_leaves_taken<=25 THEN
      UPDATE attendance
      SET remaining_paid_leaves=(25-v_leaves_taken)
      WHERE employee_id        =p_employee_id
      AND DAY                  =extract(DAY FROM sysdate)
      AND MONTH                =extract(MONTH FROM sysdate)
      AND YEAR                 =extract(YEAR FROM sysdate);
    ELSIF v_leaves_taken       >25 THEN
      UPDATE attendance
      SET remaining_paid_leaves=0
      WHERE employee_id        =p_employee_id
      AND DAY                  =extract(DAY FROM sysdate)
      AND MONTH                =extract(MONTH FROM sysdate)
      AND YEAR                 =extract(YEAR FROM sysdate);
    END IF;
    SELECT remaining_paid_leaves
    INTO v_remaining_paid_leaves
    FROM attendance
    WHERE employee_id                      =p_employee_id
    AND DAY                                =extract(DAY FROM sysdate)
    AND MONTH                              =extract(MONTH FROM sysdate)
    AND YEAR                               =extract(YEAR FROM sysdate);
    IF v_remaining_paid_leaves             =0 THEN
      IF (v_leaves_taken-v_monthly_leaves)<=25 THEN
        UPDATE attendance
        SET loss_of_pay  =(v_leaves_taken-25)*1000
        WHERE employee_id=p_employee_id
        AND DAY          =extract(DAY FROM sysdate)
        AND MONTH        =extract(MONTH FROM sysdate)
        AND YEAR         =extract(YEAR FROM sysdate);
      ELSE
        UPDATE attendance
        SET loss_of_pay  =v_monthly_leaves*1000
        WHERE employee_id=p_employee_id
        AND DAY          =extract(DAY FROM sysdate)
        AND MONTH        =extract(MONTH FROM sysdate)
        AND YEAR         =extract(YEAR FROM sysdate);
      END IF;
    ELSE
      UPDATE attendance
      SET loss_of_pay  =0
      WHERE employee_id=p_employee_id
      AND DAY          =extract(DAY FROM sysdate)
      AND MONTH        =extract(MONTH FROM sysdate)
      AND YEAR         =extract(YEAR FROM sysdate);
    END IF;
    UPDATE attendance
    SET leave_encashable=v_previous_paid_leaves*1000 --leave encashment is entitled to be provided for previous complete years only
    WHERE employee_id   =p_employee_id
    AND YEAR            =extract(YEAR FROM sysdate);
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