alter session set container = freepdb1;

prompt create the demouser account ...
drop user if exists demouser cascade;
create user demouser identified by demouser
default tablespace users
quota 100m on users;

prompt role grants ...
grant soda_app to demouser;
grant db_developer_role to demouser;

prompt default role all ...
alter user demouser default role all;