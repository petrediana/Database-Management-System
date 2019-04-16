set serveroutput on;


--trigger care se declanseaza inainte de modificarea salariului pe tabela angajati
CREATE OR REPLACE TRIGGER test_trigger
BEFORE UPDATE OF salariul ON Angajati
FOR EACH ROW
BEGIN
    dbms_output.put_line(:old.salariul || ' ' || :new.salariul);
END;
/
--TRIGGER DECLANSAT O SINGURA DATA CAND NU AM CLAUZA FOR EACH ROW!!!
UPDATE Angajati
set salariul = 199
where id_departament = 80;

--nu se fac modificari, dar triggerul se declanseaza || CAND AM CLAUZA FOR EACH ROW NU MAI AFISEAZA OK
UPDATE Angajati
set salariul = 100
where id_departament = 500000;




-- Sa se construiasca un trigger care sa se declanseze la adaugarea unui angajat nou sau la modificarea salariului unui angajat existent si care
-- sa verifice daca noul salariu se incadreaza in limitele de salariu ale functiei detinute de angajat
-- in cazul in care nu e in interval de declanseaza o exceptie


CREATE OR REPLACE TRIGGER trigger2
BEFORE INSERT  OR UPDATE OF salariul ON Angajati
FOR EACH ROW
DECLARE
    get_salmin number;
    get_salmax number;
    ex EXCEPTION;

BEGIN
    select salariu_min, salariu_max into get_salmin, get_salmax FROM Functii
            where id_functie = :new.id_functie;
            
    dbms_output.put_line(:old.salariul || ' ' || :new.salariul);
    
    if :new.salariul > get_salmax OR :new.salariul < get_salmin then
        RAISE ex;
    else
        dbms_output.put_line('OK');
end if;
EXCEPTION
    when ex then
    RAISE_APPLICATION_ERROR(-20001, 'Nu se poate');
END;
/

UPDATE Angajati
set salariul = 29000
where id_angajat = 100;

-- Sa se creeze un trigger care sa se declanseze atunci cand se incearca modificarea salariului angajatilor.
-- Daca vechimea angajatilor pentru care se incearca marirea este mai mare de 20 ani atunci nu se va permite cresterea

CREATE OR REPLACE TRIGGER trigger3
BEFORE UPDATE OF salariul ON Angajati
FOR EACH ROW
    DECLARE
        get_dataAng date;
        get_vechime number;
        NU Exception;
    BEGIN
        select data_angajare into get_dataAng from Angajati
            where id_angajat = :new.id_angajat;
            
            if :new.salariul < :old.salariul then
                RAISE NU;
        end if;
            
            --get_vechime := (extrat(year from sysdate) - extract(year from get_dataAng));
            get_vechime := ROUND((sysdate - get_dataAng) / 365);
            
            if  get_vechime < 20 then
                 dbms_output.put_line(:old.salariul || ' ' || :new.salariul);
                else
                    RAISE NU;
end if;

EXCEPTION
    when NU then
    RAISE_APPLICATION_ERROR(-20001, 'Nu se poate...');
END;
/
    
    
    
--MINIM 5 TRIGGERI PE BAZA DE DATE

























    