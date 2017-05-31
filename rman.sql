select to_char(sysdate, 'DD-MON-YY HH24:MI:SS') "Fecha" from dual;
set linesize 1000
column opname format a50;
alter session set nls_date_format='dd/mm/yy hh24:mi:ss';
select SID,SERIAL#, START_TIME,OPNAME ,      
sysdate + TIME_REMAINING/3600/24 end_at,
ROUND(SOFAR/TOTALWORK*100,2) "%COMPLETE"
from v$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%';

set linesize 10000;
alter session set nls_date_format='DD-MON-YYYY hh24:mi:ss';
select SID,OPERATION,STATUS,round(MBYTES_PROCESSED/1024,2) as GByte ,START_TIME,END_TIME,
 OBJECT_TYPE,OUTPUT_DEVICE_TYPE from v$rman_status
where STATUS='RUNNING' and OPERATION IN('BACKUP')
order by START_TIME asc;
