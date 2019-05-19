set serveroutput on;

CREATE OR REPLACE PACKAGE pac_pac
    AS
-- returneaza toti angajatii din departamentul furnizat ca parametru
  PROCEDURE afiseaza_ang_din_departament (p_dep IN departamente.id_departament%TYPE, p_rezultat IN OUT SYS_REFCURSOR);
  
 -- returneaza toate functiile detinute de un angajat furnizat ca parametru (din istoric_functii)
  PROCEDURE afiseaza_functii_anterioare (p_ang IN angajati.id_angajat%TYPE, p_rezultat IN OUT SYS_REFCURSOR);
  
-- modifica salariul unui angajat furnizat ca parametru
  PROCEDURE modifica_salariu_angajat (p_ang IN angajati.id_angajat%TYPE, p_salariu_nou IN angajati.salariul%TYPE);
  
-- modifica functia unui angajat furnizat ca parametru
    PROCEDURE modifica_functie_angajat (p_ang IN angajati.id_angajat%TYPE, p_functie_noua IN angajati.id_functie%TYPE,
                                        p_salariu_nou IN angajati.salariul%TYPE := NULL, p_dep_nou IN angajati.id_departament%TYPE := NULL);
  
END pac_pac;

CREATE OR REPLACE PACKAGE BODY pac_pac AS
    PROCEDURE afiseaza_ang_din_departament(p_dep IN departamente.id_departament%TYPE, p_rezultat IN OUT SYS_REFCURSOR) AS
        BEGIN            
            OPEN p_rezultat FOR
                SELECT id_angajat, nume from Angajati
                    WHERE id_departament = p_dep
                        ORDER BY id_angajat;
        EXCEPTION
            when NO_DATA_FOUND THEN
                dbms_output.put_line('Nu exista angajati id-ul de departament introdus!');
    END;
  
    PROCEDURE afiseaza_functii_anterioare (p_ang IN angajati.id_angajat%TYPE, p_rezultat IN OUT SYS_REFCURSOR) AS
        BEGIN
            OPEN p_rezultat FOR
                SELECT id_functie, denumire_functie FROM Functii
                    WHERE id_functie IN (SELECT id_functie FROM Istoric_functii WHERE id_angajat = p_ang)
                        ORDER BY id_functie;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('Nu exista date!!');
    END;
    
    PROCEDURE modifica_salariu_angajat (p_ang IN angajati.id_angajat%TYPE, p_salariu_nou IN angajati.salariul%TYPE) AS
        nu_exista_ang EXCEPTION;
        salariu_invalid EXCEPTION;
        OK NUMBER := 0;
        get_salariu_max NUMBER := 0;
        get_salariu_min NUMBER := 0;
        
        BEGIN
            SELECT COUNT(*) INTO OK FROM Angajati
                WHERE id_angajat = p_ang;
            SELECT salariu_max, salariu_min INTO get_salariu_max, get_salariu_min FROM Functii
                WHERE id_functie = (SELECT id_functie FROM Angajati where id_angajat = p_ang);
                
            IF OK > 0 THEN
                IF p_salariu_nou <= get_salariu_max AND p_salariu_nou >= get_salariu_min THEN
                    UPDATE Angajati
                    set salariul = p_salariu_nou 
                        WHERE id_angajat = p_ang;
                ELSE
                    RAISE salariu_invalid;
                END IF;                
            ELSE
                RAISE nu_exista_ang;
            END IF;
            
        EXCEPTION
            WHEN nu_exista_ang THEN
                dbms_output.put_line('Nu exista angajatul cu acel id!!');
            WHEN salariu_invalid THEN
                dbms_output.put_line('Nu pot sa modific salariul!! Incalc limita maxima sau minima!');
        END;
    
        PROCEDURE modifica_functie_angajat (p_ang IN angajati.id_angajat%TYPE, p_functie_noua IN angajati.id_functie%TYPE,
                                        p_salariu_nou IN angajati.salariul%TYPE := NULL, p_dep_nou IN angajati.id_departament%TYPE := NULL) AS
            get_data_angajare istoric_functii.data_inceput%TYPE;           
            data_sf DATE := SYSDATE;
            get_id_functie angajati.id_functie%TYPE;
            get_id_departament angajati.id_departament%TYPE;
            aceeasi_functie EXCEPTION;
            
            BEGIN
                SELECT data_angajare, id_functie, id_departament INTO get_data_angajare,
                    get_id_functie, get_id_departament FROM Angajati 
                        WHERE id_angajat = p_ang;
                
                IF get_id_functie = p_functie_noua THEN
                    RAISE aceeasi_functie;
                ELSE                
                    insert into istoric_functii(id_angajat, data_inceput, data_sfarsit, id_functie, id_departament)
                        VALUES(p_ang, get_data_angajare, data_sf, get_id_functie, get_id_departament);
                
                    UPDATE Angajati
                        SET id_functie = p_functie_noua, salariul = p_salariu_nou, id_departament = p_dep_nou
                            WHERE id_angajat = p_ang;
                END IF;
            EXCEPTION
                WHEN aceeasi_functie THEN
                    dbms_output.put_line('Angajatul are deja functia aceasta!! Nu am ce sa modific!');
                WHEN NO_DATA_FOUND THEN
                    dbms_output.put_line('Nu am date!');
            END;    
END pac_pac;
/

--Testez procedura nr 4
DECLARE
    id_f functii.id_functie%TYPE := 'AD_PRES';
    sal_nou NUMBER := 21500;
    dep_nou NUMBER := 100;
BEGIN
    pac_pac.modifica_functie_angajat(103, id_f, sal_nou, dep_nou);
END;
/

select id_angajat, id_functie, id_departament from Angajati where id_angajat = 103;
select * from Istoric_functii where id_angajat = 103;

--Testez procedura nr 3
DECLARE
    id_ang NUMBER := 100;
    get_salariu_vechi NUMBER;
    get_salariu_nou NUMBER;
BEGIN
    SELECT salariul INTO get_salariu_vechi FROM Angajati
        WHERE id_angajat = id_ang;
    dbms_output.put_line('Salariul vechi: ' || get_salariu_vechi);
    
    pac_pac.modifica_salariu_angajat(id_ang, 329999999);
    SELECT salariul INTO get_salariu_nou from Angajati where id_angajat = id_ang;
    dbms_output.put_line('Salariu nou: ' || get_salariu_nou);
END;
/

--Testez procedura nr 2
DECLARE
    functii_syscursor SYS_REFCURSOR;
    id_f functii.id_functie%TYPE;
    denumire_f functii.denumire_functie%TYPE;
BEGIN
    pac_pac.afiseaza_functii_anterioare(101, functii_syscursor);
    
    LOOP
        FETCH functii_syscursor
        INTO id_f, denumire_f;
        EXIT WHEN functii_syscursor%NOTFOUND;
        dbms_output.put_line('Id functie: ' || id_f || ' Denumire functie: ' || denumire_f);
    END LOOP;
        CLOSE functii_syscursor;
END;
/

--Testez prima procedura
DECLARE
    angajati_syscursor SYS_REFCURSOR;
    id_ang angajati.id_angajat%TYPE;
    nume_ang angajati.nume%TYPE;
BEGIN
    pac_pac.afiseaza_ang_din_departament(50, angajati_syscursor);
    
    LOOP
        FETCH angajati_syscursor
        INTO id_ang, nume_ang;
        EXIT WHEN angajati_syscursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || id_ang || ' Nume Angajat: ' || nume_ang);
    END LOOP;
    CLOSE angajati_syscursor;
END;
/