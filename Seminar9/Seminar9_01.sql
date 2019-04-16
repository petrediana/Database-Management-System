set serveroutput on;

--Triggeri -> blocuri PL stocate in BD care se executa automat in momentul in care apar o serie de evenimente
--         -> ev declansatoare: operatii de definire a datelor (de ex)

-- -> momentul de tip la care se executa: BEFORE / AFTER / INSTEAD OF
-- -> operatia declansatoare: LMD (manipularea datelor) -> INSERT, UPDATE, DELETE
-- -> obiectul bazei de date care are triggerul atasat: o tabela de baza sau virtuala
-- -> se indica nivelul la care actioneaza triggerul: implicit -> la nivel de instructiune declansatoare || SAU la nivel de linie afectata de operatia declansatoare
-- -> eventualele conditii care sa specifice faptul ca triggerul se va declansa in anumite cazuri
-- -> APOI BLOC PL
--  DECLARE------ BEGIN------ END;
--
--
-- CREATE OR REPLACE TRIGGER trigger_name
-- BEFORE / AFTER / INSTED OF
-- INSERT [OR UPDATE [ OF column_name] OR DELETE ]
-- ON table_name // or view_name
-- FOR EACH ROW -> triggerul se declanseaza la nivelul fiecarei linii actualizate
-- WHEN (conditii) //limitarea pt declansarea triggerului pt anumite cazuri
--  DECLARE
--  ------
--  BEGIN
-- --------
-- END;

-- INVOC EXCEPTIILE PRIN RAISE_APPLICATION_ERROR


-- Triggeri care folosesc clauza FOR EACH ROW: 
--          -> :OLD      :NEW
--  INSERT:  nu_am      (:new) -> [atatea elemente cate tabele am]
--  UPDATE  :old         :new
--  DELETE  :old        nu_am ->[nu mai exista linia]