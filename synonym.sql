Synonyms - Create public synonyms for all objects in current schema that dont already have a public
set echo off
--
--  Name: c_pubsynonyms.sql
--
--  Description: Synonyms - Create public synonyms for all objects in current schema that don't already have a public synonym
--
--  Usage: @c_pubsynonyms
--
set termout off
set verify off
set doc off
set feedback off
set recsep off
set pagesize 0
--
define lsize=200
set linesize &&lsize
--
define out_file=c_pubsynonyms.ddl
spool &&out_file
--
SELECT 'create public synonym '||rtrim(OBJECT_NAME)||' for '||user|| '.' ||rtrim(OBJECT_NAME)||';'
FROM user_objects
WHERE object_type IN ('TABLE','PACKAGE','PROCEDURE','FUNCTION','VIEW','SEQUENCE')
AND not exists (SELECT null
                FROM   dba_synonyms
                WHERE  owner = 'PUBLIC'
                  AND  dba_synonyms.synonym_name = user_objects.object_name
                  AND  dba_synonyms.table_owner  = user);
spool off
set doc off
set feedback on
set pagesize 30
set termout on
set echo on
start &&out_file
-- exit


set pages 0 lines 200 trims on verify off feedback off
accept grants_to  prompt 'Enter user to grant privileges: '
accept schema     prompt 'Enter schema on which to grant: '
spool tmpgrants.sql
select 'grant select on '||owner||'.'||table_name ||' to &grants_to;', chr(10),
       'create synonym &grants_to..'||table_name ||' for '||owner||'.'||table_name||';', chr(10)
from  dba_tables
where owner = upper('&schema')
union all
select 'grant select on '||owner||'.'||view_name ||' to &grants_to;', chr(10),
       'create synonym &grants_to..'||view_name ||' for '||owner||'.'||view_name||';', chr(10)
from  dba_views
where owner = upper('&schema')
;
spool off
set pages 99 lines 80 verify on feedback on
prompt "Run tmpgrants.sql if you are satistified with the script…"
