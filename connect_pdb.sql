-- sqlplus sys@plug1 as sysdba
set verify off
col pdb new_value pdb noprint
alter session set container = &pdb_name;
select sys_context('userenv', 'con_name') as pdb from dual;
SET SQLPROMPT "_USER'@'_CONNECT_IDENTIFIER:&&pdb'>' "
undef pdb

