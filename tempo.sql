--Script para revisar el consumo de tablespace Temporal.

set lines 152
col FreeSpaceGB format 999.999
col UsedSpaceGB format 999.999
col TotalSpaceGB format 999.999
col host_name format a30
col tablespace_name format a30
select tablespace_name,
(free_blocks*8)/1024/1024 FreeSpaceGB,
(used_blocks*8)/1024/1024 UsedSpaceGB,
(total_blocks*8)/1024/1024 TotalSpaceGB,
i.instance_name,i.host_name
from gv$sort_segment ss,gv$instance i where ss.tablespace_name in (select tablespace_name from dba_tablespaces where contents='TEMPORARY') and
i.inst_id=ss.inst_id;