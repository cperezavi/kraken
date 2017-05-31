SELECT PID, PROGRAM, TRACEFILE FROM V$PROCESS;

select
p.pid orapid
from v$process p, v$session s
where s.sid = &SID
and p.addr = s.paddr
/

oradebug oraospid 34275448
oradebug setorapid 37;
oradebug event 10046 trace name context forever, level 12;
oradebug unlimit;
oradebug tracefile_name;

select
p.pid pid,
p.spid ospid,
s.sid sid,s.serial# from v$process p, v$session s
where s.sid = &1
and p.addr = s.paddr;