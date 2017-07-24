SET MARKUP HTML ON SPOOL ON
SET TERMOUT OFF
SET PAGESIZE 1000
SET LINESIZE 300
SET TRIMOUT ON
SET TERMOUT ON
set pages 999
set feedback off
break on db_name page
alter session set nls_date_format='DD-MON-YY HH24:MI:SS';
spool backup_report.html

SET MARKUP HTML ENTMAP OFF
PROMPT <H2><center><b> RMAN Backup  details  </b></center></H2>
SET MARKUP HTML ENTMAP ON
SET VERIFY    off
SET lines 132 pages 9999 feedback off

COLUMN start_time   format date heading 'Start Date'
COLUMN end_time     format date heading 'End Date'
COLUMN input_bytes  format 999,999,999,999 heading 'Input GBytes'
COLUMN output_bytes format 999,999,999,999 heading 'Output GBytes'
COLUMN cstatus      format a40 heading 'Status'
COLUMN object_type  format a10 heading 'Backup Type'
COLUMN time_taken_display  format a40  heading 'Time Taken'
COLUMN cstatus ENTMAP OFF

select object_type, start_time, end_time, input_bytes/1024/1024/1024 "GBytes Input", output_bytes/1024/1024/1024 "GBytes Ouput",
(case
when status like '%WARN%' then '<font color="orange">COMPLETED</font>'
when status like 'COMPLETED' then '<font color="green">COMPLETED</font>'
when status like 'RUNNING' then '<font color="black">COMPLETED</font>'
ELSE '<font color="red">FAILED</font>'
END) cstatus
from v$rman_status
where object_type = 'DB FULL'
and operation not in ('RESTORE VALIDATE')
order by start_time desc;
SET MARKUP HTML ENTMAP OFF
spool off;
exit;
