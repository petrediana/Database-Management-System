set serveroutput on;
--PROCEDURI
--1. Sa se construiasca o procedura care adauga un nou angajat in tabela angajati.
-- Data de angajare va fi ziua aferenta in care s-a facut inserarea
-- Momentan noul angajat nu va fi atribuit nici unei zone si nu va avea un salariu

CREATE OR REPLACE PROCEDURE add_angajat_procedure(marca number, cnp number, nume varchar2, prenume varchar2,
                            id_magazin number)
    AS
        CURSOR angajati_cursor IS
                select marca_angajat from Angajati;
        am_deja_angajat EXCEPTION;
        ok BOOLEAN := true;
BEGIN
    FOR iterator IN angajati_cursor LOOP
        if iterator.marca_angajat = marca then
            ok := false;
        end if;
    end loop;
    
    if ok = false then
        RAISE am_deja_angajat;
    else
        dbms_output.put_line('Inserare cu succes!');
        insert into Angajati(marca_angajat, cnp, nume, prenume, data_angajare, id_magazin)
        values(marca, cnp, nume, prenume, sysdate, id_magazin);
    end if;
EXCEPTION
    when am_deja_angajat then
     dbms_output.put_line('Am deja un angajat cu id-ul introdus!!');
END;
/

DECLARE
    id_ang number(10) := '&ID_ANGAJAT';
    cnp_ang number(15) := '&CNP_ANGAJAT';
    nume_ang varchar2(30) := '&NUMELE_DE_FAMILIE';
    prenume_ang varchar2(30):= '&PRENUMELE';
    id_mag number(10) := '&ID_MAGAZIN';
BEGIN
     add_angajat_procedure(id_ang, cnp_ang, nume_ang, prenume_ang, id_mag);
     commit;
END;
/


--2. Sa se construiasca o procedura care ii atribuie unui angajat nou o aptitudine
-- In functie de aptitudinea atribuita angajatul va lucra intr-o zona si va avea un salariu
-- Se considera un angajat nou acea persoana care nu are inca atribuit un salariul si o zona
CREATE OR REPLACE PROCEDURE atribuite_angajat_procedure(id_angajat number, id_apt number)
    AS
        exceptie_ang_nou EXCEPTION;
        verificare_id_ang number(10);
        verificare_salariu number(10);
        verificare_id_apt number(10);
        
        next_id_leg number(10);
        get_nume_aptitudine varchar2(20);
        get_salariu number(10);
        get_zona number(10);
        
BEGIN
        select salariul into verificare_salariu from Angajati 
                where marca_angajat = id_angajat;        
        
        if verificare_salariu IS NOT NULL then
           RAISE exceptie_ang_nou;
        else            
        select max(id_legatura) into next_id_leg from Legaturi;
        
        insert into Legaturi (id_legatura, id_aptitudine, marca_angajat)
        values(next_id_leg + 1, id_apt, id_angajat);
        
        select specializare into get_nume_aptitudine from Aptitudini
                where id_aptitudine = id_apt;
        
        if upper(get_nume_aptitudine) = upper('Casier') THEN
                get_salariu := 1800;
                get_zona := 2;
            
        if upper(get_nume_aptitudine) = upper('Tehnic') THEN
                get_salariu := 2200;
                get_zona := 1;
        else
            get_salariu := 2100;
                get_zona := 2;
end if;
end if;
    update Angajati
    set id_zona = get_zona, salariul = get_salariu
    where marca_angajat = id_angajat;

end if;

EXCEPTION
    when NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista date!');
    when exceptie_ang_nou THEN
         dbms_output.put_line('Angajatul introdus nu este nou!!');

END;
/

DECLARE
    id_ang number := '&ID_ANG_NOU';
    id_apt number := '&ID_SPECIALIZARE';
BEGIN
    atribuite_angajat_procedure(id_ang, id_apt);
    commit;
END;
/

select ang.nume, ap.specializare
from Legaturi l, Aptitudini ap, Angajati ang
where l.marca_angajat = ang.marca_angajat and l.id_aptitudine = ap.id_aptitudine;

--3. Sa se creeze o procedura care permite adaugarea de instrumente noi
select * from user_sequences; --seq_instrument

CREATE OR REPLACE PROCEDURE adaugare_instrumente_procedura(tip_instrument varchar2, denumire varchar2, firma varchar2, anfabric date)
    AS
        get_zona number(2) := -1;
        exceptie EXCEPTION;
BEGIN
        if upper(tip_instrument) LIKE upper('Chitara%') then
            get_zona := 1;
        elsif upper(tip_instrument) LIKE upper('Tobe%') then
            get_zona := 3;
end if;
        
        if get_zona = -1 then
            RAISE exceptie;
        else
            insert into Instrumente (id_instrument, denumire_instrument, firma_producatoare, an_fabricatie, id_zona)
            values(seq_instrument.NEXTVAL, denumire, firma, anfabric, get_zona);
end if;

EXCEPTION
    when exceptie then
    dbms_output.put_line('Nu exista momentan o zona pentru tipul instrumentului introdus!');
    when others then
    dbms_output.put_line('Alt tip de exceptie');
END;
/

DECLARE
    tip_instrument varchar2(50) := '&TIP_INSTRUMENT';
    denumire varchar2(50) := '&DENUMIRE_INSTRUMENT';
    firma varchar2(50) := '&FIRMA_PRODUCATOARE';
    an date := '&AN_FABRICARE';
BEGIN
    adaugare_instrumente_procedura(tip_instrument, denumire, firma, an);
    commit;
END;
/            
--FUNCTII
--1. Sa se scrie o functie care returneaza cate instrumente de un anumit tip exista in magazin

CREATE OR REPLACE FUNCTION nr_instrumente_function(tip_instrument varchar2) RETURN number
    AS
        CURSOR instrumente_cursor IS
            SELECT denumire_instrument from Instrumente;
        
        nr_de_returnat number(3) := 0;
BEGIN
    FOR iterator IN instrumente_cursor LOOP
        if upper(iterator.denumire_instrument) LIKE ( '%' || upper(tip_instrument) || '%') then
            nr_de_returnat := nr_de_returnat + 1;
        end if;
    end loop;
    RETURN nr_de_returnat;
END;
/

DECLARE 
    tip_instrument varchar2(50) := '&TIP_INSTRUMENT';
    rez number(3);
BEGIN
    rez := nr_instrumente_function(tip_instrument);
    dbms_output.put_line('Exista: ' || rez || ' instrumente de tipul ' || tip_instrument);
END;
/
            
select count(id_instrument) from Instrumente
where upper(denumire_instrument) LIKE ( '%' || upper('Chitara') || '%');


--2. Sa se afiseze cati angajati lucreaza intr-o anumita zona
CREATE OR REPLACE FUNCTION nr_angajati_function(den_zona varchar2) RETURN number
    AS
        get_id_zona number(2) := -1;
        nu_exista_zona EXCEPTION;
        nr_ang number(2);
BEGIN
        select id_zona into get_id_zona from Zone
        where upper(denumire_zona) LIKE ('%' || upper(den_zona) || '%');
        
        IF SQL%ROWCOUNT < 0 then
            RETURN 0;
 end if;       
        
        if get_id_zona = -1 then
            RAISE nu_exista_zona;
            RETURN 0;
        else
            select count(marca_angajat) into nr_ang from Angajati
                where id_zona = get_id_zona;
                RETURN nr_ang;       
end if;
EXCEPTION
    when nu_exista_zona THEN
        dbms_output.put_line('Nu exista aceasta zona in magazin!');
    when others THEN
        dbms_output.put_line('Alta exceptie');
END;
/

DECLARE
    numele_zonei varchar2(20) := '&NUME_ZONA';
    rez number(3);
BEGIN
    rez := nr_angajati_function(numele_zonei);
    dbms_output.put_line('Exista: ' || rez || ' angajati care lucreaza in zona ' || numele_zonei);

END;
/

--3. Sa se scrie o functie care returneaza cati angajati au o anumita specializare
CREATE OR REPLACE FUNCTION angajati_cu_sp_function(id_apt number)  RETURN number
    AS
        nr number(3) := 0;
        get_marca number(3);
        v_nume varchar2(30);
        v_prenume varchar2(30);
        CURSOR legaturi_cursor IS
            select id_aptitudine, marca_angajat from Legaturi;
        
        CURSOR angajati_cursor(marca number) IS
            select nume, prenume from Angajati
                where marca_angajat = marca;
BEGIN
    for i IN legaturi_cursor LOOP
        if i.id_aptitudine = id_apt then
            get_marca := i.marca_angajat;
            nr := nr + 1;
        end if;            
    end loop;
    RETURN nr;
    
EXCEPTION
    when NO_DATA_FOUND then
    dbms_output.put_line('Nu exista date');
END;
/

BEGIN
     dbms_output.put_line('Nr ang cu specializarea 4: ' ||angajati_cu_sp_function(4));
END;
/

--4. Sa se numere cati artisti au contribuit la un anumit album
CREATE OR REPLACE FUNCTION artisti_function(den_album varchar2) RETURN number
    AS
        get_album_id number(3) := -1;
        nr number(3);
        ex EXCEPTION;

BEGIN
        select id_album into get_album_id from Albume
            where upper(denumire_album) LIKE ('%' || upper(den_album) || '%');
         
         if get_album_id < 0 THEN
            RAISE ex;
        else            
        select count(id_artist) into nr from Contributii
            where id_album = get_album_id;
            
        if SQL%ROWCOUNT > 0 then
            RETURN nr;
        else
            RETURN 0;
end if;
end if;

EXCEPTION
    when ex then
     dbms_output.put_line('Nu am date');

END;
/

DECLARE
    nr number(3);
    den_album varchar2(30) := '&DENUMIRE_ALBUM';
BEGIN
     dbms_output.put_line('Nr artisti care au compus: ' || artisti_function(den_album) || ' ' || den_album);
END;
/

