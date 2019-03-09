SET SERVEROUTPUT ON

DECLARE
    A number := '&A';
    B number := '&B';
    C number := '&C';
    D number := B * B - 4 * A * C;

BEGIN
    dbms_output.put_line('Ecuatia introdusa: ' || A || 'X^2 + ' || B  || 'X + ' || C);
    if A = 0 then
        dbms_output.put_line('Nu este ecuatie de gradul 2!');
        return;
    else if D = 0 then
        dbms_output.put_line('Solutiile sunt: ' || -B / (2 * A));
    else if D > 0 then
        dbms_output.put_line('Prima solutie: ' || (-B - sqrt(D)) / (2 * A));
        dbms_output.put_line('A doua solutie: ' || (-B + sqrt(D)) / (2 * A));
    else
        dbms_output.put_line('Nu avem solutii reale');
    end if;
    end if;
    end if;
end;
/ 