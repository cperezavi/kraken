select s1.username || '@' || s1.machine || ' ( SID=' || s1.sid || ' ) is blocking ' || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' 
AS blocking_status 
from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2 
where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 
and l2.request > 0 and l1.id1 = l2.id1 and l2.id2 = l2.id2
/