--Structuri de programare

--alternativa -> IF conditie de evaluat THEN instructiuni  
--                  ELSE instructiune
--              END IF;

-- IF conditie1 THEN instr;
--      ELSE IF conditie2 THEN instructiune;
--            .....
--      ELSE
--            .....
-- END IF;


-- Structura CASE
--  CASE 
--  WHEN cond1 THEN instr1;
--  ....
--  ELSE instr;
--  END CASE;
--
--  Variabila CASE
--  v :=    CASE WHEN c1 THEN val_1 .....
--   END;
set serveroutput on

DECLARE
varsta number;
BEGIN 
if varsta < 18 then dbms_output.put_line('Copil');
else dbms_output.put_line('adult');
end if;
end;
/

-- structuri repetitite: conditie initiala, conditie finala, cu nr finit de pasi
-- repetitiva conditionata initial
-- WHILE conditie
--      LOOP    
--      .....
--      END

-- conditionata posterior
--      LOOP
--      ....
--  EXIT WHEN conditie
--  END loop;

--nr finit de pasi
-- FOR i IN min..max (in sens invers adaug reverse)
--  loop    
-- .....
-- END LOOP;