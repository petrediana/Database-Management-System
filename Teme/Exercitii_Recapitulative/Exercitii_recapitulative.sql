set serveroutput on;
--1
CREATE OR REPLACE PROCEDURE afiseaza_angajati AS
	CURSOR angajati_cursor IS
		select nume, id_functie, data_angajare from Angajati;
    
    get_denumire_functie functii.denumire_functie%type;
BEGIN
	FOR iterator IN angajati_cursor LOOP
		IF TO_CHAR(iterator.data_angajare, 'DD-MONTH-YYYY') > '01-AUG-19998' then
            select denumire_functie into get_denumire_functie from Functii
                where id_functie = iterator.id_functie;
			dbms_output.put_line('Nume: ' || iterator.nume || ' ,data ang: ' || iterator.data_angajare || ', functia: ' || get_denumire_functie);
	end if;
end loop;
EXCEPTION
	when NO_DATA_FOUND then
		dbms_output.put_line('Nu exista date');
END;
/

execute afiseaza_angajati;


--2
CREATE OR REPLACE FUNCTION vechime_angajat(p_cod angajati.id_angajat%type) RETURN number AS
    vechime_ang number(4);
    data_ang date;
    get_nume varchar2(40);
BEGIN
    select data_angajare, nume || ' ' || prenume into data_ang, get_nume from Angajati
        where id_angajat = p_cod;
    
    dbms_output.put_line('Nume angajat cautat: ' || get_nume);
    vechime_ang := ROUND(MONTHS_BETWEEN(sysdate, data_ang) / 12);
    RETURN vechime_ang;

EXCEPTION
    when NO_DATA_FOUND then
        dbms_output.put_line('Nu exista angajatul cu acest id!');
        RETURN 0;
    when OTHERS then
        dbms_output.put_line('Alta exceptie');
END;
/

DECLARE
    id_cautat number := '&ID_ANGAJAT';
BEGIN
    dbms_output.put_line('Angajatul cu id-ul: ' || id_cautat || ', are vechimea: ' ||
        vechime_angajat(id_cautat));
END;
/
    
--3
CREATE OR REPLACE PROCEDURE vechime_angajat_proc(p_cod IN angajati.id_angajat%type,
                                                p_vechime OUT number) AS

    OK number := 0;
    CURSOR angajati_cursor(v_id number) IS
        select nume || ' ' || prenume as nume_complet, data_angajare, id_angajat
            from Angajati where id_angajat = v_id;
BEGIN
    FOR iterator IN angajati_cursor(p_cod) LOOP
        OK := iterator.id_angajat;
        dbms_output.put_line('Id angajat: ' || OK || ', nume complet: ' || iterator.nume_complet);
        p_vechime := ROUND(MONTHS_BETWEEN(sysdate, iterator.data_angajare) / 12);
end loop;
EXCEPTION
    when NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista angajatul cu id-ul: !' || p_cod);
        p_vechime := -1;
END;
/

DECLARE
    id_citit angajati.id_angajat%type := 100;
    vechime number;
BEGIN
   vechime_angajat_proc(id_citit , vechime);
    dbms_output.put_line('Vechime: ' || vechime);
END;
/

--4
CREATE OR REPLACE PROCEDURE vechime_angajat_proc2 AS
    
    CURSOR angajati_cursor IS
        select nume || ' ' || prenume as nume_c, id_angajat, data_angajare 
            from Angajati;
    vechime number;
BEGIN
    FOR iterator IN angajati_cursor LOOP
        dbms_output.put_line('Id angajat: ' || iterator.id_angajat || ', Nume complet '
                || iterator.nume_c);
        vechime := ROUND(MONTHS_BETWEEN(sysdate, iterator.data_angajare) / 12);
        dbms_output.put_line('Are vechimea: ' || vechime);
end loop;
EXCEPTION
    when NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista angajati in baza de date!');
    when OTHERS THEN
        dbms_output.put_line('Alta exceptie!');
END;
/

execute vechime_angajat_proc2;

--5
 select MAX(data) from Comenzi;    
CREATE OR REPLACE PROCEDURE info_comanda_recenta(p_data OUT comenzi.data%type, 
                            p_valoare OUT number) AS
    
    CURSOR comanda_cursor IS
        select data, nr_comanda from Comenzi;
        
    CURSOR rand_comenzi_cursor (v_id number) IS
        select pret, cantitate from Rand_comenzi 
            where nr_comanda = v_id;
    max_id number;
    max_date comenzi.data%type;
BEGIN
    Select MAX(data) INTO max_date from Comenzi;
    dbms_output.put_line('Data cea mai recenta: ' || max_date);
    p_data := max_date; 
    p_valoare := 0;
    
    FOR iterator_comenzi IN comanda_cursor LOOP
        if iterator_comenzi.data = max_date then
            FOR iterator_rand_comenzi IN rand_comenzi_cursor(iterator_comenzi.nr_comanda) LOOP
                p_valoare :=  p_valoare + iterator_rand_comenzi.pret * iterator_rand_comenzi.cantitate;
                --dbms_output.put_line('Pret: ' || iterator_rand_comenzi.pret);
        end loop;
    end if;
end loop; 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista date in baza de date!');
    --WHEN OTHERS THEN
        --dbms_output.put_line('Alta exceptie!');
END;
/

DECLARE
    p_data comenzi.data%type;
    p_valoare number;
BEGIN
    info_comanda_recenta(p_data, p_valoare);
    dbms_output.put_line('Data cea mai recenta: ' || p_data || ', Valoarea: ' || p_valoare);
END;
/

commit;

--6
CREATE OR REPLACE TRIGGER cantitate_pozitiva
BEFORE INSERT OR UPDATE OF cantitate ON Rand_comenzi
FOR EACH ROW 
DECLARE
    exceptie EXCEPTION;
BEGIN
    if :new.cantitate < 0 then
        RAISE exceptie;
    else
        dbms_output.put_line('Inserare \ Update cu succes!');
end if;
EXCEPTION
    WHEN exceptie THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cantitatea introdusa nu poate fi negativa!');
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista comanda cu acest id!');
    WHEN OTHERS THEN
        dbms_output.put_line('Alta exceptie! Codul erorii: ' || SQLCODE);
END;
/

update Rand_comenzi
set cantitate = -1 where nr_comanda = 2398;


--7
--Pachetul cu semnaturiile subprogramelor
CREATE OR REPLACE PACKAGE Actualizare_functii IS

PROCEDURE Adauga_functie(v_id functii.id_functie%type, den_f functii.denumire_functie%type,
                            v_sal_min functii.salariu_min%type, v_sal_max functii.salariu_max%type);

PROCEDURE Modifica_functie(v_id functii.id_functie%type, denumire_noua functii.denumire_functie%type);

PROCEDURE Sterge_functie(v_id functii.id_functie%type);
END Actualizare_functii;


--Implementare subprograme
CREATE OR REPLACE PACKAGE BODY Actualizare_functii IS
--a)
PROCEDURE Adauga_functie(v_id functii.id_functie%type, den_f functii.denumire_functie%type,
                            v_sal_min functii.salariu_min%type, v_sal_max functii.salariu_max%type) AS

    CURSOR functii_cursor IS
        select id_functie from Functii;
    OK number := 0;
    exceptie EXCEPTION;
BEGIN
    FOR iterator IN functii_cursor LOOP
        if iterator.id_functie = v_id then
            OK := OK + 1;
    end if;
end loop;

    if OK > 0 then
        RAISE exceptie;
    else
        dbms_output.put_line('Se poate adauga o noua functie');
        INSERT INTO Functii(id_functie, denumire_functie, salariu_min, salariu_max)
        values(v_id, den_f, v_sal_min, v_sal_max);
end if;
EXCEPTION
    when exceptie THEN
        dbms_output.put_line('Exista deja o functie cu id-ul: ' || v_id);
    when OTHERS then
        dbms_output.put_line('Alta exceptie');
END;

--b)
PROCEDURE Modifica_functie(v_id functii.id_functie%type, denumire_noua functii.denumire_functie%type) AS
    
    OK number := 0;
    exceptie EXCEPTION;
    get_denumire functii.denumire_functie%type;
    CURSOR functii_cursor IS
        select id_functie, denumire_functie from Functii;
BEGIN
    FOR iterator IN functii_cursor LOOP
        if iterator.id_functie = v_id then
            OK := 1;
            get_denumire := iterator.denumire_functie;
    end if;
end loop;
    
    if OK = 0 then
        RAISE exceptie;
    else
        dbms_output.put_line('Modific numele functiei cu id-ul: ' || v_id || ', Numele
            INAINTE de modificare: ' || get_denumire);
        
        Update Functii
        set denumire_functie = denumire_noua
        where id_functie = v_id;
end if;
EXCEPTION
    when exceptie then
        dbms_output.put_line('Nu exista functia cu id-ul introdus!!!');
    when OTHERS then
        dbms_output.put_line('Alta exceptie!');
END;

--c)
PROCEDURE Sterge_functie(v_id functii.id_functie%type) AS
    CURSOR functii_cursor IS
        select id_functie, denumire_functie from Functii;
    OK number := 0;
    exceptie EXCEPTION;
BEGIN
    FOR iterator IN functii_cursor LOOP
        if iterator.id_functie = v_id then
            OK := 1;
            dbms_output.put_line('Se va sterge functia cu id-ul: ' ||
                v_id || ' avand denumirea: ' || iterator.denumire_functie);
    end if;
end loop;
    
    if OK  = 0 then
        RAISE exceptie;
    else
        DELETE FROM functii WHERE id_functie = v_id;
        dbms_output.put_line('Functie stearsa!');
end if;
EXCEPTION
    WHEN exceptie THEN
        dbms_output.put_line('Functia cu id-ul introdus nu exista!');
    WHEN OTHERS THEN
        dbms_output.put_line('Alta exceptie, codul ei: ' || SQLCODE);
END;

END Actualizare_functii;
/


--Execut punctul 7
execute Actualizare_functii.Adauga_functie(99999, 'AAAAAAA', 100, 200); --a)
   select * from Functii order by id_functie ASC;
   
execute Actualizare_functii.Modifica_functie(99999, 'Schimb numele'); --b)
    select * from Functii order by id_functie ASC;

execute Actualizare_functii.Sterge_functie(99999); --c)
    select * from Functii order by id_functie ASC;

    