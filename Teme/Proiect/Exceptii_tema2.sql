set serveroutput on;

--1. Sa se afiseze detalii despre un angajat: numele, numele, specializarea sa si zona in care lucreaza
DECLARE
    id_citit number := '&ID_ANGAJAT';
    v_nume varchar2(40);
    v_specializare varchar2(40);
    v_zona varchar2(40);
    v_idz number(3);

BEGIN
   
   select nume || ' ' || prenume, id_zona into v_nume, v_idz From Angajati
        where marca_angajat = id_citit;
    dbms_output.put_line('Numele: ' || v_nume);
    
    select  ap.specializare into v_specializare
        from Legaturi l, Aptitudini ap
            where l.marca_angajat = id_citit and l.id_aptitudine = ap.id_aptitudine;
    dbms_output.put_line('Specializare: ' || v_specializare);
    
    select denumire_zona into v_zona From zone
        where id_zona = v_idz;
    dbms_output.put_line('Lucreaza in zona: ' || v_zona);

   
EXCEPTION
    when NO_DATA_FOUND then
        dbms_output.put_line('Nu exista angajatul cu id-ul introdus!!');
END;
/

--2. Sa se modifice cu 200 u.m salariul tuturor angajatilor care au o anumita specializare(introdusa de la tastatura) si salariul actual mai mic decat 2200 u.m
DECLARE
    nr_modif number(2) := 0;
    ZERO_MODIF EXCEPTION;
    v_specializare varchar2(40) := '&INTRODU_SPECIALIZARE';
    
    CURSOR legaturi_cursor IS 
            select id_legatura, marca_angajat, id_aptitudine FROM Legaturi;
    CURSOR apt_cursor(id_ap NUMBER) IS
            select specializare, instrumente FROM Aptitudini where id_aptitudine = id_ap;
    CURSOR ang_cursor(id_ang NUMBER) IS
            select nume || ' ' || prenume as nume_c, marca_angajat, salariul from Angajati where marca_angajat = id_ang;
BEGIN
 dbms_output.put_line('Specializarea introdusa ' || v_specializare);
    FOR it_leg IN legaturi_cursor LOOP
        FOR it_apt IN apt_cursor(it_leg.id_aptitudine) LOOP
            FOR it_ang IN ang_cursor(it_leg.marca_angajat) LOOP
            
            if it_ang.salariul < 2200 AND it_apt.specializare = v_specializare then
                 nr_modif :=  nr_modif + 1;
                 
                 update Angajati
                 set salariul = salariul + 200
                 where marca_angajat = it_ang.marca_angajat;
    end if;           
    end loop;
    end loop;
    end loop;
    
    if  nr_modif = 0 then
        RAISE ZERO_MODIF;
    else
         dbms_output.put_line('S-au modificat: ' || nr_modif || ' linii');
end if;

EXCEPTION
    when ZERO_MODIF then
         dbms_output.put_line('Nu s-a produs nicio modificare. Ai grija ce specializare introduci!!');
END;
/

--3. Sa se afiseze cate contributii are un artist. Se va citi numele de familie al artistului
DECLARE
    nume_citit varchar2(40) := '&nume_citit';
    nr_contrib number(2) := 0;
    v_id_ar number(2);
    zero_contrib EXCEPTION;

BEGIN
 dbms_output.put_line('Numele artistului: ' || nume_citit);

    select id_artist into v_id_ar from Artisti
    where upper(nume) = upper(nume_citit);

    select count(*) into nr_contrib from Contributii c, Artisti a
    where c.id_artist = v_id_ar;
    
    if nr_contrib = 0 then
        RAISE zero_contrib;
    else
         dbms_output.put_line('Artistul a contibut la: ' ||nr_contrib || ' albume');
end if;

EXCEPTION
    when TOO_MANY_ROWS then
    dbms_output.put_line('Sunt mai multi artisti cu acelasi nume!!');
    
    when zero_contrib then
     dbms_output.put_line('Artistul are 0 contributii!!');
     
     when NO_DATA_FOUND then
      dbms_output.put_line('Nu exista artistul cu numele introdus');
END;
/

--4. Sa se afiseze cati angajati lucreaza in fiecare zona

DECLARE
    nr_ang number(3) := 0;
    zero_ang EXCEPTION;
    CURSOR zone_cursor IS 
            select id_zona, denumire_zona FROM Zone;    
    CURSOR angajati_cursor (id NUMBER) IS 
            select nume || ' ' || prenume as nume_c from Angajati where id_zona = id;
BEGIN
    FOR it_zona IN zone_cursor LOOP
        dbms_output.put_line('Denumirea zonei: ' || it_zona.denumire_zona || ' cu angajatii: ');
            nr_ang := 0;
            FOR it_ang IN angajati_cursor(it_zona.id_zona) LOOP
                nr_ang := nr_ang + 1;
    end loop; 
    
    if nr_ang = 0 then
        RAISE zero_ang;
    else
         dbms_output.put_line('In aceasta zona lucreaza: ' || nr_ang || ' angajati');
end if;
    end loop;

EXCEPTION
    when zero_ang then
     dbms_output.put_line('Exista o zona care nu are nici un angajat!!');
END;
/

--5. Sa se afiseze numele zonei in care se afla un anumit instrument. Se va citi numele instrumentului de la tastatura

DECLARE
    nume_inst varchar2(20) := '&NUME_INSTRUMENT';
    v_id number(3);
    v_nume varchar2(40);
BEGIN
dbms_output.put_line('Caut instrumentul: ' || nume_inst);
    select id_zona into v_id from Instrumente
        where upper(denumire_instrument) = upper(nume_inst);
    
    select denumire_zona into v_nume from Zone
        where id_zona = v_id;
    
    dbms_output.put_line('Instrumentul se afla in zona: ' || v_nume);
EXCEPTION
    when TOO_MANY_ROWS then
        dbms_output.put_line('Am mai multe instrumente cu aceeasi denumire!!');
    
    when NO_DATA_FOUND then
        dbms_output.put_line('Nu exista instrumentul introdus');
END;
/

--6. Sa se afiseze numele angajatilor care au o vechime mai mare decat o valoare citita de la tastatura
DECLARE
    nr_ang number(2) := 0;
    vvechime number(2) := '&VECHIME_ANI';
    zero_ang exception;
    CURSOR ang_cursor IS
        select nume || ' ' || prenume as nume_c,  (extract(year from sysdate) - extract(year from data_angajare)) as vechime From Angajati;
BEGIN
dbms_output.put_line('Vechimea ceruta in ani: > ' || vvechime);
    FOR iterator IN ang_cursor LOOP
        if iterator.vechime > vvechime then
            nr_ang := nr_ang + 1;
        dbms_output.put_line('Numele: ' || iterator.nume_c);
    end if;
end loop;
    
    if nr_ang = 0 then
        RAISE zero_ang;
    else
        dbms_output.put_line('Am ' || nr_ang || ' angajati');
end if;
EXCEPTION
    when zero_ang then
    dbms_output.put_line('Nu am nici un angajat care depaseste vechimea introdusa!!');
END;
/

--7. Sa se afiseze numele albumului, genul muzical si anul de aparitie pentru un album al carui id se citeste de la tastatura

DECLARE
    id_citit number := '&ID_CITIT';
    CURSOR album_cursor (idd number) IS
        select denumire_album, genul_muzical, an_aparitie From Albume where id_album = idd;
    ok number := 0;
    NU EXCEPTION;

BEGIN
    for iterator IN album_cursor(id_citit) loop
        dbms_output.put_line('Nume album: ' || iterator.denumire_album || ', genul mmuzical: ' ||
            iterator.genul_muzical || ', an aparitie: ' || iterator.an_aparitie);
            ok := 1;
end loop;
    if ok = 0 then
        RAISE NU;
end if;

EXCEPTION
    when NU then
    dbms_output.put_line('Nu exista albumul cu id-ul introdus');
END;
/




--Citat: Ergo bibamus!