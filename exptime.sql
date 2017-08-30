set linesize 1000
column opname format a30;
alter session set nls_date_format='dd/mm/yy hh24:mi:ss';
SELECT SID,SERIAL#,CONTEXT,OPNAME,SOFAR,TOTALWORK,
       ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM V$SESSION_LONGOPS
WHERE OPNAME LIKE 'SYS_IMPORT_TABLE_01%'
  AND OPNAME NOT LIKE '%aggregate%'
  AND TOTALWORK != 0
  AND SOFAR  != TOTALWORK; 

select inst_id,function_name,
sum(small_read_megabytes+large_read_megabytes) as read_mb,
sum(small_write_megabytes+large_write_megabytes) as write_mb
from gv$iostat_function
where function_name='Data Pump'
group by cube (inst_id,function_name) 
order by inst_id,function_name;