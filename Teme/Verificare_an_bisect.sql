SET SERVEROUTPUT ON;

ACCEPT an_citit PROMPT 'Introduceti anul: '

DECLARE
    copie_an number(9) := &an_citit;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Anul introdus este: ' || copie_an);
    IF
         MOD(copie_an, 4)=0
            then DBMS_OUTPUT.PUT_LINE('Anul este bisect');
    else
        DBMS_OUTPUT.PUT_LINE('Anul nu este bisect');
END IF;

END;
/