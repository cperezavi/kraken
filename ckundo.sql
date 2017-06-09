set verify off
set linesize 1000
set pagesize 1000
accept sid char prompt 'What is the SID to search for: '
select sid, sql_text
from gv$session s, gv$sql q
where sid in (&sid)
and (
   q.sql_id = s.sql_id or
   q.sql_id = s.prev_sql_id);