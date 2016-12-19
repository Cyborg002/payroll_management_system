CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_department(
    p_department_id      IN NUMBER,--It is provided only at the time of update not at time of insert
    p_department_name    IN VARCHAR2,
    p_department_head_id IN NUMBER,
    p_mode               IN VARCHAR2 )
AS
  v_old_department_name    VARCHAR2(100);
  v_old_department_head_id NUMBER(10);
  v_employee_count         NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status                 NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  v_status                :=0;
  IF p_department_head_id IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_employee_count
    FROM employee
    WHERE employee_id  =p_department_head_id;
    IF v_employee_count=1 THEN
      v_status        :=1;
    END IF;
  ELSE
    v_status:=1;
  END IF;
  IF v_status       =1 THEN
    IF lower(p_mode)='insert' THEN
      INSERT
      INTO department
        (
          department_id ,
          department_name ,
          department_head_id
        )
        VALUES
        (
          department_id_seq.nextval ,
          p_department_name ,
          p_department_head_id
        );
      HTP.P('Record added successfully');
    ELSIF lower(p_mode)='update' THEN
      SELECT department_name ,
        department_head_id
      INTO v_old_department_name ,
        v_old_department_head_id
      FROM department
      WHERE department_id= p_department_id;
      IF SQL%NOTFOUND --It can also be implemented using another count for department.
        THEN
        HTP.P('invalid department id');
      ELSE
        UPDATE department
        SET department_name  = NVL (p_department_name,v_old_department_name) ,
          department_head_id =NVL(p_department_head_id,v_old_department_head_id)
        WHERE department_id  = p_department_id;
        HTP.P('Record Updated');
      END IF;
    ELSE
      HTP.P('invalid mode') ;
    END IF;
  ELSE
    HTP.P('no such employee is present as given in department_head_id');
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
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_department TO PUBLIC;
show error;