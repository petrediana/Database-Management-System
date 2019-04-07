set serveroutput on;


--Utilizare cursor implicit
--1. Sa se mareasca cu 5 unitati monetare salariul angajatului al carui id este preluat de la tastatura
DECLARE
    marca number(3) := '&marca';

BEGIN
    update Angajati
    set salariul = salariul + 5 
        where marca_angajat = marca;
    
    IF SQL%NOTFOUND THEN
        dbms_output.put_line('Nu exista angajatul cu id-ul introdus!');
    else
       dbms_output.put_line('Actualizare reusita, s-a modificat salariul a: ' || SQL%ROWCOUNT || ' angajati');
       dbms_output.put_line('S-a modificat salariul angajatului cu id-ul: ' || marca);
end if;
end;
/

--2. Sa se actualizeze numele de scena a unui artist. Atat id-ul cat si numele se vor citi de la tastatura
DECLARE
    ar_id number(3) := '&ID';
    porecla varchar2(40) := '&PORECLA';
    
BEGIN
    update Artisti
    set nume_de_scena = porecla
        where id_artist = ar_id;
        
    IF SQL%FOUND THEN
        dbms_output.put_line('Adaugare de porecla cu succes!');
    END IF;

    IF SQL%NOTFOUND THEN
        dbms_output.put_line('Nu s-a putut realiza actualizarea!');
    END IF; 

    IF SQL%ROWCOUNT >0 THEN
        dbms_output.put_line(SQL%ROWCOUNT||' coloane modificate');
    ELSE
        dbms_output.put_line('Nu s-a modificat nici o coloana');
    
    END IF;
END;
/


--Utilizare cursor explicit
--1. Sa se afiseze detalii despre toti angajatii
DECLARE
    CURSOR angajati_cursor IS 
                select marca_angajat as id, nume || ' ' || prenume as nume_c, data_angajare FROM Angajati;
BEGIN
    FOR it_ang IN angajati_cursor LOOP
        dbms_output.put_line('Marca: ' || it_ang.id || '| Numele: ' ||  it_ang.nume_c || '| Data de angajare: ' ||  it_ang.data_angajare);
    end loop;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista angajati!');
END;
/


--2. Sa se afiseze denumirea zonelor cu angajatii aferenti fiecarei zone
DECLARE
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
END;
/


--3. Sa se afiseze angajatii cu specializarea lor si instrumentele studiate
select ang.nume, ap.specializare, ap.instrumente
from Legaturi l, Aptitudini ap, Angajati ang
where l.marca_angajat = ang.marca_angajat and l.id_aptitudine = ap.id_aptitudine;

DECLARE
    CURSOR legaturi_cursor IS 
            select id_legatura, marca_angajat, id_aptitudine FROM Legaturi;
    CURSOR apt_cursor(id_ap NUMBER) IS
            select specializare, instrumente FROM Aptitudini where id_aptitudine = id_ap;
    CURSOR ang_cursor(id_ang NUMBER) IS
            select nume || ' ' || prenume as nume_c from Angajati where marca_angajat = id_ang;
BEGIN
    FOR it_leg IN legaturi_cursor LOOP
        FOR it_apt IN apt_cursor(it_leg.id_aptitudine) LOOP
            FOR it_ang IN ang_cursor(it_leg.marca_angajat) LOOP
            dbms_output.put_line('Denumire specializare: ' || it_apt.specializare || ' Numele angajatului: ' || it_ang.nume_c || ' Instrumentul: ' || it_apt.instrumente);
    end loop;
    end loop;
    end loop;
END;
/


--4. Sa se afiseze cati artisti exista in baza de date
DECLARE
    counting NUMBER := 0;
    CURSOR artist_cursor IS
                select id_artist from Artisti;
                
BEGIN
    FOR it IN artist_cursor LOOP
        counting := counting + 1;
    end loop;
    
    dbms_output.put_line('In baza de date sunt: ' || counting  || ' artisti');    
END;
/

