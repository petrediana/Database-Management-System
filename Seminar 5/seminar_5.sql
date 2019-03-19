--tema: de realizat cel putin 5 blocuri PL (cu cursori) folosind baza de date de la proiect


--1. sa se creeze un bloc plsql prin care sa se afiseze pentru fiecare departament angj acestuia astfel: 
-- denumire departament -> angajatii
-- departament 2 -> angajatii
--....

set serveroutput on;

DECLARE
    CURSOR dep_cursor IS select denumire_departament, id_departament FROM Departamente
                        WHERE id_departament IN (SELECT id_departament FROM Angajati);
    
    angj_nume varchar2(30);
    angj_sal number(4);
    exi number(4);
BEGIN
    FOR iterator IN dep_cursor LOOP
        select count(*) INTO exi, angj_sal FROM Angajati
                    where id_departament = iterator.id_departament;
    
    
    IF exi > 0 THEN 
    
    select nume, salariul INTO angj_nume, angj_sal FROM Angajati where id_departament = iterator.id_departament;
    
    DBMS_OUTPUT.PUT_LINE(iterator.denumire_departament || ' ' || angj_nume || ' ' || angj_sal);


end if;
end loop;
end;
/

--2. sa se afiseze pentru fiecare comanda incheiata dupa 01.ian.1998 produsele comandate si cant aferente

DECLARE
        CURSOR c_com IS SELECT nr_comanda, data FROM Comenzi where extract(year from data) > 1997;
        CURSOR c_produs (nr_com NUMBER) IS SELECT r.cantitate, r.id_produs, p.denumire_produs FROM Rand_comenzi r, Produse p
                                where p.id_produs = r.id_produs AND r.nr_comanda = nr_com;
BEGIN
    FOR iterator IN c_com loop
     DBMS_OUTPUT.PUT_LINE('Comanda: ' || iterator.nr_comanda || ' ' || ' data: ' || iterator.data || ' are produsele: ');
        FOR j IN c_produs(iterator.nr_comanda) loop
            DBMS_OUTPUT.PUT_LINE( chr(9) || 'Produsul: ' || j.denumire_produs || ' in cantitate: ' || j.cantitate);
end loop;
end loop;
end;
/


--3. Sa se construiasca un bloc pl care sa afiseze  informatii despre  angajatul al carui nume este dat de la tastatura

DECLARE
    v angajati%ROWTYPE;

BEGIN
    select * into v from Angajati where nume = '&n';
     DBMS_OUTPUT.PUT_LINE(v.nume || v.salariul);
     
EXCEPTION
        WHEN TOO_MANY_ROWS THEN
         DBMS_OUTPUT.PUT_LINE('Prea multi angj');
         
        WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('Nu exista angj');         

end;
/







