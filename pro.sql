set linesize 1000
SELECT item,
TO_CHAR(sofar)||' '||TO_CHAR(units)||' '|| TO_CHAR(timestamp,'DD-MON-RR HH24:MI:SS') Description
FROM v$recovery_progress
WHERE start_time=(SELECT MAX(start_time) FROM v$recovery_progress);