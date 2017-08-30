set linesize 1000
col opname for a25

select inst_id, sid, opname, sofar, totalwork,units,start_time,time_remaining,message  
from gv$session_longops
where opname like 'Gather%';

select inst_id, a.sid, a.serial#, b.status, a.opname,
to_char(a.start_time,' dd-mon-yyyy hh24:mi:ss') start_time,
to_char(a.last_update_time,' dd-mon-yyyy hh24:mi:ss') last_update_time,
a.time_remaining as "Time Remaining Sec" ,
a.time_remaining/60 as "Time Remaining Min",
a.time_remaining/60/60 as "Time Remaining HR"
from gv$session_longops a, gv$session b
where a.sid = b.sid
and a.sid =&sid
And time_remaining > 0;

select *
from gv$session_longops
where opname like 'Gather%' 
order by sid;

select operation, target , start_time
from dba_optstat_operations
where  operation in ('gather_dictionary_stats','gather_database_stats','gather_schema_stats')
ORDER BY start_time;