REM srdc_db_rman_performance - collect rman performance information
define SRDCNAME='RMAN_PERFORMANCE_'
SET MARKUP HTML ON PREFORMAT ON
set TERMOUT off FEEDBACK off VERIFY off TRIMSPOOL on HEADING off
COLUMN SRDCSPOOLNAME NOPRINT NEW_VALUE SRDCSPOOLNAME
select 'SRDC_'||upper('&&SRDCNAME')||'_'||upper(instance_name)||'_'||to_char(sysdate,'YYYYMMDD_HH24MISS') SRDCSPOOLNAME from v$instance;
set TERMOUT on MARKUP html preformat on 
REM
spool &&SRDCSPOOLNAME..htm
select '+----------------------------------------------------+' from dual
union all
select '| Diagnostic-Name: '||'&&SRDCNAME' from dual
union all
select '| Timestamp:'||to_char(systimestamp,'YYYY-MM-DD HH24:MI:SS TZH:TZM') from dual
union all
select '| Machine:'||host_name from v$instance
union all
select '| Version:'||version from v$instance
union all
select '| DBName:'||name from v$database
union all
select '| Instance:'||instance_name from v$instance
union all
select '+----------------------------------------------------+' from dual
set pagesize 50000;
set echo on;
set feedback on;
Column session_id format 9999999 heading "SESS|ID"
Column session_serial# format 9999999 heading "SESS|SER|#"
Column event format a40
Column total_waits format 9,999,999,999 heading "TOTAL|TIME|WAITED|MICRO"
alter session set nls_date_format='dd/mm/yy hh24miss';
SELECT sid, spid, client_info
FROM v$process p, v$session s
WHERE p.addr = s.paddr
AND client_info LIKE '%id=rman%';

select SID, START_TIME,TOTALWORK, sofar, (sofar/totalwork) * 100 done,
sysdate + TIME_REMAINING/3600/24 end_at
from v$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%';

alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24MISS';
SELECT set_count, device_type, type, substr(filename,1,90) filename,
buffer_size, buffer_count, open_time, close_time
FROM v$backup_async_io
where type != 'AGGREGATE'
ORDER BY set_count,type, open_time, close_time;

Select session_id, session_serial#, Event, sum(time_waited) total_waits
From v$active_session_history
Where sample_time > sysdate - 1
And program like '%rman%'
And session_state='WAITING' And time_waited > 0
Group by session_id, session_serial#, Event
Order by session_id, session_serial#, total_waits desc;
exit;