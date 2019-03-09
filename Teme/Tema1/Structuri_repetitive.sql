SET SERVEROUTPUT ON

PROMPT Utilizare structura repetitiva WHILE;

DECLARE
    iterator number(3);
    min_first number(3);
    max_last number(3);
    valid number(3);
    nume_ang varchar2(40);

BEGIN
    select min(marca_angajat) into min_first from Angajati;
    select max(marca_angajat) into max_last from Angajati;    
    --dbms_output.put_line(min_first || ' ' || max_last);
    iterator := min_first;
    -- dbms_output.put_line(iterator);
    WHILE iterator <= max_last
        LOOP
                select count(*) into valid from Angajati
                        where marca_angajat = iterator;
                
                if valid > 0 then
                    select nume || ' ' || prenume into nume_ang from Angajati
                        where marca_angajat = iterator;
                    dbms_output.put_line('Numele angajatului cu id: ' || iterator || ' este: ' || nume_ang);
                end if;
        iterator := iterator + 1;
        end loop;

END;
/

PROMPT Utilizare structura repetitiva DO-WHILE;
DECLARE
    iterator number(3);
    min_first number(3);
    max_last number(3);
    valid number(3);
    nume_ang varchar2(40);

BEGIN
    select min(marca_angajat) into min_first from Angajati;
    select max(marca_angajat) into max_last from Angajati;    
    iterator := min_first;
    
    if min_first > 0 THEN
        LOOP
                select count(*) into valid from Angajati
                    where marca_angajat = iterator;
                
                if valid > 0 then
                    select nume || ' ' || prenume into nume_ang from Angajati
                        where marca_angajat = iterator;
                    dbms_output.put_line('Numele angajatului cu id: ' || iterator || ' este: ' || nume_ang);
                end if;
            
            iterator := iterator + 1;
        EXIT WHEN iterator > max_last + 1;
        END LOOP;
        END IF;

END;
/


















     
     