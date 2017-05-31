set pagesize 1000
set linesize 150
set long 1000
col metadata for a145
select dbms_metadata.get_ddl(object_type => 'SYNONYM', 
                             name =>  synonym_name, 
                             schema =>'PUBLIC') || '/' metadata
from dba_synonyms
where owner = 'PUBLIC'
  and table_owner = upper('&OWNER')
  and table_owner not in ('SYS', 'SYSTEM', 'SYSMAN')
order by synonym_name;