--CURSOR
set serveroutput on;

BEGIN 
    update Produse
    set pret_min = pret_min where id_produs = '&id_p';
    
    if SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Produsul s-a actualizat');
    else
        DBMS_OUTPUT.PUT_LINE('Produsul nu id-ul introdus nu exista');
    end if;

END;
/


--sa se afiseze numele si salariul angj folosind un cursor explicit

DECLARE
  CURSOR angj_cursor IS
  SELECT id_angajat, nume from angajati ORDER BY id_angajat;

BEGIN
  FOR it IN angj_cursor LOOP
     DBMS_OUTPUT.PUT_LINE(it.id_angajat || ' '|| it.nume);
  end LOOP;
END;
/

--sa se afiseze intr un bloc plsql pt fiecare comanda identificatorul, data incheierii, valoarea


select c.nr_comanda, c.DATA, (rc.pret * rc.cantitate) as val 
from Comenzi c, Rand_Comenzi rc
where c.nr_comanda = rc.nr_comanda;

DECLARE
    CURSOR com_cursor IS select c.nr_comanda, c.DATA, sum((rc.pret * rc.cantitate)) as val 
                                from Comenzi c, Rand_Comenzi rc
                                    where c.nr_comanda = rc.nr_comanda
                                        group by c.nr_comanda, c.DATA
                                            ORDER BY val;
BEGIN
    FOR iterator IN com_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(iterator.nr_comanda || ' ' || iterator.DATA || ' ' || iterator.val);
END LOOP;
END;
/









