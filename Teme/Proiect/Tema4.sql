--TEM? - Proiect SGBD, v.4
set serveroutput on;


--TRIGGERS

--1. Sa se creeze un trigger care se va declansa in momentul in care o noua aptitudine este adaugata. O aptitudine este corect introdusa daca instrumentul/instrumentele de specialitate sunt diferite
-- de celelalte deja existente!
CREATE OR REPLACE TRIGGER aptitudine_trigger
BEFORE INSERT OR UPDATE OF Instrumente on Aptitudini
FOR EACH ROW
DECLARE
    CURSOR instrumente_cursor IS 
        SELECT instrumente from Aptitudini;
    OK number(2) := 0;
    instrument_nou varchar2(40);
    
BEGIN
    instrument_nou := :new.instrumente;
    dbms_output.put_line(instrument_nou);

    FOR iterator_instrumente IN instrumente_cursor LOOP
        if upper(instrument_nou) = upper(iterator_instrumente.instrumente) then
               OK := OK + 1;
    end if;
end loop;

    if OK > 0 then
    RAISE_APPLICATION_ERROR(-20001, 'Specializarea cu aceste instrumente exista deja! Redundanta!!');
    else
        dbms_output.put_line('Inserare \ Update cu succes!');
end if;

END;
/
DROP TRIGGER aptitudine_trigger;

Update Aptitudini
set instrumente = 'Orga electronica' where id_aptitudine = 3;

Insert into Aptitudini (id_aptitudine, specializare, instrumente)
values(5, 'Mecanic', 'Tobe');

Delete from Aptitudini where id_aptitudine = 5;


-- 2. Sa se creeze un trigger care previne atribuirea unei zone inexistente unui angajat.
-- Zonele sunt numerotate incepand cu 1 pana la n (cate sunt) in ordine.
select count(id_zona) from Zone;

CREATE OR REPLACE TRIGGER verificaZona_trigger
BEFORE INSERT OR UPDATE OF id_zona ON Angajati
FOR EACH ROW
DECLARE
    nr_zone number(3) := 0;
    zona_noua number(3) := 0;
BEGIN
    select count(id_zona) into nr_zone from Zone;
    
    if nr_zone > 0 then
        dbms_output.put_line('Exista zonele 1 --- ' || nr_zone);
    else
        RAISE_APPLICATION_ERROR(-20001, 'Baza de date nu dispune de zone inserate!');
end if;
    
    zona_noua := :new.id_zona;
    dbms_output.put_line('Zona noua introdusa ' || zona_noua);
    
    if zona_noua > 0 AND zona_noua < nr_zone + 1 then
        dbms_output.put_line('Inserare \ Update cu succes!');
    else
        RAISE_APPLICATION_ERROR(-20002, 'Id-ul pentru zona introdusa este eronat!');
end if;
END;
/

Update Angajati
set id_zona = 3 where marca_angajat = 11;
    

--3. Sa se creeze un trigger care controleaza salariul unui angajat in functie de specializare
select ang.nume, ap.specializare
from Legaturi l, Aptitudini ap, Angajati ang
where l.marca_angajat = ang.marca_angajat and l.id_aptitudine = ap.id_aptitudine;


CREATE OR REPLACE TRIGGER salariul_trigger
BEFORE INSERT OR UPDATE OF salariul ON Angajati
FOR EACH ROW
DECLARE
pragma autonomous_transaction; -- mutatie, SUPER FOLOSITOR
     get_id_angajat number;
     
     get_id_legatura number;
     get_id_aptitudine number;
     get_denumire_specializare varchar2(30);
     
     get_salariu_curent number;
     get_nume_angajat varchar2(30) := 0;

BEGIN
    get_id_angajat := :new.marca_angajat;        
        select nume into get_nume_angajat from Angajati
            where marca_angajat = get_id_angajat; 
            
   dbms_output.put_line('Numele angajatului introdus: ' || get_nume_angajat || ' salariul curent: ' || :old.salariul || ' si marca de identificare: ' || get_id_angajat);  
      
    select id_legatura, id_aptitudine into get_id_legatura, get_id_aptitudine from Legaturi
        where marca_angajat = get_id_angajat;

    select specializare into get_denumire_specializare from Aptitudini
        where id_aptitudine = get_id_aptitudine;
    
    dbms_output.put_line('Specializarea angajatului: ' || get_denumire_specializare);
    
    if upper(get_denumire_specializare) = upper('Tehnic') OR upper(get_denumire_specializare) = upper('Cantaret') then
        dbms_output.put_line('Ramura cantaret / tehnic');
            if :new.salariul <  1500 OR :new.salariul > 3500 then
                RAISE_APPLICATION_ERROR(-20001, 'Tehnicianul / Canteretul trebuie sa aiba salariul in intervalul (1500, 3500)');
    end if;
end if;

    if upper(get_denumire_specializare) = upper('casier') then
        dbms_output.put_line('Ramura casier');
            if :new.salariul <  1000 OR :new.salariul > 2500 then
                RAISE_APPLICATION_ERROR(-20001, 'Tehnicianul / Canteretul trebuie sa aiba salariul in intervalul (1000, 2500)');
    end if;
end if;
  
END;
/

Update Angajati
set salariul = 10 where marca_angajat = 16;



-- PACHET
SELECT * FROM ALL_OBJECTS WHERE OBJECT_TYPE IN ('FUNCTION','PROCEDURE') AND OWNER = 'PETREI_46';


--PACKAGE CU PROCEDURI SI FUNCTII  
CREATE OR REPLACE PACKAGE pachetul_meu IS

procedure Public_date_angajat(id_angajat angajati.marca_angajat%TYPE); -- apelez in procedura continutul unei proceduri private
procedure Public_Zone_cu_angajati;

procedure Public_Afiseaza_Functia1; -- in procedura asta afisez rezultatul primei functii!
procedure Public_Afiseaza_Functia2; -- procedez similar pentru functia nr 2!
    
END pachetul_meu;
/


--CONSTRUIESC DECLARATIILE DIN PACKAGE
CREATE OR REPLACE PACKAGE BODY pachetul_meu IS

--1. Date despre un angajat cu id-ul introdus
procedure private_dateAng(id_angajat angajati.marca_angajat%TYPE) IS
    nume_complet varchar2(50);
    data_ang date;
    id_apt number;
    den_apt varchar2(50);

BEGIN
    select nume || ' ' || prenume, data_angajare into nume_complet, data_ang from Angajati
        where marca_angajat = id_angajat;
    
    select id_aptitudine into id_apt from Legaturi
        where marca_angajat = id_angajat;
    
    select specializare into den_apt from Aptitudini
        where id_aptitudine = id_apt;
    
    dbms_output.put_line('Nume angajat: ' || nume_complet || ' data de angajare: ' || data_ang || ' Are specializarea: ' || den_apt);

EXCEPTION
    when NO_DATA_FOUND then
        dbms_output.put_line ('Nu am date!');
    when OTHERS then
        dbms_output.put_line('Alta exceptie!');
END;

procedure Public_date_angajat(id_angajat angajati.marca_angajat%TYPE) IS
BEGIN
private_dateAng(id_angajat);
END;


--2. Afisez zonele cu fiecare angajat
procedure PRIVATE_zone_cu_ang IS
    CURSOR zone_cursor IS 
            select id_zona, denumire_zona FROM Zone;
    
    CURSOR angajati_cursor (id NUMBER) IS 
            select nume || ' ' || prenume as nume_c from Angajati where id_zona = id;

BEGIN
    FOR it_zona IN zone_cursor LOOP
        dbms_output.put_line('Denumirea zonei: ' || it_zona.denumire_zona || ' cu angajatii: ');
            FOR it_ang IN angajati_cursor(it_zona.id_zona) LOOP
                dbms_output.put_line( chr(9) || 'Numele complet: ' || it_ang.nume_c);
    end loop;
    end loop;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nu am date!!!');
    WHEN OTHERS THEN
        dbms_output.put_line('Alta Exceptie!');
END;

procedure Public_Zone_cu_angajati IS
BEGIN
    PRIVATE_zone_cu_ang;
END;    


-- 3. Functie care afiseaza numele artistilor care au scris un anumit album
FUNCTION get_NumeArtisti_album (v_denumire_album varchar2) RETURN varchar2
IS
    get_id_album number;
    
    string_toate_numele varchar2(200);
    string_nume varchar2(40);
    
    CURSOR contributii_cursor(v_id_album number) IS
        select id_artist from Contributii where id_album = v_id_album;
BEGIN
    select id_album into get_id_album from Albume
        where upper(denumire_album) = upper(v_denumire_album);
    dbms_output.put_line('Id album cautat: ' || get_id_album || ', Denumire Album: ' || v_denumire_album);
    
    FOR iterator IN contributii_cursor(get_id_album) LOOP
       -- dbms_output.put_line('Id Artisti: ' || iterator.id_artist);
        
        select nume || ' ' || prenume into string_nume from Artisti where id_artist = iterator.id_artist;
        string_toate_numele := string_toate_numele || string_nume || ', ';       
end loop;

    --dbms_output.put_line(string_toate_numele);
    RETURN string_toate_numele;

EXCEPTION
    when NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista date, cautati alt album!');
    when TOO_MANY_ROWS THEN
        dbms_output.put_line('Exista albume care intamplator au aceeasi denumire!');
    when OTHERS THEN
        dbms_output.put_line('Alta exceptie..');
    
END;

procedure Public_Afiseaza_Functia1 IS
    album varchar2(20) := 'Holy Hell';
    res varchar2(100);
BEGIN
    res := get_NumeArtisti_album(album);
    dbms_output.put_line('Nume complet artisti: ' || res);
END;

-- 4. Functie care returneaza daca un instrument exista in baza de date
FUNCTION private_exista_instrument(v_id_i instrumente.id_instrument%type) RETURN BOOLEAN
IS
    ok number(2) := 0;
    CURSOR instr_cursor(v_id number) IS
        select count(*) as total from Instrumente where id_instrument = v_id;
    nu_exista EXCEPTION;
BEGIN
    FOR iterator IN instr_cursor(v_id_i) loop
        ok := ok + iterator.total;
end loop;
    
    if ok = 0 then
        RAISE nu_exista;
    else
        RETURN TRUE;
end if;
EXCEPTION
    when nu_exista then
        return FALSE;
END;

procedure Public_Afiseaza_Functia2 IS
    v_id number := 100;
    rezultat boolean;
BEGIN
    rezultat := private_exista_instrument(100);
    dbms_output.put_line('Se cauta instrumentul cu id-ul: ' || v_id);
    if rezultat = true then
        dbms_output.put_line('Instrumentul exista');
    else
        dbms_output.put_line('Instrumentul nu exista');
    end if;
END;

END pachetul_meu;
/

-- Apel proceduri din pachet
    execute pachetul_meu.Public_date_angajat(10);
    execute pachetul_meu.Public_Zone_cu_angajati;
commit;
    
    
--Apelez cu ajutorul unei proceduri functiile pe care le-am creat in body-ul pachetului (functiile sunt private)
    execute pachetul_meu.Public_Afiseaza_Functia1;
     execute pachetul_meu.Public_Afiseaza_Functia2;

