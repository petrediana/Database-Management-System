set serveroutput on;

--NR 2

select denumire_produs, categorie from produse
    where upper(categorie) LIKE ( '%' || upper('software') || '%');
--1. 
CREATE OR REPLACE FUNCTION pret_lista_prod (v_id_prod produse.id_produs%TYPE ,v_categorie produse.categorie%TYPE, v_discount NUMBER) RETURN NUMBER AS
    pret_de_returnat produse.pret_lista%TYPE;
    verif_categoria produse.categorie%TYPE;
    
    BEGIN
        SELECT pret_lista, categorie INTO pret_de_returnat, verif_categoria FROM Produse
            WHERE id_produs = v_id_prod;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE NO_DATA_FOUND;
        ELSE
            IF upper(verif_categoria) LIKE ( '%' || upper(v_categorie) || '%') THEN
                pret_de_returnat := pret_de_returnat - pret_de_returnat * v_discount;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Nu apartine categoriei, nu se poate aplica discount-ul');
            END IF;
            RETURN pret_de_returnat;
        END IF;
   
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista produsul cu acest id!');
            RETURN -1;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Alta exceptie: ' || SQLCODE);
            RETURN -2;       
    END;
/

begin
    dbms_output.put_line(pret_lista_prod(179700, 'aaa', 0));
end;
/

SELECT pret_lista_prod(1797, 'aaa', 0) from dual;
SELECT pret_lista from produse where id_produs = 1797;


SELECT id_produs, denumire_produs, categorie, pret_lista FROM Produse
ORDER BY categorie;

SELECT id_produs, denumire_produs, categorie, pret_lista_prod(id_produs, 'hardware', 0.2) as pret_lista_prodd FROM Produse
ORDER BY id_produs;

SELECT rc.nr_comanda, rc.id_produs,pret_lista_prod(rc.id_produs, 'hardware', 0.2) as pret_lista_prodd, p.categorie
FROM Rand_comenzi rc, Produse p
WHERE rc.id_produs = p.id_produs
ORDER BY p.categorie;


--2.
CREATE OR REPLACE TRIGGER trg_rand_comenzi_pr 
BEFORE INSERT OR UPDATE OF PRET ON RAND_COMENZI
FOR EACH ROW
    DECLARE
        OK NUMBER := 0;
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        SELECT COUNT(*) INTO OK FROM RAND_COMENZI
            WHERE id_produs = :new.id_produs;
            
        IF SQL%ROWCOUNT = 0 THEN
            RAISE NO_DATA_FOUND;
        ELSE
            :new.pret := pret_lista_prod(:new.id_produs, '', 0);
            COMMIT;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista produsul cu acest id!!' || :new.id_produs);
    END;
/

UPDATE rand_comenzi 
set pret = 100
    where nr_comanda = 2392;
    
select * from rand_comenzi
    where nr_comanda = 2392;

INSERT INTO RAND_COMENZI(nr_comanda, id_produs, pret, cantitate)
values(2392, 3082, 0, 99);

select pret from rand_comenzi
    where nr_comanda = 2392 and id_produs = 3082;
    
-----------------------------------------------------------------------------------------------------  
       
    
--NR3
/*CREATE OR REPLACE FUNCTION cost_total_comenzi(v_id_client comenzi.id_client%TYPE, cost_maxim NUMBER, adaos NUMBER) RETURN NUMBER
    AS
        get_nr_comanda comenzi.nr_comanda%TYPE;
        ok number := 0;
        val_totala_comenzi number := 0;
        
        CURSOR comenzi_cursor(id_c NUMBER) IS SELECT nr_comanda
            FROM COMENZI WHERE id_client = id_c;
        
        BEGIN
            SELECT nr_comanda INTO get_nr_comanda FROM COMENZI
                WHERE id_client = v_id_client;
            
            if SQL%ROWCOUNT = 0 THEN
                RAISE NO_DATA_FOUND;
            ELSE
                SELECT SUM(pret * cantitate) INTO val_totala_comenzi FROM Rand_comenzi
                    WHERE nr_comanda = get_nr_comanda;
                
                IF val_totala_comenzi >= cost_maxim THEN
                    RETURN val_totala_comenzi;
                ELSE
                    val_totala_comenzi := val_totala_comenzi + adaos * val_totala_comenzi;
                    RETURN val_totala_comenzi;
                END IF;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Nu exista clientul cu acest id!!');
                RETURN -1;
            
        END;
/

SELECT cost_total_comenzi(148, 0, 0) FROM DUAL;


SELECT id_client, nume_client, cost_total_comenzi(id_client, 0, 0) as cost_total FROM Clienti
ORDER BY cost_total_comenzi(id_client, 0, 0) DESC;
*/

--EXISTA CLIENTI CARE AU DAT MAI MULTE COMENZI
--DECI CURSOR comenzi_cursor(id_c NUMBER) IS SELECT nr_comanda FROM COMENZI WHERE id_client = id_c; POATE INTOARCE MAI MULTE VALORI!!!

--1
CREATE OR REPLACE FUNCTION cost_total_comenzi2(v_id_client comenzi.id_client%TYPE, cost_maxim NUMBER, adaos NUMBER) RETURN NUMBER
    AS
        get_nr_comanda comenzi.nr_comanda%TYPE;
        ok number := 0;
        val_totala_comenzi number := 0;
        get_val_curenta number := 0;
        
        CURSOR comenzi_cursor(id_c NUMBER) IS SELECT nr_comanda
            FROM COMENZI WHERE id_client = id_c;
    BEGIN
        FOR iterator IN comenzi_cursor(v_id_client) LOOP
            --dbms_output.put_line(iterator.nr_comanda);
            
            SELECT SUM(pret * cantitate) INTO get_val_curenta FROM Rand_comenzi
                where nr_comanda = iterator.nr_comanda;
            
            val_totala_comenzi := val_totala_comenzi + get_val_curenta;
        END LOOP;
        
        IF val_totala_comenzi >= cost_maxim THEN
           RETURN val_totala_comenzi;
        ELSE
            val_totala_comenzi := val_totala_comenzi + adaos * val_totala_comenzi;
            RETURN val_totala_comenzi;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('NU EXISTA DATE!');
            RETURN -1;
    END;
/
                
SELECT id_client, nume_client, cost_total_comenzi2(id_client, 0, 0) FROM Clienti
ORDER BY cost_total_comenzi2(id_client, 0, 0) DESC;    

--2

CREATE OR REPLACE TRIGGER rc_pret_lista_trg
BEFORE INSERT OR UPDATE OF PRET ON RAND_COMENZI
FOR EACH ROW
    DECLARE
        nu_comenzi EXCEPTION;

        get_pret_de_pus NUMBER := 0;
        get_metoda_plata comenzi.modalitate%TYPE;
        get_id_produs produse.id_produs%TYPE;
        pragma autonomous_transaction;
        
        get_nrc rand_comenzi.nr_comanda%TYPE := :new.NR_COMANDA;
        
    BEGIN
        SELECT MODALITATE INTO get_metoda_plata FROM Comenzi
            WHERE NR_COMANDA = get_nrc;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE nu_comenzi;
        ELSE
        
            
            SELECT pret_lista INTO get_pret_de_pus FROM Produse
                where id_produs = :new.id_produs;
            
            IF upper(get_metoda_plata) = upper('online') THEN
                :new.pret := get_pret_de_pus;
                commit;
            END IF;
        END IF;
    EXCEPTION
        WHEN nu_comenzi THEN
            RAISE_APPLICATION_ERROR(-20001, 'NU EXISTA ACEASTA COMANDA!!!');
    END;
/

--nrc 2355 -> online

update rand_comenzi
    set pret = 0 
where nr_comanda = 2355;

 SELECT pret FROM Rand_comenzi
                where NR_COMANDA = 2355;


        