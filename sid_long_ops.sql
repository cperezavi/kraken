set lines 200
col OPNAME for a25

select inst_id "Instancia", a.sid, a.serial#, b.status, a.opname, to_char(a.START_TIME,' dd-Mon-YYYY HH24:mi:ss') START_TIME, 
to_char(a.LAST_UPDATE_TIME,' dd-Mon-YYYY HH24:mi:ss') LAST_UPDATE_TIME, a.time_remaining as "Time Remaining Sec" , 
a.time_remaining/60 as "Time Remaining Min", a.time_remaining/60/60 as "Time Remaining HR" 
from gv$session_longops a, gv$session b
where a.sid = b.sid
and a.sid =&sid
and time_remaining > 0;