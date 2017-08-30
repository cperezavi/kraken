set lines 1000
set pagesize 1000
col OPERATION for a30
col TARGET for a5
col START_TIME for a40
col END_TIME for a40

--SQL> EXECUTE dbms_stats.gather_dictionary_stats;

select inst_id, sid, sofar, totalwork, units, start_time, time_remaining, message  
from gv$session_longops
where opname = 'Gather Dictionary Schema Statistics';


select * from dba_optstat_operations order by start_time desc;