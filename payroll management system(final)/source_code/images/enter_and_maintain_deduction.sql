CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE enter_and_maintain_deduction(
      p_employee_id       IN NUMBER,
      p_tax_deduction     IN NUMBER,
      p_salary_year       IN NUMBER,
      p_mode              IN VARCHAR2)
AS
      v_old_employee_id       NUMBER(10);
      v_old_tax_deduction     NUMBER(10,2);
      v_old_salary_year       NUMBER(4);
      v_empsal_count          NUMBER(10); --need to use count for all foreign keys to check integrity constraint
      v_status                NUMBER(10);
BEGIN
  page_formatting('BEFORE');
  v_status         :=0;
    SELECT COUNT(*)
    INTO v_empsal_count
    FROM annual_salary
    WHERE employee_id  =p_employee_id
    AND salary_year=p_salary_year;
    IF v_empsal_count=1 THEN
      v_status        :=1;
    END IF;
  IF v_status       =1 THEN
    IF lower(p_mode)='insert' THEN
      INSERT
      INTO deduction
        (
          employee_id,
          tax_deduction
        )
        VALUES
        (
          p_employee_id,
          p_tax_deduction
        );
        enter_and_maintain_tax(p_employee_id,p_salary_year);
      HTP.P('Record added successfully');
    ELSIF lower(p_mode)='update' THEN
      SELECT tax_deduction
      INTO  v_old_tax_deduction  
      FROM deduction
      WHERE employee_id= p_employee_id
      AND salary_year  =p_salary_year;
      IF SQL%NOTFOUND --why to use it when exception block is present
        THEN
        HTP.P('invalid employee id and/or salary year');
      ELSE
        UPDATE deduction
        SET tax_deduction=NVL(p_tax_deduction,v_old_tax_deduction)
        WHERE employee_id        = p_employee_id
        AND salary_year          =p_salary_year;
        enter_and_maintain_tax(p_employee_id,p_salary_year);
        HTP.P('Record Updated');
      END IF;
    ELSE
      HTP.P('invalid mode') ;
    END IF;
  ELSE
    HTP.P('no such employee and/or salary is present as given');
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
GRANT EXECUTE ON salary_mgmt.enter_and_maintain_deduction TO PUBLIC;
show error;