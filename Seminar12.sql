-- 1. Creati un bloc prin care sa se scada cu 5% limita de credit a clientiilor care au incheiat comenzi intr-un an dat de la tastatura.
set serveroutput on;
DECLARE
    

BEGIN
    UPDATE Clienti
    SET limita_credit = limita_credit - 0.05 * limita_credit
   where id_client IN (SELECT id_client FROM Comenzi where EXTRACT(year from data) = EXTRACT(year from to_date('&DATA_CITITA', 'DD-MON-YYYY')));
    
    if SQL%ROWCOUNT = 0 then
        RAISE NO_DATA_FOUND;
    else
        dbms_output.put_line('S-au efectuat: ' || SQL%ROWCOUNT || ' modificari');
end if;
    
EXCEPTION
    when NO_DATA_FOUND then
       dbms_output.put_line('Nu exista date');
END;
/

--2. Sa se creeze o functie care sa calculeze numarul de angajati cu salariul mai mare decat media. Care fac parte din departamentul al carui id este dat ca parametru. Tratati prin ex cand nu exista ang + nu exista departamentu

CREATE OR REPLACE FUNCTION nr_angajati_salariu( v_id_departament NUMBER) RETURN NUMBER AS
    get_salariu_mediu number := 0;
    count_angajati number := 0;
    nu_exista_ang EXCEPTION;
    nu_exista_departamentul EXCEPTION;
    
    verif_dep NUMBER := 0;
    verif_ang NUMBER := 0;
BEGIN
    select AVG(salariuL) INTO get_salariu_mediu from Angajati;
    select count(id_departament) INTO verif_dep from Departamente WHERE id_departament = v_id_departament;
    select count(id_angajat) INTO verif_ang from Angajati where salariul >= get_salariu_mediu;
    
    if verif_dep = 0 THEN
        RAISE nu_exista_departamentul;
    elsif verif_ang = 0 then
        RAISE nu_exista_ang;
    else
        RETURN verif_ang;
end if;

EXCEPTION
    WHEN nu_exista_departamentul THEN
        dbms_output.put_line('Nu exista departamentul introdus');
        RETURN -1;
    WHEN nu_exista_ang THEN
        dbms_output.put_line('Nu exista angajati');
        RETURN -2;
    WHEN OTHERS THEN
        dbms_output.put_line(SQLCODE);
        RETURN -3;
END;
/
        
--3. Sa se creeze o procedura care sa afiseze informatii despre primele 3 departamente care au cei mai multi angajati cu salariul > salariul mediu

CREATE OR REPLACE PROCEDURE afiseaza_dep_salariul AS
    CURSOR departamente_cursor IS
        SELECT id_departament, denumire_departament, nr_angajati_salariu(id_departament) as nr_ang from Departamente
            ORDER BY nr_ang DESC;

BEGIN
    FOR iterator IN departamente_cursor LOOP
        dbms_output.put_line(iterator.denumire_departament);
    EXIT WHEN departamente_cursor%ROWCOUNT = 3;
END LOOP;
END;
/

execute afiseaza_dep_salariul;
    

--4. Creati o functie care sa returneze valoarea cea mai mare pentru comenzile date de un angajat pentru care se da id'ul ca parametru.
CREATE OR REPLACE FUNCTION fct_val_max2(v_id_angajat angajati.id_angajat%type) RETURN NUMBER AS
        
        CURSOR cursor_frumos(idd NUMBER) IS
        select SUM(rc.pret * rc.cantitate) as valoare, c.id_client
            from Rand_comenzi rc, Comenzi c
             where rc.nr_comanda = c.nr_comanda and id_client = idd
             group by c.id_client;
             
    get_maxim NUMBER := 0;
    nu_exista_id_ang EXCEPTION;
    
BEGIN
    
    FOR iterator IN cursor_frumos(v_id_angajat) LOOP
        --dbms_output.put_line(iterator.valoare);
        if iterator.valoare > get_maxim then
            get_maxim := iterator.valoare;
        END IF;
    END LOOP;

--dbms_output.put_line(get_maxim);
    if get_maxim > 0 then
        RETURN get_maxim;
    else
         RAISE nu_exista_id_ang;
end if;
EXCEPTION
    WHEN  nu_exista_id_ang then
        dbms_output.put_line('Nu exista angajatul cu acest id'); 
        RETURN -1;
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nu AM COMENZI!');
        RETURN -2;
    WHEN OTHERS THEN
         dbms_output.put_line('Alta exceptie! codul ei: ' || SQLCODE);
         RETURN -3;
END;
/
    
    
 CREATE OR REPLACE PROCEDURE proc_afiseaza_ang AS
    CURSOR cursor_date_ang IS
        select id_angajat, nume || ' ' || prenume as nume_complet, fct_val_max2(id_angajat) as val from Angajati
        ORDER BY fct_val_max2(id_angajat) DESC;

BEGIN
    FOR iterator IN cursor_date_ang LOOP
        dbms_output.put_line('Nume complet: ' || iterator.nume_complet || ', id angajat: ' || iterator.id_angajat || 
                        ', Valoare: ' || iterator.val);
        EXIT WHEN cursor_date_ang%ROWCOUNT = 3;
    end loop;
END;
/


execute proc_afiseaza_ang;   
    

--5. Creati un bloc anonim prin care sa se adauge o coloana noua "STOC" in tabela produse. coloana are restrictie, valoarea stocului sa fie > 0;
-- 6. Intr-un bloc PL adaugati valori in coloana stoc astfel: daca produsul a fost comandat anterior stoc = 20, daca nu a mai fost comandat pana acum stoc = 30;
-- in cazul in care actualizarile se fac cu succes afisati numarul de actualizari facute;
-- 7. Sa se creeze un trigger care sa nu permita comandarea unui produs in cantitate mai mare decat stocul aferent; altfel se va permite comandarea produsului si se va modifica valoarea in stoc



--5. -> adaug coloana "STOC"

    
    
    
    
    
    
    