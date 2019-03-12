set serveroutput on;

--1.
--sa se construiasca un bloc plsql prin care sa se adauge o inregistrare noua in tabela produse
-- astfel denumire, descriere, categorie, preturile necompletate
-- pentru id ma asigur ca nu suprascriu

PROMPT Adaug un produs in tabel;

DECLARE
    den_p varchar2(30) := '&den_p';
    desc_p varchar2(30) := '&desc_p';
    cat_p varchar2(30) := '&cat_p';
    it number(4);
BEGIN
    select max(id_produs) into it from Produse;
    DBMS_OUTPUT.PUT_LINE(it);
    
    insert into Produse (id_produs, denumire_produs, descriere, categorie)
    values(it + 1, den_p, desc_p, cat_p);
    
END;
/
    
    select * from Produse where id_produs = 3516;
    

--2.
--sa se construiasca un bloc plsql
--prin care sa se dubleze pretul minim al produsului al carui id e citit de la tastatura

DECLARE
    id_p number(5) := '&id_p';
    exista number(5);
    
BEGIN
    select count(*) into exista from Produse where id_produs = id_p;
    
    if exista > 0 then
        update Produse
        set pret_min = pret_min * 2 where id_produs = id_p;
    else
    DBMS_OUTPUT.PUT_LINE('Produsul nu exista!');
    
    end if;
    
    
END;
/
    
     select * from Produse where id_produs = 3515;
