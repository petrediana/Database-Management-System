set serveroutput on;

--1.
CREATE OR REPLACE PROCEDURE add_job_procedure(job_id varchar2, job_name varchar2, min_salary number)
    AS
        max_salary number := 2 * min_salary;
        
        CURSOR functii_cursor IS
                select id_functie from FUNCTII;
        NUPOT EXCEPTION;
        ok number := 0;
        
BEGIN
    
    FOR iterator IN functii_cursor LOOP
        if iterator.id_functie = job_id then
                ok := ok + 1;
        end if;
end loop;
         
        if ok  > 0 then
            RAISE NUPOT;
         else 
     insert into Functii(id_functie, denumire_functie, salariu_min, salariu_max)
    values(job_id, job_name, min_salary, max_salary);
    dbms_output.put_line('Am inserat');
    
end if;

EXCEPTION
    when NUPOT then
    dbms_output.put_line('Am deja un job cu acel id!!!!');
END;
/

DECLARE
    job_id varchar2(20) := '&JOB_ID';
    job_name varchar2(30) := '&JOB_NAME';
    job_min_salary number(10) := '&JOB_MIN_SALARY';
BEGIN
    
    add_job_procedure(job_id, job_name, job_min_salary);
END;
/

--2.

CREATE OR REPLACE  PROCEDURE add_job_hist (emp_id number, job_id varchar2)
    AS
        get_functia_veche varchar(20);
        get_data_inceput date;
        get_salariu_min number(5);

BEGIN
    select id_functie, data_angajare into get_functia_veche, get_data_inceput from Angajati
        where id_angajat = emp_id;
    
    insert into ISTORIC_FUNCTII (id_angajat, data_inceput, data_sfarsit, id_functie)
    values(emp_id, get_data_inceput, sysdate, get_functia_veche);
    
    select salariu_min into get_salariu_min from Functii
        where id_functie = job_id;
    
    update Angajati
    set id_functie = upper(job_id)
    where id_angajat  = emp_id;
    
    update angajati
    set salariul = get_salariu_min + 500
    where id_angajat = emp_id;

EXCEPTION
    when NO_DATA_FOUND then
    dbms_output.put_line('Nu exista angajatul cu acel id!!');
END;
/

BEGIN
    add_job_hist(106, 'SY_ANAL');
END;
/
    
    
--3
CREATE OR REPLACE PROCEDURE upd_jobsal(job_id varchar2, new_min_sal number, new_max_sal number)
    AS
        salariuExceptie EXCEPTION;
BEGIN
    if new_min_sal > new_max_sal then
        RAISE salariuExceptie;
    else
        update Functii
        set salariu_min = new_min_sal
        where id_functie = job_id;
        
        update Functii
        set salariu_max = new_max_sal
        where id_functie = job_id;
end if;

EXCEPTION
    when salariuExceptie then
     dbms_output.put_line('Am salariul minim mai mare decat salariul maxim!!!');
END;
/

BEGIN
    upd_jobsal('SY_ANAL', 7000, 14000);
END;
/

select * from Functii;

--4

ALTER TABLE Angajati
ADD EXCEED_AVGSAL varchar2(3);

update Angajati
set EXCEED_AVGSAl = 'NO';

ALTER TABLE ANGAJATI
ADD constraint ck_exceed CHECK(EXCEED_AVGSAL = 'NO' OR EXCEED_AVGSAL = 'YES');


CREATE OR REPLACE PROCEDURE check_avgsal
    AS
        CURSOR angajati_cursor IS 
            Select id_angajat, salariul From Angajati;
        
        avg_salary number(9) := 0;
BEGIN
    
    select avg(salariul) into avg_salary from Angajati;
    
    FOR iterator IN angajati_cursor LOOP
        if iterator.salariu > avg_salary then
            update Angajati
            set EXCEED_AVGSAl = 'Yes';
    end if;
end loop;
END;
/

--5






    