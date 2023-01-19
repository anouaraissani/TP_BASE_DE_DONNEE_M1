--1
CREATE or replace trigger message after insert or delete or update on sportifs 
for each row 
begin
case
when inserting then dbms_output.put_line ('un sportif a été ajouté') ; 
when deleting then dbms_output.put_line ('un sportif a été supprimé') ;
when updating then dbms_output.put_line ('un sportif a été modifié') ;
end case;
exception
when others then dbms_output.put_line ('error:' ||sqlcode||''||sqlerrm) ;
end;
/

SET SERVEROUTPUT ON

--Vérification
INSERT INTO Sportifs VALUES(200,'AISSANI','Anouar','F',24,1);
UPDATE Sportifs SET AGE = 20 WHERE IDSPORTIF = 200;
DELETE FROM Sportifs WHERE IDSPORTIF = 200;


--2
CREATE or replace trigger affich_entraineur after insert on SEANCES 
for each row 
declare
noms sportifs.nom%type;
prenoms sportifs.prenom%type;
begin
SELECT NOM, PRENOM into noms, prenoms
FROM sportifs
WHERE idsportif = :new.IDSPORTIFENTRAINEUR;
dbms_output.put_line ('Une séance est ajoutée à l entraineur '||noms||' '||prenoms); 
end;
/
SHOW ERRORS TRIGGER affich_entraineur;

--Vérification
INSERT INTO SEANCES VALUES(3,3,3,'Samedi',18.0,90);


--3
CREATE or replace trigger verifie_age before update of AGE on SPORTIFS 
for each row 
declare
begin
IF :new.age < :old.age THEN 
RAISE_APPLICATION_ERROR(-20005,‘La contrainte verifie_age est violée’);
END IF;
END;
/
SHOW ERRORS TRIGGER verifie_age;

UPDATE sportifs SET age = 30 WHERE idsportif = 2;


--
--4
--a
ALTER TABLE sports add Total_Entraineurs NUMBER;
ALTER TABLE sports add Total_Arbitres NUMBER;

DESC sports;

/*initialiser les attributs Total_Entraineurs et Total_Arbitres par les valeurs qui existes dans la BD*/
create or replace procedure initialiser(codsport sports.idsport%type) is
nbr_Entraineurs NUMBER;
nbr_Arbitres NUMBER;
begin
select count(DISTINCT IDSPORTIFENTRAINEUR) into nbr_Entraineurs
from  ENTRAINER 
where idsport = codsport;
update sports set total_Entraineurs = nbr_Entraineurs
where idsport = codsport;
select count(DISTINCT IDSPORTIF) into nbr_Arbitres
from  ARBITRER 
where idsport = codsport;
update sports set total_Arbitres = nbr_Arbitres
where idsport = codsport;
end initialiser;
/
select idsport, total_Entraineurs, total_Arbitres from sports;


/*exécution de la procedure pour tous les sports*/
declare
cursor cr is select idsport from sports;
begin
for item in cr 
loop
initialiser(item.idsport);
end loop;
end;
/
select idsport, total_Entraineurs, total_Arbitres from sports;


--
--b
create or replace trigger verifie_total_Entraineurs after insert or delete on ENTRAINER
for each ROW
BEGIN
CASE
    WHEN INSERTING THEN update sports set total_Entraineurs = total_Entraineurs + 1;
    WHEN DELETING  THEN update sports set total_Entraineurs = total_Entraineurs - 1;
END CASE;
EXCEPTION
    WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/

create or replace trigger verifie_total_Arbitres after insert or delete on ARBITRER
for each ROW
BEGIN
CASE
    WHEN INSERTING THEN update sports set total_Arbitres = total_Arbitres + 1;
    WHEN DELETING  THEN update sports set total_Arbitres = total_Arbitres - 1;
END CASE;
EXCEPTION
    WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/


--Vérification
select idsport, total_Entraineurs, total_Arbitres from sports;
INSERT INTO Arbitrer VALUES(151,2);
INSERT INTO Entrainer VALUES(151,2);
select idsport, total_Entraineurs, total_Arbitres from sports;
delete from Arbitrer WHERE IDSPORTIF = 151 AND IDSPORT = 2;
delete from Entrainer WHERE IDSPORTIFENTRAINEUR = 151 AND IDSPORT = 2;
select idsport, total_Entraineurs, total_Arbitres from sports;


--
--5
--a
create table Historique_Seance_Par_Jour (
    Jour  VARCHAR2(10), 
    total_seance number, 
    constraint pk_hc primary key(Jour),
    constraint checkJOUR CHECK (JOUR IN ('Samedi', 'Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'))
);



--
--b
------------INSERTION--------------------------------------------------
CREATE OR REPLACE TRIGGER isert_Seance_Par_Jour AFTER INSERT ON seances
FOR EACH ROW 
declare
j int;
BEGIN 
select count(Jour) into j from Historique_Seance_Par_Jour where jour = :new.jour;
if (j = 0) then insert into Historique_Seance_Par_Jour (jour, total_seance) values (:new.jour, 1);
else
UPDATE Historique_Seance_Par_Jour set total_seance = total_seance + 1  where jour = :new.jour;
end if;
END ;
/
--Vérification
select * from Historique_Seance_Par_Jour;
INSERT INTO Seances VALUES(28,3,9,'Mardi',18.0,120);
select * from Historique_Seance_Par_Jour;

------------UPDATE----------------------------------------------------
CREATE OR REPLACE TRIGGER modif_Seance_Par_Jour AFTER update ON seances
FOR EACH ROW 
declare
j int;
BEGIN 
UPDATE Historique_Seance_Par_Jour set total_seance = total_seance - 1  where jour = :old.jour;
select count(jour) into j from Historique_Seance_Par_Jour where jour = :new.jour;
if (j = 0) then insert into Historique_Seance_Par_Jour (jour, total_seance) values (:new.jour, 1);
else
UPDATE Historique_Seance_Par_Jour set total_seance = total_seance + 1  where jour = :new.jour;
end if;
END ;
/
--Vérification
select * from Historique_Seance_Par_Jour;
UPDATE SEANCES SET jour = 'Dimanche' WHERE IDGYMNASE = 17 and IDSPORT = 3 and IDSPORTIFENTRAINEUR = 9 and jour = 'Mardi' and HORAIRE = 18.0;
select * from Historique_Seance_Par_Jour;


------------------------------------DELETE---------------------------------
CREATE OR REPLACE TRIGGER supp_hist_Seance_Par_Jour AFTER delete ON seances
FOR EACH ROW 
declare
j int;
BEGIN 
select count(jour) into j from Historique_Seance_Par_Jour where jour = :old.jour;
if (j = 0) then dbms_output.put_line('le jour n''est pas dans la table donc rien à modifier');
else
UPDATE Historique_Seance_Par_Jour set total_seance = total_seance - 1  where jour = :old.jour;
end if;
END ;
/

--Vérification
select * from Historique_Seance_Par_Jour;
delete from seances where IDGYMNASE = 28 and idsport = 5 and IDSPORTIFENTRAINEUR = 7 and jour ='Vendredi' and horaire = 18.0;
select * from Historique_Seance_Par_Jour;
delete from seances where IDGYMNASE = 17 and IDSPORT = 3 and IDSPORTIFENTRAINEUR = 9 and jour = 'Dimanche' and HORAIRE = 18.0;
select * from Historique_Seance_Par_Jour;




