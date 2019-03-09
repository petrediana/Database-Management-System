SET SERVEROUTPUT ON;

--1. S? se calculeze valoarea f?r? TVA pentru un pre? introdus de la tastatur? ce con?ine TVA
VARIABLE pret number
ACCEPT pret_citit PROMPT  'Introduceti pretul: '
DECLARE
copie_pret number(9, 2) := &pret_citit;
BEGIN
:pret := copie_pret - (copie_pret * 0.19);
END;
/
PRINT pret;

--2. Sa se citeasca intr-o variabila de legatura
-- venitul anual total al angajatului indicat de la tastatura

VARIABLE venit_anual number
ACCEPT angajat_id PROMPT 'Introduceti id-ul angajatului: '

DECLARE
copie_id number(9, 2) := &angajat_id;
BEGIN
select 12 * (salariul + NVL(comision, 0) * salariul) INTO :venit_anual from Angajati
where id_angajat = copie_id;

END;
/

PRINT venit_anual;

--3. Sa se afiseze contributiile si salariul net pt angajatul 100
VARIABLE venit_net number
DECLARE
venit_angajat number(9, 2);
CAS number default 0;
CASS number default 0;

BEGIN
select  (salariul + NVL(comision, 0) * salariul) INTO venit_angajat from Angajati
where id_angajat = 100;

CAS := venit_angajat * 0.25;
CASS := venit_angajat * 0.10;
:venit_net := venit_angajat - CAS - CASS;

DBMS_OUTPUT.PUT_LINE('CAS este: ' || CAS);
DBMS_OUTPUT.PUT_LINE('CASS este: ' || CASS);
END;
/
PRINT venit_net;


