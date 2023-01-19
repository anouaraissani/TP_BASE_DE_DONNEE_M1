--1

SELECT DISTINCT s.IDSPORTIF, s.NOM, s.PRENOM
FROM SPORTIFS s, SPORTIFS c
WHERE s.IDSPORTIF = c.IDSPORTIFCONSEILLEUR
ORDER BY s.IDSPORTIF;

SELECT  COUNT(DISTINCT IDSPORTIFCONSEILLEUR) 
AS SPORTIF_CONSEILLER 
FROM SPORTIFS;

--2
SET SERVEROUTPUT ON

DECLARE
CURSOR cr IS 
SELECT s.LIBELLE, COUNT(g.IDGYMNASE) AS nbr_gym
FROM SPORTS s, GYMNASES g, SEANCES c
WHERE g.IDGYMNASE = c.IDGYMNASE
AND c.IDSPORT = s.IDSPORT
GROUP BY s.LIBELLE;
BEGIN
FOR item IN cr 
LOOP
dbms_output.put_line('Le sport "'||item.LIBELLE||'" est organisé par '||item.nbr_gym);
END LOOP;
EXCEPTION
when NO_DATA_FOUND then dbms_output.put_line('Le sport n est pas organisé par aucune gymnase');
when others then dbms_output.put_line('erreur '||sqlcode||sqlerrm);
end;
/ 

--3
ALTER TABLE SPORTIFS ADD CONSTRAINT ck_age CHECK (AGE BETWEEN 20 AND 45);

ALTER TABLE SPORTIFS DISABLE CONSTRAINT ck_age;

--procedure
CREATE OR REPLACE PROCEDURE UPDATE_AGE IS
CURSOR cr IS SELECT * FROM SPORTIFS
ORDER BY IDSPORTIF;
a INTEGER;
BEGIN
FOR item IN cr 
LOOP
a := item.AGE; 
UPDATE SPORTIFS SET AGE = AGE + 5 WHERE IDSPORTIF = item.IDSPORTIF;
COMMIT;
dbms_output.put_line('le sportif '||item.NOM||' son âge a passé de '||a||' ans à '||item.AGE||' ans.');
END LOOP;
EXCEPTION
when NO_DATA_FOUND then dbms_output.put_line('Le sportif n a pas un age');
when others then dbms_output.put_line('erreur '||sqlcode||sqlerrm);
end;
/

EXECUTE UPDATE_AGE;

ALTER TABLE SPORTIFS ENABLE CONSTRAINT ck_age;

--4
CREATE OR REPLACE PROCEDURE AFFICHER_HORAIRE IS
CURSOR cr IS 
SELECT g.NOMGYMNASE, s.JOUR, MIN(s.HORAIRE) AS PREMIERE_SEANCE, MAX(s.HORAIRE) AS DERNIERE_SEANCE
FROM GYMNASES g, SEANCES s
WHERE g.IDGYMNASE = s.IDGYMNASE
AND g.surface > 400
GROUP BY g.NOMGYMNASE, s.JOUR
ORDER BY g.NOMGYMNASE, s.JOUR;
BEGIN
FOR item IN cr 
LOOP
dbms_output.put_line('le gymnase  "'||item.NOMGYMNASE||'"  a le jour d ouverture  "'||item.JOUR||'"  sa première séance est à l heure  "'||item.PREMIERE_SEANCE||'"  et sa dernière séance est à l heure  "'||item.DERNIERE_SEANCE||'"');
END LOOP;
EXCEPTION
when NO_DATA_FOUND then dbms_output.put_line('Il n y a pas des gymnases');
when others then dbms_output.put_line('erreur '||sqlcode||sqlerrm);
COMMIT;
end;
/
EXECUTE AFFICHER_HORAIRE;

--5
CREATE OR REPLACE FUNCTION NBR_SPORT_ENT (sportif SPORTIFS.IDSPORTIF%type) RETURN NUMBER IS
NBR_SPORT NUMBER;
BEGIN
SELECT COUNT(DISTINCT IDSPORT) INTO NBR_SPORT
FROM ENTRAINER 
WHERE IDSPORTIFENTRAINEUR = sportif;
RETURN NBR_SPORT;
END NBR_SPORT_ENT;
/
--------------------------
--------------------------
DECLARE
CURSOR cr IS 
SELECT DISTINCT IDSPORTIF, NOM, PRENOM
FROM SPORTIFS s, ENTRAINER e
WHERE s.IDSPORTIF = e.IDSPORTIFENTRAINEUR;
BEGIN
FOR item IN cr
LOOP
dbms_output.put_line('Le sportif '||item.NOM||' '||item.PRENOM||' entraine '||NBR_SPORT_ENT(item.IDSPORTIF)||' sports');
END LOOP;
EXCEPTION
when NO_DATA_FOUND then dbms_output.put_line('Il n y a pas des sportifs');
when others then dbms_output.put_line('erreur: '||sqlcode||''||sqlerrm);
COMMIT;
end;
/

--6
CREATE OR REPLACE PROCEDURE AJOUTER_SEANCE (id_gym IN GYMNASES.IDGYMNASE%type, id_sport IN ENTRAINER.IDSPORT%type, id_entraineur ENTRAINER.IDSPORTIFENTRAINEUR%type, JOUR VARCHAR2(10), HORAIRE NUMBER, DUREE NUMBER(38)) IS
erreur  boolean:= false;
num_gym GYMNASES.IDGYMNASE%type;
num_sport ENTRAINER.IDSPORT%type;
num_entraineur ENTRAINER.IDSPORTIFENTRAINEUR%type;
BEGIN
-- vérifier le id de le gymnase.
     DECLARE
        num_gym_null EXCEPTION;
        num_gym_existe EXCEPTION;
       BEGIN
         if(id_gym is NULL) then RAISE numcommande_null;
         else
         select IDGYMNASE into num_gym from GYMNASES where IDGYMNASE = id_gym;
         if (num_gym is not null) then RAISE num_gym_existe;
         end if;
         end if;
       EXCEPTION
        WHEN num_gym_null then  DBMS_OUTPUT.PUT_LINE('error : le id du gymnase est obligatoire'); erreur:=true;
        WHEN num_gym_existe then DBMS_OUTPUT.PUT_LINE('error : le id dgymnase existe déjà'); erreur:=true;
        WHEN NO_DATA_FOUND then null;
       END;
-- vérifier le id de sport 
     DECLARE
        num_sport_null EXCEPTION;
        num_sport_existe EXCEPTION;
       BEGIN
         if(id_sport is NULL) then RAISE num_sport_null;
         else
         select IDSPORT into num_sport from ENTRAINER where IDSPORT = id_sport;
         if (num_sport is not null) then RAISE num_sport_existe;
         end if;
         end if;
       EXCEPTION
        WHEN num_sport_null then  DBMS_OUTPUT.PUT_LINE('error : le id du sport est obligatoire'); erreur:=true;
        WHEN num_gym_existe then DBMS_OUTPUT.PUT_LINE('error : le id du sport existe déjà'); erreur:=true;
        WHEN NO_DATA_FOUND then null;
       END;
       -- vérifier le id d'entraineur 
     DECLARE
        num_entraineur_null EXCEPTION;
        num_entraineur_existe EXCEPTION;
       BEGIN
         if(id_entraineur is NULL) then RAISE num_entraineur_null;
         else
         select IDSPORTIFENTRAINEUR into num_entraineur from ENTRAINER where IDSPORTIFENTRAINEUR = id_entraineur;
         if (num_entraineur is not null) then RAISE num_entraineur_existe;
         end if;
         end if;
       EXCEPTION
        WHEN num_entraineur_null then  DBMS_OUTPUT.PUT_LINE('error : le id d entraineur est obligatoire'); erreur:=true;
        WHEN num_entraineur_existe then DBMS_OUTPUT.PUT_LINE('error : le id d entraineur existe déjà'); erreur:=true;
        WHEN NO_DATA_FOUND then null;
       END;
-- vérifier le jour de seance
     DECLARE
        jour_null EXCEPTION;
        BEGIN
         if(JOUR is NULL) then RAISE jour_null;
         end if;
       EXCEPTION
        WHEN jouratecom_null then  DBMS_OUTPUT.PUT_LINE('error : le jour de seance est obligatoire'); erreur:=true;
        END;
-- vérifier l'horaire de seance
     DECLARE
        horaire_null EXCEPTION;
        BEGIN
         if(HORAIRE is NULL) then RAISE jour_null;
         end if;
       EXCEPTION
        WHEN horaire_null then  DBMS_OUTPUT.PUT_LINE('error : l horaire de seance est obligatoire'); erreur:=true;
        END;
-- vérifier la duree de seance
     DECLARE
        duree_null EXCEPTION;
        BEGIN
         if(DUREE is NULL) then RAISE jour_null;
         end if;
       EXCEPTION
        WHEN horaire_null then  DBMS_OUTPUT.PUT_LINE('error : la duree de seance est obligatoire'); erreur:=true;
        END;
-- vérifier la contrainte JOUR.
     DECLARE
        check1 EXCEPTION;
        BEGIN
         if(JOUR = CHECK_JOUR) then RAISE check1;
         end if;
       EXCEPTION
        WHEN check1 then  DBMS_OUTPUT.PUT_LINE('error : le jour  doit être dans la liste des jour'); erreur:=true;
        END;
----- insertion
if (erreur=false)then
	       insert into commande values (id_gym,  id_sport, id_entraineur, jour, horaire, duree);
	       DBMS_OUTPUT.PUT_LINE('la seance est bien ajoutée');
	   end if;      
    EXCEPTION
       WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);  	   
END AJOUTER_SEANCE;
/
