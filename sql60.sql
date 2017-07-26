---first capture Highest SQL using following Query for last 60 minutes.

set linesize 1000
select *
from (select s.BUFFER_GETS, s.DISK_READS ,nvl(s.sql_id,'null') as sql_id , Nvl(S.sql_text, 'NULL') AS SQL_text,
round(COUNT(*) / 60, 2) DB_TIME,
ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS PCT_LOAD
FROM V$active_Session_History A, v$SQL S
WHERE A.SQL_ID = S.SQL_ID
AND SAMPLE_TIME > SYSDATE - 60 / 24 / 60  
AND SESSION_TYPE <> 'BACKGROUND'
GROUP BY s.sql_id, s.SQL_text, s.BUFFER_GETS,s.DISK_READS
ORDER BY COUNT(*) DESC)
where rownum <= 1;