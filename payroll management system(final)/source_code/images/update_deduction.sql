CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE update_deduction(p_number IN NUMBER)
  AS
  v_number NUMBER(10):=1001;
BEGIN
  LOOP
    enter_and_maintain_tax(v_number,extract(YEAR FROM sysdate));
    get_tds(v_number,extract(YEAR FROM sysdate));
    EXIT
  WHEN v_number=1015;
  END LOOP;
COMMIT;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  HTP.P(SQLCODE||' '||SQLERRM);
WHEN TOO_MANY_ROWS THEN
  HTP.P(SQLCODE||' '||SQLERRM);
WHEN OTHERS THEN
  HTP.P(SQLCODE||' '||SQLERRM);
END;
/
GRANT EXECUTE ON salary_mgmt.update_deduction TO PUBLIC;
show error;