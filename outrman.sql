set lines 2000
set pages 5000
select output
from GV$RMAN_OUTPUT
where session_recid = 9102
and session_stamp = 950647866
order by recid;