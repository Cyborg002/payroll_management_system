CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE FUNCTION get_tds(
    p_employee_id IN NUMBER,
    p_salary_year IN NUMBER,
    p_sum IN NUMBER)
  RETURN NUMBER
AS
  v_service_end_date DATE;
  v_te               NUMBER(10,2);
  v_td               NUMBER(10,2);
  v_ti               NUMBER(10,2);
  v_tp               NUMBER(10,2);
  v_tds              NUMBER(10,2);
  v_empsal_count     NUMBER(10); --need to use count for all foreign keys to check integrity constraint
  v_status           NUMBER(10);
BEGIN
  v_status :=0;
  SELECT COUNT(*)
  INTO v_empsal_count
  FROM annual_salary
  WHERE employee_id =p_employee_id
  AND salary_year   =p_salary_year;
  IF v_empsal_count =1 THEN
    v_status       :=1;
  END IF;
IF v_status=1 THEN
  SELECT hra+conveyance+medical
  INTO v_te
  FROM annual_salary
  WHERE employee_id=p_employee_id
  AND salary_year  =p_salary_year;
  SELECT tax_deduction
  INTO v_td
  FROM deduction
  WHERE employee_id=p_employee_id
  AND salary_year  =p_salary_year;
  v_ti            :=p_sum-v_te-v_td;
  IF v_ti         <=250000 THEN
    v_tp          :=0;
  ELSIF v_ti      <=500000 AND v_ti>=250001 THEN
    v_tp          :=0.1*(v_ti-250000);
  ELSIF v_ti      <=1000000 AND v_ti>=500001 THEN
    v_tp          :=0.2*(v_ti-500000)+25000;
  ELSIF v_ti      >=1000001 THEN
    v_tp          :=0.3*(v_ti-1000000)+125000;
  END IF;
  IF (p_sum             -v_te)>=10000000 THEN
    v_tds         :=1.15*v_tp;
  ELSE
    v_tds:=1.03*v_tp;
  END IF;
  RETURN v_tds;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
WHEN OTHERS THEN
  HTP.P(SQLCODE ||' '|| SQLERRM);
  RETURN NULL;
END;
/
GRANT EXECUTE ON salary_mgmt.get_tds TO PUBLIC;
show error;