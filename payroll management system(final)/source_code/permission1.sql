conn SYSTEM/dbase@xe;
SET DEFINE OFF;
ALTER SESSION SET current_schema=apex_040000;
CREATE OR REPLACE FUNCTION wwv_flow_epg_include_mod_local(procedure_name IN VARCHAR2)
RETURN boolean
IS
BEGIN


	--    
	-- Administrator note: the procedure_name input parameter may be in the format:    
	--    
	--    procedure    
	--    schema.procedure    
	--    package.procedure    
	--    schema.package.procedure    
	--    
	-- If the expected input parameter is a procedure name only, the IN list code shown below    
	-- can be modified to itemize the expected procedure names. Otherwise you must parse the    
	-- procedure_name parameter and replace the simple code below with code that will evaluate    
	-- all of the cases listed above.    --    
	IF UPPER(procedure_name) IN ('HR.ERROR_HANDELLER'
				    )
	THEN	RETURN TRUE;	
	ELSE	RETURN TRUE;	
	END IF;
END wwv_flow_epg_include_mod_local;
/				