select x.job_name,b.state,b.job_mode,b.degree
, x.owner_name,z.sql_text, p.message
, p.totalwork, p.sofar
, round((p.sofar/p.totalwork)*100,2) done
, p.time_remaining
from dba_datapump_jobs b 
left join dba_datapump_sessions x on (x.job_name = b.job_name)
left join v$session y on (y.saddr = x.saddr)
left join v$sql z on (y.sql_id = z.sql_id)
left join v$session_longops p ON (p.sql_id = y.sql_id)
WHERE y.module='Data Pump Worker'
AND p.time_remaining > 0;