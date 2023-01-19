--------------------------------------
------------------------Question TP2 :
--1
connect DBAGYMNASE/psw;


--2
create user ADMINGYM  identified by psw default tablespace GYMNASE_TBS temporary tablespace GYMNASE_TempTBS;


--3
grant create session to ADMINGYM;


--4
grant create table, create view, create user to ADMINGYM;

grant index on GYMNASES to ADMINGYM ;


--5
grant select on GYMNASES to public;


--6
connect ADMINGYM/psw

Select * from DBAGYMNASE.GYMNASES; 

alter user ADMINGYM quota unlimited on GYMNASE_TBS;
create index LIBELLE_IX on DBAGYMNASE.GYMNASES(VILLE);


--7
connect DBAGYMNASE/psw;
revoke select on GYMNASES from public;


--8
grant delete on GYMNASES to ADMINGYM;
grant select on SEANCES to ADMINGYM;

connect ADMINGYM/psw

delete from DBAGYMNASE.gymnases where  idgymnase not in (select  idgymnase
from  DBAGYMNASE.SEANCES);


--9
connect DBAGYMNASE/psw

create role GESTIONNAIRE_DES_GYMNASES;

connect system/Anouar33

select role from dba_roles where role='GESTIONNAIRE_DES_GYMNASES';

connect DBAGYMNASE/psw

grant select on SPORTIFS to GESTIONNAIRE_DES_GYMNASES;
grant select on SPORTS to GESTIONNAIRE_DES_GYMNASES;
grant update on ARBITRER to GESTIONNAIRE_DES_GYMNASES;

--Vérifier
select USERNAME, GRANTED_ROLE from user_role_privs;
select privilege, table_name from user_tab_privs where grantee='GESTIONNAIRE_DES_GYMNASES';

--10
connect DBAGYMNASE/psw

grant GESTIONNAIRE_DES_GYMNASES to ADMINGYM;

--vérification

connect system/Anouar33

select GRANTEE, GRANTED_ROLE from dba_role_privs where GRANTEE ='ADMINGYM';




--11. 
connect system/Anouar33
select privilege, table_name from user_tab_privs where grantee='ADMINGYM';

connect ADMINGYM/psw
select privilege, table_name from user_tab_privs where grantee='ADMINGYM';


--12
connect system/Anouar33
select privilege, admin_option from dba_sys_privs where grantee=upper('ADMINGYM');

connect ADMINGYM/psw
select privilege, admin_option from dba_sys_privs where grantee=upper('ADMINGYM');


--13
connect system/Anouar33
select * from dba_objects where owner ='ADMINGYM';

select object_type, object_name from dba_objects where owner ='ADMINGYM';

connect ADMINGYM/psw
select * from dba_objects where owner ='ADMINGYM';

--------------------------------------
------------------------Question TP3 :
--1
connect DBAGYMNASE/psw
show user


--2
SELECT table_name from user_tables;


--3
select constraint_name, constraint_type from user_constraints where table_name=upper('SPORTIFS');

--4
desc SPORTS


--5
select owner from all_tables where table_name = 'SPORTS';