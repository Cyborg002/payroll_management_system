--set define off;
--add not null constraint if possible
CONNECT salary_mgmt/dbase@XE;
---DROP SEQUENCE
DROP SEQUENCE employee_id_seq;
DROP SEQUENCE department_id_seq;
---DROP TABLE
DROP TABLE address;
DROP TABLE attendance;
DROP TABLE deduction;
DROP TABLE annual_salary;
ALTER TABLE department
DROP CONSTRAINT fk_emp;
DROP TABLE employee;
DROP TABLE department;
---SEQUENCE CREATION
CREATE SEQUENCE department_id_seq START WITH 101 INCREMENT BY 10 NOCACHE NOCYCLE MAXVALUE 1001;
CREATE SEQUENCE employee_id_seq START WITH 1001 INCREMENT BY 1 NOCACHE NOCYCLE MAXVALUE 99999;
  --- TABLE CREATION
  CREATE TABLE department
    (
      department_id     NUMBER(10) CONSTRAINT dept_pk PRIMARY KEY,
      department_name   VARCHAR2(100),
      creation_date     DATE DEFAULT sysdate,
      created_by        VARCHAR2(100) DEFAULT USER,
      last_updated_date DATE DEFAULT sysdate,
      last_updated_by   VARCHAR2(100) DEFAULT USER
    );
  CREATE TABLE employee
    (
      employee_id        NUMBER(10) CONSTRAINT emp_pk PRIMARY KEY,
      first_name         VARCHAR2(100),
      last_name          VARCHAR2(100),
      date_of_birth      DATE,
      employee_type      VARCHAR2(100),
      designation        VARCHAR2(100),
      email              VARCHAR2(100),
      contact_no         NUMBER(10),
      ESI_no             VARCHAR2(12),
      PAN                VARCHAR2(10),
      PF_no              VARCHAR2(18),
      PF_UAN_no          NUMBER(12),
      bank               VARCHAR2(20),
      bank_ac_no         NUMBER(16),
      service_start_date DATE,
      service_end_date   DATE,
      creation_date      DATE DEFAULT sysdate,
      created_by         VARCHAR2(100) DEFAULT USER,
      last_updated_date  DATE DEFAULT sysdate,
      last_updated_by    VARCHAR2(100) DEFAULT USER,
      department_id_1 CONSTRAINT fk_dept_1 REFERENCES department(department_id),
      department_id_2 CONSTRAINT fk_dept_2 REFERENCES department(department_id)
    );
  ALTER TABLE department ADD department_head_id CONSTRAINT fk_emp REFERENCES employee(employee_id);
  CREATE TABLE annual_salary
    (
      employee_id,
      basic                   NUMBER(10),
      hra                     NUMBER(10,2), --50% of basic
      conveyance              NUMBER(10,2), --Rs.1500*12 per year
      medical                 NUMBER(10,2), --15k per year
      lta                     NUMBER(10,2), --20k per year
      monthly_bonus           NUMBER(10,2), --20% of basic
      shift_allowance         NUMBER(10,2), --Rs.0
      additional_personal_pay NUMBER(10,2), --80% of basic
      leave_encashed          NUMBER(10) DEFAULT 0,
      salary_year             NUMBER(4) DEFAULT extract(YEAR FROM sysdate),
      creation_date           DATE DEFAULT sysdate,
      created_by              VARCHAR2(100) DEFAULT USER,
      last_updated_date       DATE DEFAULT sysdate,
      last_updated_by         VARCHAR2(100) DEFAULT USER,
      CONSTRAINT annual_pk PRIMARY KEY(employee_id,salary_year),
      CONSTRAINT fk_emp1 FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
    );
  CREATE TABLE deduction
    (
      employee_id,
      esi               NUMBER(10,2),
      epf               NUMBER(10,2),
      profession_tax    NUMBER(10,2) DEFAULT 2500,
      tax_exemption     NUMBER(10,2),
      tax_deduction     NUMBER(10,2) DEFAULT 0,
      tds               NUMBER(10,2),
      salary_year       NUMBER(4) DEFAULT extract(YEAR FROM sysdate),
      creation_date     DATE DEFAULT sysdate,
      created_by        VARCHAR2(100) DEFAULT USER,
      last_updated_date DATE DEFAULT sysdate,
      last_updated_by   VARCHAR2(100) DEFAULT USER,
      CONSTRAINT deduct_pk PRIMARY KEY(employee_id,salary_year),
      CONSTRAINT fk_sal1 FOREIGN KEY(employee_id,salary_year) REFERENCES annual_salary(employee_id,salary_year)
    );
  CREATE TABLE attendance
    (
      employee_id,
      DAY                     NUMBER(2) DEFAULT extract(DAY FROM sysdate),
      MONTH                   NUMBER(2) DEFAULT extract(MONTH FROM sysdate),
      YEAR                    NUMBER(4) DEFAULT extract(YEAR FROM sysdate),
      status                  VARCHAR2(10) NOT NULL,
      allotted_leaves         NUMBER(2) DEFAULT 25,
      allotted_unpaid_leaves  NUMBER(2) DEFAULT 15,
      allotted_paid_leaves    NUMBER(2) DEFAULT 10,
      remaining_unpaid_leaves NUMBER(2) DEFAULT 15,
      remaining_paid_leaves   NUMBER(2) DEFAULT 10,
      loss_of_pay             NUMBER(10,2) DEFAULT 0,
      leave_encashable        NUMBER(10),
      CONSTRAINT attend_pk PRIMARY KEY(employee_id,DAY,MONTH,YEAR),
      CONSTRAINT fk_emp2 FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
    );
  CREATE TABLE address
    (
      employee_id,
      address_1         VARCHAR2(100),
      address_2         VARCHAR2(100),
      address_3         VARCHAR2(100),
      city              VARCHAR2(100),
      pincode           NUMBER(6),
      state             VARCHAR2(100),
      country           VARCHAR2(100),
      address_type      VARCHAR2(100),
      creation_date     DATE DEFAULT sysdate,
      created_by        VARCHAR2(100) DEFAULT USER,
      last_updated_date DATE DEFAULT sysdate,
      last_updated_by   VARCHAR2(100) DEFAULT USER,
      CONSTRAINT address_pk PRIMARY KEY(employee_id,address_type),
      CONSTRAINT fk_emp3 FOREIGN KEY(employee_id) REFERENCES employee(employee_id)
    );
  --Department table insertion
  INSERT
  INTO department
    (
      department_id,
      department_name,
      department_head_id
    )
    VALUES
    (
      department_id_seq.NEXTVAL,
      'Directors',
      NULL
    );
  INSERT
  INTO department
    (
      department_id,
      department_name,
      department_head_id
    )
    VALUES
    (
      department_id_seq.NEXTVAL,
      'Finance',
      NULL
    );
  INSERT
  INTO department
    (
      department_id,
      department_name,
      department_head_id
    )
    VALUES
    (
      department_id_seq.NEXTVAL,
      'Human Resources',
      NULL
    );
  INSERT
  INTO department
    (
      department_id,
      department_name,
      department_head_id
    )
    VALUES
    (
      department_id_seq.NEXTVAL,
      'Technical',
      NULL
    );
  INSERT
  INTO department
    (
      department_id,
      department_name,
      department_head_id
    )
    VALUES
    (
      department_id_seq.NEXTVAL,
      'Marketting',
      NULL
    );
  --employee table insertion
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Cyrus',
      'Mistry',
      '04-JUL-68',
      'permanent',
      'CHAIRMAN',
      'cyrusmistry@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      '01-MAR-93',
      '04-JUL-28',
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Natarajan',
      'Chandrasekaran',
      '14-JUN-65',
      'permanent',
      'CEO',
      'nc@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      '11-APR-94',
      '14-JUN-25',
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Aarthi',
      'Subramanian',
      '24-APR-62',
      'permanent',
      'Non-Independent Director',
      'as@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      '04-JUL-2028',
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Aman',
      'Mehta',
      '04-SEP-68',
      'permanent',
      'Independent Director',
      'am@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      add_months(TRUNC(sysdate),60),
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Venkatraman',
      'Thyagarajan',
      '14-NOV-62',
      'permanent',
      'Independent Director',
      'vt@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      add_months(TRUNC(sysdate),60),
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Prof. Clayton M',
      'Christensen',
      '07-JUL-70',
      'permanent',
      'Independent Director',
      'pcmc@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      add_months(TRUNC(sysdate),60),
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Dr. Ron',
      'Sommer',
      '23-MAR-72',
      'permanent',
      'Independent Director',
      'drs@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      add_months(TRUNC(sysdate),60),
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Dr. Vijay',
      'Kelkar',
      '17-JAN-73',
      'permanent',
      'Independent Director',
      'dvk@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      add_months(TRUNC(sysdate),60),
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Ishaat',
      'Hussain',
      '04-DEC-69',
      'permanent',
      'Non-Independent Director',
      'ih@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      '04-DEC-29',
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'O.P.',
      'Bhatt',
      '07-MAY-71',
      'permanent',
      'Independent Director',
      'opb@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      TRUNC(sysdate),
      add_months(TRUNC(sysdate),60),
      101,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Rajesh',
      'Gopinathan',
      '05-FEB-74',
      'permanent',
      'CFO and Director',
      'rg@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      '05-FEB-34',
      '04-JUL-28',
      111,101
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Ajoyendra',
      'Mukherjee',
      '12-JUL-66',
      'permanent',
      'COO',
      'ajm@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      '01-JUN-93',
      '12-JUL-26',
      121,121
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'K Ananth',
      'Krishnan',
      '09-AUG-65',
      'permanent',
      'CTO',
      'kak@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      '01-OCT-94',
      '09-AUG-25',
      131,131
    );
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
      esi_no,
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
      employee_id_seq.NEXTVAL,
      'Raja',
      'Banerji',
      '11-JUL-66',
      'permanent',
      'CMO',
      'rb@tcs.com',
      '9425371289',
      'Not Eligible',
      'BFFPM0532J',
      'MP/CYR/34223/76232',
      '100286405598',
      'SBI',
      '0742001684975213',
      '11-NOV-92',
      '11-JUL-26',
      141,141
    );
  --department_head_id insertion
  UPDATE department
  SET department_head_id=1001
  WHERE department_id   =101;
  UPDATE department SET department_head_id=1011 WHERE department_id=111;
  UPDATE department SET department_head_id=1012 WHERE department_id=121;
  UPDATE department SET department_head_id=1013 WHERE department_id=131;
  UPDATE department SET department_head_id=1014 WHERE department_id=141;
  --annual_salary table insertion
  INSERT
  INTO annual_salary
    (
      employee_id,
      basic
    )
    VALUES
    (
      1001,400000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1002,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1003,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1004,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1005,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1006,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1007,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1008,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1009,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1010,320000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1011,240000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1012,240000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1013,240000*12
    );
  INSERT INTO annual_salary
    ( employee_id, basic
    ) VALUES
    ( 1014,240000*12
    );
  UPDATE annual_salary
  SET hra                  =0.5*basic,
    conveyance             =1600,
    medical                =15000,
    lta                    =18000,
    monthly_bonus          =0.2*basic,
    shift_allowance        =0,
    additional_personal_pay=0.8*basic
  WHERE employee_id        <1015;
  --deduction table insertion
  INSERT
  INTO deduction
    (
      employee_id
    )
    VALUES
    (
      1001
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1002
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1003
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1004
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1005
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1006
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1007
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1008
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1009
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1010
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1011
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1012
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1013
    );
  INSERT INTO deduction
    ( employee_id
    ) VALUES
    ( 1014
    );
  --attendance table insertion
  INSERT
  INTO attendance
    (
      employee_id,
      status
    )
    VALUES
    (
      1001,
      'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1002,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1003,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1004,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1005,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1006,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1007,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1008,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1009,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1010,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1011,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1012,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1013,'PRESENT'
    );
  INSERT INTO attendance
    ( employee_id, status
    ) VALUES
    ( 1014,'PRESENT'
    );
COMMIT;