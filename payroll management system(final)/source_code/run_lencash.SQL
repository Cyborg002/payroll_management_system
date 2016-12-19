CONNECT salary_mgmt/dbase@xe
CREATE OR REPLACE PROCEDURE run_lencash
-- http://127.0.0.1:8080/apex/salary_mgmt.run_lencash
AS
BEGIN
page_formatting('BEFORE');
	HTP.HTMLOPEN;
		HTP.HEADOPEN;
			HTP.TITLE('PAYROLL MANAGER');
		HTP.HEADCLOSE;
		HTP.BODYOPEN;
			HTP.FORMOPEN ('http://127.0.0.1:8080/apex/salary_mgmt.enter_and_maintain.enter_and_maintain_lencash', 'POST');
					HTP.TABLEOPEN;
					HTP.TABLEROWOPEN; 
						HTP.TABLEDATA ('EMPLOYEE ID'); 
						HTP.TABLEDATA (HTF.FORMTEXT('p_employee_id',NULL,NULL,NULL)); 
					HTP.TABLEROWCLOSE;
					HTP.TABLEROWOPEN; 
						HTP.TABLEDATA (HTF.FORMSUBMIT(CVALUE=>'Save')); 
						HTP.TABLEDATA (HTF.FORMRESET); 
					HTP.TABLEROWCLOSE; 
				HTP.TABLECLOSE; 
			HTP.FORMCLOSE; 
		HTP.BODYCLOSE;
	HTP.HTMLCLOSE;	
page_formatting('AFTER');
END run_lencash;
/
GRANT EXECUTE ON salary_mgmt.run_lencash TO PUBLIC;
SHOW ERROR;
