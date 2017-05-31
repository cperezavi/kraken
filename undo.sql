set linesize 1000;
SELECT c.username, a.sid, c.program, b.name , a.value 
FROM v$sesstat a, v$statname b, v$session c 
WHERE a.statistic# = b.statistic# 
AND a.sid = c.sid 
AND b.name like '%undo%' 
AND a.value > 0 and username is not null
ORDER BY value DESC;