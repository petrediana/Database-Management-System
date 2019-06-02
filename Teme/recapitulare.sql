set serveroutput on;

--3.
DECLARE
    persoana_rec PERSOANE%ROWTYPE;
BEGIN
    SELECT * INTO persoana_rec
        FROM PERSOANE
            WHERE Codp = 4;
    
    dbms_output.put_line(persoana_rec.nume || persoana_rec.salariu);
END;
/

--4.
DECLARE
    cod_catedra persoane.codcat%TYPE  := '&CODCAT';
    nr_ang number := 0;
BEGIN
    SELECT COUNT(CODP) INTO nr_ang FROM PERSOANE
        WHERE codcat = cod_catedra;
    
    dbms_output.put_line('Catedra: ' || cod_catedra || ' are: ' || nr_ang);
END;
/

--5.
DECLARE
    cod_catedra persoane.codcat%TYPE  := '&CODCAT';
    nr_ang number := 0;
    nu_exista_cod EXCEPTION;
BEGIN
    SELECT COUNT(CODP) INTO nr_ang FROM PERSOANE
        WHERE upper(codcat) = upper(cod_catedra);
    
    DBMS_OUTPUT.PUT_LINE('Codul introdus: ' || cod_catedra);
    
    IF nr_ang != 0 THEN
        dbms_output.put_line('Catedra: ' || cod_catedra || ' are: ' || nr_ang);
    ELSE
        RAISE nu_exista_cod;
    END IF;
EXCEPTION
    WHEN nu_exista_cod THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista codul catedrei introdus');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Alta exceptie: ' || SQLCODE);
END;
/

--6.
DECLARE
    CURSOR ang_cursor IS 
        SELECT salariu, nume, codp FROM Persoane;
    nr number := 0;
BEGIN
    FOR iterator IN ang_cursor LOOP
        IF iterator.salariu < 1500 THEN
            UPDATE Persoane
                SET salariu = salariu + salariu * 0.2
                    WHERE codp = iterator.codp;
            DBMS_OUTPUT.PUT_LINE('Nume ang cu salariu modificat: ' || iterator.nume);
            nr := nr + 1;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('S-au produs: ' || nr || ' modificari');
END;
/

--7.
DECLARE
    cod_catedra persoane.codcat%TYPE := '&CODCAT';
    nr number := 0;
    nu_am_ang EXCEPTION;
    CURSOR ang_cursor(id_c varchar2) IS
        SELECT nume, functia, codcat FROM Persoane
            WHERE upper(codcat) = upper(id_c);
BEGIN
    FOR iterator IN ang_cursor(cod_catedra) LOOP
        
            nr := nr + 1;
            DBMS_OUTPUT.PUT_LINE('Nume: ' || iterator.nume || ' functia: ' || iterator.functia);

    END LOOP;
    
    IF nr = 0 THEN
        RAISE nu_am_ang;
    END IF;
EXCEPTION
    WHEN nu_am_ang THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acel cod al catedrei');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Alta exceptie: ' || SQLCODE);
END;
/

--8.
DECLARE
    CURSOR ang_cursor IS
        SELECT nume, codp, salariu FROM Persoane
            ORDER BY salariu desc;
BEGIN
    FOR iterator IN ang_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(iterator.nume || ' ' || iterator.salariu || ' ' || iterator.codp);
    EXIT WHEN ang_cursor%ROWCOUNT = 4;
    END LOOP;
END;
/

--9.
DECLARE
    CURSOR cursor_frumos IS 
    (select c.dencat as dencat, count(p.codp) as nrang
        from Catedre c, Persoane p
            where c.codcat = p.codcat and c.codcat != 'IE'
        GROUP BY c.dencat
        HAVING count(p.codp) > 1);
BEGIN
    FOR iterator IN cursor_frumos LOOP
        dbms_output.put_line('Den cat: ' || iterator.dencat || ' nr ang: ' || iterator.nrang);
    END LOOP;
END;
/

--10
DECLARE
    CURSOR catedre_cursor IS 
        SELECT codcat, dencat from Catedre;
    
    CURSOR ang_cursor(coddcat catedre.codcat%TYPE) IS
        SELECT nume, functia, salariu from Persoane
            where upper(codcat) = upper(coddcat);
BEGIN
    FOR iterator_catedre IN catedre_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Denumire cat: ' || iterator_catedre.dencat);
            FOR iterator_ang IN ang_cursor(iterator_catedre.codcat) LOOP
                DBMS_OUTPUT.PUT_LINE('--- Nume: ' || iterator_ang.nume || ' functia: ' ||
                iterator_ang.functia);
            END LOOP;
    END LOOP;
END;
/

DECLARE
x NUMBER := &p_x;
y NUMBER := &p_y;
BEGIN
DBMS_OUTPUT.PUT_LINE(x/y);
EXCEPTION
WHEN ZERO_DIVIDE THEN
DBMS_OUTPUT.PUT_LINE('Impartire la 0!');
END;
/

SET SERVEROUTPUT ON
DECLARE
a NUMBER(10,2);
b NUMBER(2) DEFAULT 7;
c NUMBER(2) DEFAULT 5;
BEGIN
a:=GREATEST(B,C);
DBMS_OUTPUT.PUT_LINE('a=
'||a);
end;
/


BEGIN
NULL;
END;
/


--------------------------------------------------------------
--1.

--a
CREATE OR REPLACE PROCEDURE NEW_JOB (v_id_f functii.id_functie%TYPE,
    v_den_f functii.denumire_functie%TYPE, v_min_sal functii.salariu_min%TYPE) AS
    
    sal_max number := v_min_sal * 2;
     ok boolean := true;
    exceptie_functie EXCEPTION;
    CURSOR functii_cursor IS
        SELECT id_functie from FUNCTII;
BEGIN
    FOR iterator IN functii_cursor LOOP
        IF upper(iterator.id_functie) = upper(v_id_f) THEN
            ok := false;
        END IF;
    END LOOP;
    
    if ok = false THEN
        RAISE exceptie_functie;
    ELSE
        INSERT INTO FUNCTII(id_functie, denumire_functie, salariu_min, salariu_max)
            VALUES(v_id_f, v_den_f, v_min_sal, sal_max);
            DBMS_OUTPUT.PUT_LINE('Insert cu succes');
    END IF;
EXCEPTION
    WHEN exceptie_functie THEN
        DBMS_OUTPUT.PUT_LINE('Exista o functie cu acest id!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Alta exceptie!' || SQLCODE);
END;
/

--b
DECLARE
    id_f functii.id_functie%TYPE := 'SY_ANAL';
    den_f functii.denumire_functie%TYPE := 'System Analyst';
    sal_min functii.salariu_min%TYPE := 6000;
BEGIN
    NEW_JOB(id_f, den_f, sal_min);
    commit;
END;
/
--c
    SELECT * FROM FUNCTII
        WHERE id_functie = 'SY_ANAL';

--2.

--a
CREATE OR REPLACE PROCEDURE ADD_JOB_HIST(v_id_ang angajati.id_angajat%TYPE,
    id_f_nou angajati.id_functie%TYPE) AS
    
    data_curenta date := SYSDATE;
    get_data_inceput_ang date;
    get_id_f angajati.id_functie%TYPE;
    get_id_dep angajati.id_departament%TYPE;
    
    get_sal_min number := 0;

BEGIN
    SELECT data_angajare, id_functie, id_departament into 
    get_data_inceput_ang, get_id_f, get_id_dep FROM Angajati
        WHERE id_angajat = v_id_ang;
        
    SELECT salariu_min into get_sal_min from Functii
        where id_functie = id_f_nou;
    
    INSERT INTO istoric_functii (id_angajat, data_inceput, data_sfarsit, id_functie,
        id_departament)
        VALUES(v_id_ang, get_data_inceput_ang, data_curenta, get_id_f, get_id_dep);
        
    UPDATE Angajati
        SET id_functie = upper(id_f_nou), salariul = get_sal_min + 500,
        data_angajare = data_curenta
            where id_angajat = v_id_ang;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cu acest id!!' || v_id_ang);
END;
/

DECLARE
    id_f functii.id_functie%TYPE := 'SY_ANAL';
    id_ang number := 106;
BEGIN
    ADD_JOB_HIST(87897897, id_f);
END;
/

select * from Angajati
    where id_angajat = 106;

--3
CREATE OR REPLACE PROCEDURE UPD_JOBSAL(v_id_f functii.id_functie%TYPE,
    v_sal_min functii.salariu_min%TYPE, v_sal_max functii.salariu_max%TYPE) AS
    
    salariu_invalid EXCEPTION;

BEGIN
    IF v_sal_max < v_sal_min THEN
        RAISE salariu_invalid;
    ELSE
        UPDATE Functii
            SET salariu_min = v_sal_min, salariu_max = v_sal_max
                where id_functie = v_id_f;
        dbms_output.put_line(SQL%ROWCOUNT);
        IF SQL%ROWCOUNT = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista functia introdusa!!');
    WHEN salariu_invalid THEN
        DBMS_OUTPUT.PUT_LINE('Salariu maxim mai mic decat salariu minim!!');
END;
/

execute UPD_JOBSAL('SY_ANAL', 7000, 14);
execute UPD_JOBSAL('aaaaaaaaaaaa', 7000, 14000);
execute UPD_JOBSAL('SY_ANAL', 7000, 14000);
COMMIT;

select * from functii;

--4.
--a
ALTER TABLE Angajati
ADD EXCEED_AVGSAL varchar2(3);

update Angajati
SET EXCEED_AVGSAL = 'NO';


/*select a.id_angajat from Angajati a, Functii f
    where a.salariul > ((f.salariu_min + f.salariu_max) / 2)
    and a.id_functie = f.id_functie; */

CREATE OR REPLACE FUNCTION GET_JOB_AVGSAL( v_id_f functii.id_functie%TYPE)
    RETURN NUMBER AS
    
    avg_salariu number := 0;
BEGIN
    select ((salariu_min + salariu_max) / 2) into avg_salariu from Functii
        where id_functie = v_id_f;
    
    if SQL%ROWCOUNT = 0 then
        raise no_data_found;
    else
        return avg_salariu;
    end if;
    
EXCEPTION
    WHEN no_data_found then
        dbms_output.put_line('nu exista acest id');
        return -1;
END;
/

begin
    dbms_output.put_line(GET_JOB_AVGSAL('SY_ANAL'));
end;

CREATE OR REPLACE PROCEDURE CHECK_AVGSAL AS
    CURSOR ang_cursor IS
        SELECT id_angajat, salariul, id_functie from Angajati
            where salariul > GET_JOB_AVGSAL(id_functie) FOR UPDATE;
BEGIN
    FOR iterator IN ang_cursor LOOP
        UPDATE Angajati
            set EXCEED_AVGSAL = 'YES'
                where id_angajat = iterator.id_angajat;
    END LOOP;
END;
/

execute CHECK_AVGSAL;


--5
CREATE OR REPLACE FUNCTION GET_YEARS_SERVICE(v_id_ang angajati.id_angajat%TYPE)
    RETURN NUMBER AS
    
    get_data_ang angajati.data_angajare%TYPE;
    rezultat number := 0;

BEGIN
    SELECT data_angajare into get_data_ang from Angajati
        where id_angajat = v_id_ang;
    
    if sql%rowcount = 0 THEN
        RAISE no_data_found;
    else
        rezultat := extract(year from sysdate) - extract(year from get_data_ang);
        return rezultat;
    end if;
EXCEPTION
    when no_data_found then
        dbms_output.put_line('Nu exista angajatul cu acest id');
        RETURN -1;
END;
/

BEGIN
DBMS_OUTPUT.PUT_LINE(GET_YEARS_SERVICE(106));
END;


--6
CREATE OR REPLACE FUNCTION GET_JOB_COUNT (id_ang angajati.id_angajat%TYPE)
    RETURN NUMBER AS
    
    nr number := 0;
BEGIN
    select count(DISTINCT id_functie) into nr from istoric_functii
        where id_angajat = id_ang;
    
    if nr = 0 then
        raise no_data_found;
    else
        return nr;
    end if;
exception
    when no_data_found then
        dbms_output.put_line('nu exista ang cu acest id');
        return -1;
end;
/

BEGIN
DBMS_OUTPUT.PUT_LINE(GET_JOB_COUNT(176));
END;
   
    
    
    
    
    
    
    
    
    
    
    




