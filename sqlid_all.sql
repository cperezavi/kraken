set pagesize  200
set verify    off
set feedback  off
set linesize 1000

select status, sid, key, sql_id, sql_text, sql_plan_hash_value, sql_child_address, elapsed_time, cpu_time, fetches, buffer_gets, disk_reads
from v$sql_monitor 
where status = 'EXECUTING';
