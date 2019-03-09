--1.Sa se afiseze numele si salariul tuturor angj
--TEMA: !! sa se rezolve ecuatia de gradul 2 in plsql -> pe online zona de incarcat

DECLARE
  CURSOR emp_cursor IS
  SELECT id_angajat, nume from angajati ORDER BY id_angajat;

BEGIN
  FOR empid IN emp_cursor loop
     DBMS_OUTPUT.PUT_LINE(empid.id_angajat || empid.nume);

  end LOOP;

END;
/

DECLARE
    iterator number(2);
    min_first number(3);
    max_last number(3);
    nume1 varchar2(30);
    sal number;
    exista number(4);
BEGIN
    select a.id_angajat into min_first from Angajati a, Angajati b
        where a.id_angajat < b.id_angajat AND rownum = 1;
    
    select max(id_angajat) into max_last from Angajati;
    
    FOR iterator IN min_first..max_last
    LOOP
            select count(*) into exista from Angajati where id_angajat = iterator;
        if exista > 0 then
        select nume, salariul into nume1, sal from Angajati where id_angajat = iterator;
        DBMS_OUTPUT.PUT_LINE(nume1 || ' ' || sal);
        end if;
    END LOOP;
    
    
    DBMS_OUTPUT.PUT_LINE(min_first);
    DBMS_OUTPUT.PUT_LINE(max_last);
END;
/

-- sa se afiseze angajatii care au o vechime mai mare de 10 ani

DECLARE
    iterator number(2);
    min_first number(3);
    max_last number(3);
    nume1 varchar2(30);
    sal number;
    exista number(4);
    vechime number(4);
BEGIN
    select a.id_angajat into min_first from Angajati a, Angajati b
        where a.id_angajat < b.id_angajat AND rownum = 1;
    
    select max(id_angajat) into max_last from Angajati;
    
    FOR iterator IN min_first..max_last
    LOOP
            select count(*) into exista from Angajati where id_angajat = iterator;
            select (extract(year from sysdate) - extract(year from data_angajare)) into vechime from Angajati
                        where (extract(year from sysdate) - extract(year from data_angajare)) > 10 and id_angajat = iterator;
                                
            
          if exista > 0 AND vechime > 10 then
        select nume, salariul into nume1, sal from Angajati where id_angajat = iterator;
        DBMS_OUTPUT.PUT_LINE(nume1 || ' ' || sal);
          end if;
    END LOOP;
    
    
    DBMS_OUTPUT.PUT_LINE(min_first);
    DBMS_OUTPUT.PUT_LINE(max_last);
END;
/


select (extract(year from data_angajare) - extract(year from sysdate))
from Angajati;

select extract(year from sysdate)
from dual