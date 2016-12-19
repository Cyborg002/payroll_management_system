CONNECT salary_mgmt/dbase@XE;
CREATE OR REPLACE PACKAGE BODY report
AS
  PROCEDURE enter_and_maintain_department(
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
  PROCEDURE enter_and_maintain_employee(
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
  PROCEDURE enter_and_maintain_annual_sal(
      p_employee_id             IN NUMBER,
      p_basic                   IN NUMBER,
      p_hra                     IN NUMBER, --50% of basic
      p_conveyance              IN NUMBER, --Rs.1500*12 per year
      p_medical                 IN NUMBER, --15k per year
      p_lta                     IN NUMBER, --20k per year
      p_monthly_bonus           IN NUMBER, --20% of basic
      p_shift_allowance         IN NUMBER, --Rs.0
      p_additional_personal_pay IN NUMBER, --80% of basic
      p_salary_year             IN NUMBER,
      p_mode                    IN VARCHAR2)
  AS
    v_old_basic                   NUMBER(10);
    v_old_hra                     NUMBER(10,2); --50% of basic
    v_old_conveyance              NUMBER(10,2); --Rs.1500*12 per year
    v_old_medical                 NUMBER(10,2); --15k per year
    v_old_lta                     NUMBER(10,2); --20k per year
    v_old_monthly_bonus           NUMBER(10,2); --20% of basic
    v_old_shift_allowance         NUMBER(10,2); --Rs.0
    v_old_additional_personal_pay NUMBER(10,2); --80% of basic
    v_employee_count              NUMBER(10);   --need to use count for all foreign keys to check integrity constraint
    v_status                      NUMBER(10);
  BEGIN
    page_formatting('BEFORE');
    v_status :=0;
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
        INTO annual_salary
          (
            employee_id,
            basic,
            hra,
            conveyance,
            medical,
            lta,
            monthly_bonus,
            shift_allowance,
            additional_personal_pay
          )
          VALUES
          (
            employee_id_seq.nextval,
            p_basic,
            p_hra,                    --50% of basic
            p_conveyance,             --Rs.1500*12 per year
            p_medical,                --15k per year
            p_lta,                    --20k per year
            p_monthly_bonus,          --20% of basic
            p_shift_allowance,        --Rs.0
            p_additional_personal_pay --80% of basic
          );
        HTP.P('Record added successfully');
      ELSIF lower(p_mode)='update' THEN
        SELECT basic,
          hra,
          conveyance,
          medical,
          lta,
          monthly_bonus,
          shift_allowance,
          additional_personal_pay
        INTO v_old_basic,
          v_old_hra,                    --50% of basic
          v_old_conveyance,             --Rs.1500*12 per year
          v_old_medical,                --15k per year
          v_old_lta,                    --20k per year
          v_old_monthly_bonus,          --20% of basic
          v_old_shift_allowance,        --Rs.0
          v_old_additional_personal_pay --80% of basic
        FROM annual_salary
        WHERE employee_id= p_employee_id
        AND salary_year  =p_salary_year;
        IF SQL%NOTFOUND --why to use it when exception block is present
          THEN
          HTP.P('invalid employee id and/or salary year');
        ELSE
          UPDATE annual_salary
          SET basic                =NVL(p_basic,v_old_basic),
            hra                    =NVL(p_hra,v_old_hra),
            conveyance             =NVL(p_conveyance,v_old_conveyance),
            medical                =NVL(p_medical,v_old_medical),
            lta                    =NVL(p_lta,v_old_lta),
            monthly_bonus          =NVL(p_monthly_bonus,v_old_monthly_bonus),
            shift_allowance        =NVL(p_shift_allowance,v_old_shift_allowance),
            additional_personal_pay=NVL(p_additional_personal_pay,v_old_additional_personal_pay)
          WHERE employee_id        = p_employee_id
          AND salary_year          =p_salary_year;
          enter_and_maintain_tax(p_employee_id,p_salary_year);
          HTP.P('Record Updated');
        END IF;
      ELSE
        HTP.P('invalid mode') ;
      END IF;
    ELSE
      HTP.P('no such employee is present as given in employee_id');
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
  PROCEDURE enter_and_maintain_deduction(
      p_employee_id   IN NUMBER,
      p_tax_deduction IN NUMBER,
      p_salary_year   IN NUMBER,
      p_mode          IN VARCHAR2)
  AS
    v_old_employee_id   NUMBER(10);
    v_old_tax_deduction NUMBER(10,2);
    v_old_salary_year   NUMBER(4);
    v_empsal_count      NUMBER(10); --need to use count for all foreign keys to check integrity constraint
    v_status            NUMBER(10);
  BEGIN
    page_formatting('BEFORE');
    v_status :=0;
    SELECT COUNT(*)
    INTO v_empsal_count
    FROM annual_salary
    WHERE employee_id =p_employee_id
    AND salary_year   =p_salary_year;
    IF v_empsal_count =1 THEN
      v_status       :=1;
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
        INTO v_old_tax_deduction
        FROM deduction
        WHERE employee_id= p_employee_id
        AND salary_year  =p_salary_year;
        IF SQL%NOTFOUND --why to use it when exception block is present
          THEN
          HTP.P('invalid employee id and/or salary year');
        ELSE
          UPDATE deduction
          SET tax_deduction =NVL(p_tax_deduction,v_old_tax_deduction)
          WHERE employee_id = p_employee_id
          AND salary_year   =p_salary_year;
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
  FUNCTION get_tds(
      p_employee_id IN NUMBER,
      p_salary_year IN NUMBER,
      p_sum         IN NUMBER)
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
  PROCEDURE enter_and_maintain_tax(
      p_employee_id IN NUMBER,
      p_salary_year IN NUMBER)
  AS
    v_basic        NUMBER(10);
    v_hra          NUMBER(10,2); --50% of basic
    v_conveyance   NUMBER(10,2); --Rs.1500*12 per year
    v_medical      NUMBER(10,2); --15k per year
    v_tds          NUMBER(10,2);
    v_sum          NUMBER(10,2);
    v_empsal_count NUMBER(10); --need to use count for all foreign keys to check integrity constraint
    v_status       NUMBER(10);
  BEGIN
    page_formatting('BEFORE');
    SELECT basic,
      hra,
      conveyance,
      medical
    INTO v_basic,
      v_hra,
      v_conveyance,
      v_medical
    FROM annual_salary
    WHERE employee_id=p_employee_id
    AND salary_year  =p_salary_year;
    SELECT basic+ hra+ conveyance+ medical+ lta+ monthly_bonus+ shift_allowance+ additional_personal_pay+leave_encashed
    INTO v_sum
    FROM annual_salary
    WHERE employee_id=p_employee_id
    AND salary_year  =p_salary_year;
    v_status        :=0;
    SELECT COUNT(*)
    INTO v_empsal_count
    FROM annual_salary
    WHERE employee_id =p_employee_id
    AND salary_year   =p_salary_year;
    IF v_empsal_count =1 THEN
      v_status       :=1;
    END IF;
    IF v_status =1 THEN
      IF v_sum <=15000*12 THEN
        UPDATE deduction
        SET esi          =0.0175*v_basic
        WHERE employee_id=p_employee_id
        AND salary_year  =p_salary_year;
      ELSE
        UPDATE deduction
        SET esi          =0
        WHERE employee_id=p_employee_id
        AND salary_year  =p_salary_year;
      END IF;
      UPDATE deduction
      SET epf          =0.12  *v_basic,
        tax_exemption  = v_hra+v_conveyance+v_medical,
        tds            =get_tds(p_employee_id,p_salary_year,v_sum)
      WHERE employee_id=p_employee_id
      AND salary_year  =p_salary_year;
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
  PROCEDURE enter_and_maintain_attendance(
      p_employee_id IN NUMBER,
      p_day         IN NUMBER,
      p_month       IN NUMBER,
      p_year        IN NUMBER,
      p_status      IN VARCHAR2,
      p_mode        IN VARCHAR2)
  AS
    v_old_status     VARCHAR2(10);
    v_employee_count NUMBER(10); --need to use count for all foreign keys to check integrity constraint
    v_status         NUMBER(10);
  BEGIN
    page_formatting('BEFORE');
    v_status :=0;
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
        AND DAY          =p_day
        AND MONTH        =p_month
        AND YEAR         =p_year;
        IF SQL%NOTFOUND --why to use it when exception block is present
          THEN
          HTP.P('invalid employee id and/or date');
        ELSE
          UPDATE attendance
          SET status       =NVL(p_status,v_old_status)
          WHERE employee_id= p_employee_id
          AND DAY          =p_day
          AND MONTH        =p_month
          AND YEAR         =p_year;
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
  PROCEDURE enter_and_maintain_leaves(
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
    SELECT SUM(remaining_paid_leaves)
    INTO v_previous_paid_leaves
    FROM attendance
    WHERE employee_id=p_employee_id
    AND YEAR BETWEEN extract(YEAR FROM v_service_start_date) AND (extract(YEAR FROM sysdate)-1)
    AND remaining_paid_leaves!=0;
    v_status                 :=0;
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
  PROCEDURE enter_and_maintain_lencash(
      p_employee_id IN NUMBER)
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
END;
/
GRANT EXECUTE ON salary_mgmt.enter_and_maintain TO PUBLIC;
SHOW ERROR;
