CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_employee(
    p_employee_id        IN NUMBER,--It is provided only at the time of update not at time of insert
    p_first_name         IN VARCHAR2,
    p_last_name          IN VARCHAR2,
    p_date_of_birth      IN DATE,
    p_employee_type      IN VARCHAR2,
    p_designation        IN VARCHAR2,
    p_email              IN VARCHAR2,
    p_contact_no         IN NUMBER,
    p_ESI_no             IN VARCHAR2,
    p_PAN                IN VARCHAR2,
    p_PF_no              IN VARCHAR2,
    p_PF_UAN_no          IN NUMBER,
    p_bank               IN VARCHAR2,
    p_bank_ac_no         IN NUMBER,
    p_service_start_date IN DATE,
    p_service_end_date   IN DATE,
    p_department_id_1    IN OUT NUMBER,
    p_department_id_2    IN OUT NUMBER,
    p_mode               IN VARCHAR2)
AS
  v_old_first_name         VARCHAR2(100);
  v_old_last_name          VARCHAR2(100);
  v_old_date_of_birth      DATE;
  v_old_employee_type      VARCHAR2(100);
  v_old_designation        VARCHAR2(100);
  v_old_email              VARCHAR2(100);
  v_old_contact_no         NUMBER(10);
  v_old_ESI_no             VARCHAR2(100);
  v_esi                    NUMBER(10,2);
  v_old_PAN                VARCHAR2(100);
  v_old_PF_no              VARCHAR2(100);
  v_old_PF_UAN_no          NUMBER(12);
  v_old_bank               VARCHAR2(100);
  v_old_bank_ac_no         NUMBER(16);
  v_old_service_start_date DATE;
  v_old_service_end_date   DATE;
  v_old_department_id_1    NUMBER(10);
  v_old_department_id_2    NUMBER(10);
  v_department_count       NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status                 NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  v_status               :=0;
  IF p_department_id_1   IS NOT NULL OR p_department_id_2 IS NOT NULL THEN
    p_department_id_1    :=NVL(p_department_id_1,p_department_id_2);
    p_department_id_2    :=NVL(p_department_id_2,p_department_id_1);
    IF p_department_id_1 IS NOT NULL AND p_department_id_2 IS NOT NULL THEN
      SELECT COUNT(*)
      INTO v_department_count
      FROM department
      WHERE department_id  =p_department_id_1
      AND department_id    =p_department_id_2;
      IF v_department_count>0 THEN 
        v_status          :=1;
      END IF;
    END IF;
  ELSE
    v_status:=1;
  END IF;
  IF v_status       =1 THEN
    IF lower(p_mode)='insert' THEN
      INSERT
      INTO employee
        (
          employee_id,
          first_name,
          last_name,
          date_of_birth,
          employee_type,
          designation,
          email,
          contact_no,
          PAN,
          PF_no,
          PF_UAN_no,
          bank,
          bank_ac_no,
          service_start_date,
          service_end_date,
          department_id_1,
          department_id_2
        )
        VALUES
        (
          employee_id_seq.nextval,
          p_first_name,
          p_last_name,
          p_date_of_birth,
          p_employee_type,
          p_designation,
          p_email,
          p_contact_no,
          p_PAN,
          p_PF_no,
          p_PF_UAN_no,
          p_bank,
          p_bank_ac_no,
          p_service_start_date,
          p_service_end_date,
          p_department_id_1,
          p_department_id_2
        );
      SELECT esi
      INTO v_esi
      FROM deduction
      WHERE employee_id=p_employee_id
      AND salary_year  =extract(YEAR FROM sysdate);
      IF SQL%NOTFOUND --why to use it when exception block is present
        THEN
        HTP.P('update deduction table for this employee first');
      ELSE
        IF v_esi!=0 THEN
          UPDATE employee SET esi_no =p_esi_no WHERE employee_id=p_employee_id;
        ELSE
          UPDATE employee SET esi_no ='Not Eligible' WHERE employee_id=p_employee_id;
        END IF;
      END IF;
      HTP.P('Record added successfully');
    ELSIF lower(p_mode)='update' THEN
      SELECT first_name,
        last_name,
        date_of_birth,
        employee_type,
        designation,
        email,
        contact_no,
        ESI_no,
        PAN,
        PF_no,
        PF_UAN_no,
        bank,
        bank_ac_no,
        service_start_date,
        service_end_date,
        department_id_1,
        department_id_2
      INTO v_old_first_name,
        v_old_last_name,
        v_old_date_of_birth,
        v_old_employee_type,
        v_old_designation,
        v_old_email,
        v_old_contact_no,
        v_old_ESI_no,
        v_old_PAN,
        v_old_PF_no,
        v_old_PF_UAN_no,
        v_old_bank,
        v_old_bank_ac_no,
        v_old_service_start_date,
        v_old_service_end_date,
        v_old_department_id_1,
        v_old_department_id_2
      FROM employee
      WHERE employee_id= p_employee_id;
      IF SQL%NOTFOUND --why to use it when exception block is present
        THEN
        HTP.P('invalid employee id');
      ELSE
        UPDATE employee
        SET first_name      =NVL(p_first_name,v_old_first_name),
          last_name         =NVL(p_last_name,v_old_last_name),
          date_of_birth     =NVL(p_date_of_birth,v_old_date_of_birth),
          employee_type     =NVL(p_employee_type,v_old_employee_type),
          designation       =NVL(p_designation,v_old_designation),
          email             =NVL(p_email,v_old_email),
          contact_no        =NVL(p_contact_no,v_old_contact_no),
          PAN               =NVL(p_PAN,v_old_PAN),
          PF_no             =NVL(p_PF_no,v_old_PF_no),
          PF_UAN_no         =NVL(p_PF_UAN_no,v_old_PF_UAN_no),
          bank              =NVL(p_bank,v_old_bank),
          bank_ac_no        =NVL(p_bank_ac_no,v_old_bank_ac_no),
          service_start_date=NVL(p_service_start_date,v_old_service_start_date),
          service_end_date  =NVL(p_service_end_date,v_old_service_end_date),
          department_id_1   =NVL(p_department_id_1,v_old_department_id_1),
          department_id_2   =NVL(p_department_id_2,v_old_department_id_2)
        WHERE employee_id   = p_employee_id;
        SELECT esi
        INTO v_esi
        FROM deduction
        WHERE employee_id=p_employee_id
        AND salary_year  =extract(YEAR FROM sysdate);
        IF v_esi!=0 THEN
          UPDATE employee
          SET ESI_no       =NVL(p_ESI_no,v_old_ESI_no)
          WHERE employee_id=p_employee_id;
        ELSE
          UPDATE employee SET esi_no ='Not Eligible' WHERE employee_id=p_employee_id;
        END IF;
        HTP.P('Record Updated');
      END IF;
    ELSE
      HTP.P('invalid mode') ;
    END IF;
  ELSE
    HTP.P('no such department is present as given in department_id_1 or department_id_2');
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
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_employee TO PUBLIC;
show error;