create table facultati
(
codfac varchar2(5),
denfac varchar2(80) not null,
constraint pk_fac primary key(codfac)
);

create table catedre
(
codcat varchar2(7),
dencat varchar2(50) not null,
codfac varchar2(5),
constraint pk_cat primary key(codcat),
constraint fk_fac foreign key(codfac) references facultati(codfac)
);

create table persoane
(
codp number(3),
nume varchar2(30),
functia varchar2(5),
dataang date,
codcat varchar2(7),
salariu number(4),
constraint pk_pers primary key(codp),
constraint fk_cat foreign key(codcat) references catedre(codcat),
constraint ck_functia check(functia in('Prof','Conf','Lect','Asist','Prep'))
);
insert into facultati values ('CSIE','Cibernetica, Statistica si Informatica Economica');
insert into facultati values ('CIG','Contabilitate si Informatica de Gestiune');
insert into facultati values ('COM','Comert');

insert into catedre values ('IE','Informatica Economica','CSIE');
insert into catedre values ('CIB','Cibernetica Economica','CSIE');
insert into catedre values ('EM','Economie Matematica','CSIE');
insert into catedre values ('STAT','Statistica si Previziune Economica','CSIE');

insert into persoane values ('1','Ionescu','Prof',to_date('12-nov-1994','dd-mon-yyyy'),'IE','2200');
insert into persoane values ('2','Popescu','Prof',null,'CIB','2000');
insert into persoane values ('3','Georgescu','Asist',to_date('23-apr-2002','dd-mon-yyyy'),'IE','1000');
insert into persoane values ('4','Stanescu','Conf',to_date('10-oct-2001','dd-mon-yyyy'),'EM','1400');
insert into persoane values ('5','Tudor','Lect',null,'IE','1500');
insert into persoane values ('6','Zaharia','Prep',to_date('04-feb-2005','dd-mon-yyyy'),'EM','900');
commit;


--3
set serveroutput on;
DECLARE
    v_cod persoane%ROWTYPE;

BEGIN
    select *into v_cod from Persoane where codp = 4;

EXCEPTION
    when NO_DATA_FOUND then
    DBMS_OUTPUT.put_line('Nu exista angajatul');

end;
/

--4.
DECLARE
    my_ex EXCEPTION;
    nr_ang number(3) := 0;
    cod_cat varchar2(10) := '&CODUL';
    
    CURSOR angj_cursor(id_v varchar2) IS 
            SELECT codp from persoane where codcat = id_v;
BEGIN
    FOR iterator IN angj_cursor(cod_cat) LOOP
        nr_ang := nr_ang + 1;
        end loop;     
        
        
        if nr_ang = 0 then
            RAISE my_ex;
        else
        dbms_output.put_line('Nr de angajati: ' || nr_ang);  
    end if;

EXCEPTION
    when my_ex then
    dbms_output.put_line('nu exista angajati');
    
end;
/

--6
DECLARE
    my_ex EXCEPTION;
    nr_modif number := 0;
    CURSOR persoane_cursor IS 
            SELECT salariu, codp from Persoane;
BEGIN
    FOR iterator IN persoane_cursor LOOP
        if iterator.salariu < 1500 then
            
            update Persoane
                set salariu = salariu * 1.2
                    where codp = iterator.codp;
            
            
            nr_modif := nr_modif + 1;
        end if;
    end loop;
    
        if nr_modif = 0 then
            RAISE my_ex;
        else
            dbms_output.put_line('Modificari facute: ' || nr_modif);
        end if;
EXCEPTION
    when my_ex then
        dbms_output.put_line('Nu s-au facut modificari');
end;
/


--7
DECLARE
    v_nume persoane.nume%type;
    v_functie persoane.functia%type;
    v_cod persoane.codcat%type := '&codcat';

BEGIN
    select nume, functia INTO v_nume, v_functie
        FROM Persoane
            where codcat = v_cod;
        
    dbms_output.put_line(v_nume || v_functie || v_cod);
end;
/

--8
DECLARE
    CURSOR persoane_cursor IS
        SELECT codp, salariu, nume, functia from Persoane ORDER BY salariu DESC;
    
    stop_p number := 0;

BEGIN
    
        FOR iterator IN persoane_cursor LOOP
            if stop_p  < 4 then
            dbms_output.put_line(iterator.nume || ' ' || iterator.salariu);
            stop_p := stop_p + 1;
        end if;
     end loop;
end;
/

--10
DECLARE
    CURSOR catedre_cursor IS
        SELECT dencat, codcat, codfac FROM Catedre;
    
    CURSOR persoane_cursor(id_cat varchar2) IS
        SELECT nume, functia, salariu FROM Persoane
                where codcat = id_cat;

BEGIN
    FOR i IN catedre_cursor LOOP
      dbms_output.put_line('Denumirea catedra: ' || i.dencat);
        FOR j IN persoane_cursor(i.codcat) LOOP
         dbms_output.put_line(chr(9) || j.nume || j.functia || j.salariu);
    end loop;
end loop;

END;
/


--9
select c.dencat, count(p.codp)
from Catedre c, Persoane p
where c.codcat = p.codcat AND upper(c.dencat) <>(upper('Informatica Economica'))
group by c.dencat;

DECLARE
    CURSOR catedre_cursor IS
        SELECT dencat, codcat from Catedre
            where upper(dencat) <>(upper('Informatica Economica'));
    
    CURSOR persoane_cursor(id_cat varchar2) IS
        SELECT nume, functia FROM Persoane
           where codcat = id_cat;
    
    nr_ang number := 0;
        
BEGIN
    FOR i IN catedre_cursor LOOP
      nr_ang := 0;
      dbms_output.put_line('Den cat:' || i.dencat);
        FOR j IN persoane_cursor(i.codcat) LOOP  
            nr_ang := nr_ang + 1;
        end loop;
                if nr_ang < 1 then                
                    dbms_output.put_line(chr(9) ||'Nu are mai mult de 1 angj');
               end if;
           
       end loop;
end;
/

-- TEMAAAA!!!!!!!
--folosind un cursor explicit sa se parcurga toti angajatii
--in corupul blocului, zona ex sa se verifice
-- daca salariul angajatului (fiecarui angajat parcurs) este mai mare decat salariul mediu pe firma
--atunci micsoram salariul = salariul / 2
--moficarea pe baza de date!!!!!!!!!
--altfel afisati date despre angajat


