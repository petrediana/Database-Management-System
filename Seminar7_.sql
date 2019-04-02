set serveroutput on;
--Proceduri

--1. Sa se construiasca o procedura prin care sa mareasca (parametru citit) limita de credit pt clientii cu nivel de venit din categoria B:.. si care au incheiat un nr de comenzi dat ca parametru

CREATE OR REPLACE PROCEDURE procedura_1 (lim_cr_noua number, nr_comenzi number)
    AS
        nr_com number;
        CURSOR clienti_cursor IS select id_client, nume_client from CLIENTI;
        --TYPE tip IS TABLE OF VARCHAR2(5) INDEX BY BINARY_INTEGER;
        --Vector tip;
        
    BEGIN
        FOR iterator IN clienti_cursor LOOP
            SELECT count(iterator.id_client) into nr_com from COMENZI
                    where id_client = iterator.id_client;
                    
        IF nr_com > nr_comenzi THEN
            UPDATE CLIENTI
                set limita_credit = limita_credit + lim_cr_noua
                    where id_client = iterator.id_client AND nivel_venituri like 'B%';
             -- RETURNING (nume_client) bulk collect into Vector;
               dbms_output.put_line('S-a modificat; NUMELE CLIENTULUI: ' || iterator.nume_client);    
            
            else
               dbms_output.put_line('Nu am nr de comenzi mai mare');
        END IF;
    END LOOP;
    
   -- FOR i IN 1.. vector.COUNT loop
    --dbms_output.put_line(Vector(i));
--end loop;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
         dbms_output.put_line('No data found');
END;
/

DECLARE
    lim_c number := '&LIMITA_CREDIT';
    nr_c number := '&NR_COMENZI';

BEGIN
    procedura_1(lim_c, nr_c);
    END;
/


--3. Construiti o functie care sa returneze cantitatea totala comandata din produsul dat ca parametru
--. TEMA!!!!!!!!!!!!! 
--. 1. construiti cel putin 7 proceduri/functii pe baza de date de la proiect

CREATE OR REPLACE FUNCTION functia_3 (id_p number) RETURN number
    AS
        --CURSOR produse_cursor IS select id_produs from Produse;
        cant number(9);
BEGIN
   select SUM(cantitate) into cant FROM RAND_COMENZI
    where id_produs = id_p;
    
    IF SQL%ROWCOUNT > 0 THEN
        RETURN cant;
    else
        RETURN -1;
end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Nu exista produsul');
END;
/


DECLARE 
    rez number(9);
    id_citit number := '&ID_PRODUS_CITIT';
BEGIN
    rez := functia_3(id_citit);
    
    if rez > - 1 then
        dbms_output.put_line('Rezultat: ' || rez);
    else
        dbms_output.put_line('Nu am cantitate');
end if;
END;
/


