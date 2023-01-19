

--------------------------Partie I : Création des TablesSpaces et des utilisateurs--------------------------

--  1. Créer deux TableSpaces GYMNASE_TBS et GYMNASE_TempTBS

create tablespace GYMNASE_TBS  datafile 'c:\GYMNASE_TBS.dat' size 100M autoextend on online;
create temporary tablespace GYMNASE_TempTBS tempfile 'c:\GYMNASE_TempTBS.dat' size 100M autoextend on;

-- 2. Créer un utilisateur DBAGYMNASE en lui attribuant les deux tablespaces créés précédemment

create user DBAGYMNASE identified by psw default tablespace GYMNASE_TBS temporary tablespace GYMNASE_TempTBS;

-- 3. Donner tous les privilèges à cet utilisateur.

grant all privileges to DBAGYMNASE;


--------------------------Partie II : Langage de définition de données--------------------------

-- 4. Créer les relations de la base de données avec toutes les contraintes d’intégrité plus tableerreurs.

connect DBAGYMNASE/psw;

-- 5. Ajouter l’attribut DATECREATION de type Date dans la relation GYMNASES.

ALTER TABLE GYMNASES ADD DATECREATION DATE;

-- 6. Ajouter la contrainte not null pour les attributs SEXE et AGE de la relation SPORTIF.

ALTER TABLE SPORTIF MODIFY SEXE NOT NULL;
ALTER TABLE SPORTIFS MODIFY AGE NOT NULL;

-- 7. Modifier la longueur de l’attribut PRENOM (agrandir, réduire).

ALTER TABLE SPORTIFS MODIFY PRENOM VARCHAR(100);
ALTER TABLE SPORTIFS MODIFY PRENOM VARCHAR(50);

-- 8. Supprimer la colonne DATECREATION dans la table GYMNASE. Vérifier la suppression.

ALTER TABLE GYMNASES DROP COLUMN DATECREATION;

-- 9. Renommer la colonne ADRESSE dans la table GYMNASE par ADRESSEGYM. Vérifier.

 ALTER TABLE GYMNASES RENAME COLUMN ADRESSE TO ADRESSEGYM;

-- 10. Ajouter la contrainte suivante : L’attribut LIBELLE de la table SPORTS prend ses valeurs 
--dans le domaine {'Basket ball','Volley ball','Hand ball','Tennis', 'Hockey', 'Badmington','Ping pong','Football', 'Boxe'}.
 
ALTER TABLE SPORTS ADD constraint check_LIBELLE 
CHECK (LIBELLE IN('Basket ball','Volley ball','Hand ball','Tennis', 'Hockey', 'Badmington','Ping pong','Football', 'Boxe'));

select constraint_name, constraint_type from user_constraints where table_name=upper('SPORTS');

-- 11. Remplir toutes les tables par les instances représentées ci-dessus en exécutant le script insert.sql. Quels sont les problèmes rencontrés.

CREATE TABLE SPORTIFS(
    IDSPORTIF INTEGER,
    NOM VARCHAR(50),
    PRENOM VARCHAR(50),
    Sexe VARCHAR(1),
    AGE INTEGER,
    IDSPORTIFCONSEILLEUR INTEGER,
    constraint pk_SPORTIFS PRIMARY KEY (IDSPORTIF),
    constraint fk_SPORTIFS FOREIGN KEY (IDSPORTIFCONSEILLEUR)
    references SPORTIFS (IDSPORTIF)  on delete cascade,
    constraint check_SEXE CHECK (SEXE IN('F','M'))
);

INSERT INTO Sportifs VALUES(91,'BATERAOUI','Zinedine','M',30,98);
INSERT INTO Sportifs VALUES(37,'LAZARI','Malika','F',25,44);

CREATE TABLE SPORTS(
    IDSPORT INTEGER,
    LIBELLE VARCHAR(50),
    constraint pk_SPORTS PRIMARY KEY (IDSPORT)
);

CREATE TABLE GYMNASES(
    IDGYMNASE INTEGER,
    NOMGYMNASE VARCHAR(50),
    ADRESSE VARCHAR(50),
    VILLE VARCHAR(50),
    SURFACE NUMBER,
    constraint pk_GYMNASE PRIMARY KEY (IDGYMNASE)
);

CREATE TABLE ARBITRER(
    IDSPORTIF INTEGER,
    IDSPORT INTEGER,
    constraint fk_SPORTIFS_AR FOREIGN KEY (IDSPORTIF) references SPORTIFS(IDSPORTIF) on delete cascade,
    constraint fk_SPORTS_AR FOREIGN KEY (IDSPORT) references SPORTS(IDSPORT) on delete cascade,
    constraint pk_ARBITRER PRIMARY KEY (IDSPORTIF, IDSPORT)
);

CREATE TABLE ENTRAINER(
    IDSPORTIFENTRAINEUR INTEGER,
    IDSPORT INTEGER,
    constraint fk_SPORTIFS_EN FOREIGN KEY (IDSPORTIFENTRAINEUR) references SPORTIFS(IDSPORTIF) on delete cascade,
    constraint fk_SPORTS_EN FOREIGN KEY (IDSPORT) references SPORTS(IDSPORT) on delete cascade,
    constraint pk_ENTRAINER PRIMARY KEY (IDSPORTIFENTRAINEUR, IDSPORT)
);

CREATE TABLE JOUER(
    IDSPORTIF INTEGER,
    IDSPORT INTEGER,
    constraint fk_SPORTIFS_JOU FOREIGN KEY (IDSPORTIF) references SPORTIFS(IDSPORTIF) on delete cascade,
    constraint fk_SPORTS_JOU FOREIGN KEY (IDSPORT) references SPORTS(IDSPORT) on delete cascade,
    constraint pk_JOUER PRIMARY KEY (IDSPORTIF, IDSPORT)
);

CREATE TABLE SEANCES(
    IDGYMNASE INTEGER,
    IDSPORT INTEGER,
    IDSPORTIFENTRAINEUR INTEGER,
    JOUR VARCHAR(10),
    HORAIRE NUMBER,
    DUREE INT,
    constraint fk_IDGYMNASE FOREIGN KEY (IDGYMNASE) references GYMNASES(IDGYMNASE) on delete cascade,
    constraint fk_SPORTS_SE FOREIGN KEY (IDSPORT) references SPORTS(IDSPORT) on delete cascade,
    constraint fk_SPORTIFS_SE FOREIGN KEY (IDSPORTIFENTRAINEUR) references SPORTIFS(IDSPORTIF) on delete cascade,
    constraint pk_SEANCES PRIMARY KEY (IDGYMNASE, IDSPORT, IDSPORTIFENTRAINEUR, JOUR, HORAIRE),
    constraint check_JOUR CHECK (JOUR IN ('Samedi', 'Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'))
);


--------------------------Partie III : Langage de manipulation de données--------------------------


-- 12. Supposons que le sportif LACHEMI Bouzid a changé son conseillé par CHAADI Mourad. Que faut-il faire ?

UPDATE SPORTIFS
SET IDSPORTIFCONSEILLEUR = 
                        (
                            SELECT IDSPORTIF
                            FROM SPORTIFS 
                            WHERE nom = 'CHAADI' and prenom = 'Mourad')
WHERE nom = 'LACHEMI' AND prenom = 'Bouzid';

-- 13. Ajouter les deux sports ‘Natation’ et ‘Golf’. Désactiver la contrainte pour autoriser la modification. Réactiver la contrainte.
-- Désactiver la contrainte check_LIBELLE

ALTER TABLE SPORTS DISABLE constraint check_LIBELLE;

ALTER TABLE SPORTS 
DROP CONSTRAINT check_LIBELLE;

ALTER TABLE SPORTS
ADD CONSTRAINT check_LIBELLE 
CHECK (LIBELLE IN ('Basket ball','Volley ball','Hand ball','Tennis', 'Hockey', 'Badmington','Ping pong','Football', 'Boxe', 'Natation', 'Golf'));

ALTER TABLE SPORTS constraint check_LIBELLE;
select constraint_name, constraint_type from user_constraints where table_name=upper('SPORTS');

--Insertion

INSERT INTO Sports VALUES(10,'Natation');
INSERT INTO Sports VALUES(11,'Golf');

-- 14. Supprimer tous les gymnases dont la superficie est supérieure à 400 m². Quels sont les problèmes rencontrés.

DELETE FROM GYMNASES WHERE SURFACE > 400;


--------------------------Partie IV : Langage d’interrogation de données--------------------------


-- 15. Quels sont les sportifs (identifiant, nom et prénom) qui ont un âge entre 20 et 30 ans ?

SELECT IDSPORTIF, NOM, PRENOM, AGE FROM SPORTIFS WHERE AGE BETWEEN 20 AND 30;

-- 16. Quels sont les sportifs qui sont des conseillers ?

SELECT IDSPORTIF, NOM, PRENOM FROM SPORTIFS WHERE IDSPORTIF IN (SELECT DISTINCT IDSPORTIFCONSEILLEUR FROM SPORTIFS) ORDER BY IDSPORTIF;
SELECT DISTINCT IDSPORTIFCONSEILLEUR FROM SPORTIFS DESC;

SELECT DISTINCT s.IDSPORTIF, s.NOM, s.PRENOM 
FROM    SPORTIFS s, SPORTIFS p
WHERE s.IDSPORTIF = p.IDSPORTIFCONSEILLEUR ORDER BY s.IDSPORTIF;

-- 17. Quels entraîneurs n’entraînent que du hand ball ou du basket ball ?

SELECT IDSPORTIF, NOM, PRENOM FROM SPORTIFS WHERE IDSPORTIF IN (
SELECT DISTINCT IDSPORTIFENTRAINEUR 
FROM ENTRAINER
WHERE IDSPORT IN
(SELECT IDSPORT
FROM SPORTS 
WHERE LIBELLE = 'Hand ball' OR LIBELLE = 'Basket ball'));

-- 18. Quels sont les sportifs les plus jeunes?

SELECT 
IDSPORTIF, NOM, PRENOM, AGE 
FROM 
SPORTIFS 
WHERE 
AGE = (SELECT 
        MIN(AGE)
        FROM 
        SPORTIFS);

-- 19. Calculer la superficie moyenne des gymnases, pour chaque ville.

SELECT VILLE, AVG(SURFACE)
FROM GYMNASES 
GROUP BY VILLE;