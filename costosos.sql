select count(1), s.sql_hash_value, sw.event   
from v$session s, v$session_wait sw   
where s.sid=sw.sid  and sw.event!='SQL*Net message from client'
group by s.sql_hash_value,sw.event   
order by 3 desc;

 
select * from table(dbms_xplan.display_cursor(&hash));