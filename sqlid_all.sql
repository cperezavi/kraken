set pagesize  200
set verify    off
set feedback  off
set linesize 1000

select status, sid, key, sql_id, sql_text, sql_plan_hash_value, sql_child_address, elapsed_time, cpu_time, fetches, buffer_gets, disk_reads
from v$sql_monitor 
where status = 'EXECUTING';

select plan_line_id, plan_operation || ' ' || plan_options operation, starts, output_rows 
from v$sql_plan_monitor where sql_id = '' 
and key = 
order by plan_line_id;

select sql_text, sql_id, plan_hash_value, child_address, hash_value, child_number
from v$sql where plan_hash_value = ; 

select sql_text, sql_id, plan_hash_value, child_address, hash_value, child_number
from v$sql where sql_id = ''; 

