select name,bytes from
(select name, bytes
from v$datafile
union all
select name, bytes
from v$tempfile
union all
select lf.member "name", l.bytes
from v$logfile lf
, v$log l
where lf.group# = l.group#
union all
select name, 0
from v$controlfile) 
/

COLUMN "Total Mb" FORMAT 999,999,999.0
COLUMN "Redo Mb" FORMAT 999,999,999.0
COLUMN "Temp Mb" FORMAT 999,999,999.0
COLUMN "Data Mb" FORMAT 999,999,999.0

Prompt
Prompt "Database Size"

select (select sum(bytes/1048576) from dba_data_files) "Data Mb",
(select NVL(sum(bytes/1048576),0) from dba_temp_files) "Temp Mb",
(select sum(bytes/1048576)*max(members) from v$log) "Redo Mb",
(select sum(bytes/1048576) from dba_data_files) +
(select NVL(sum(bytes/1048576),0) from dba_temp_files) +
(select sum(bytes/1048576)*max(members) from v$log) "Total Mb"
from dual;