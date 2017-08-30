set linesize 10000
col status format a25
col hrs format 999.99
COL in_sec format a10
COL out_sec format a10
COL time_taken_display format a10
col start_time format a20
col end_time format a20
select session_key, session_stamp, input_type, status, 
to_char(start_time,'dd/mm/yyyy hh24:mi') start_time,
to_char(end_time,'dd/mm/yyyy hh24:mi') end_time,
round(output_bytes/1024/1024/1024,0) GBytes,
round(elapsed_seconds/60,0) minutos,
round(elapsed_seconds/3660,1) horas,
time_taken_display,
INPUT_BYTES_PER_SEC_DISPLAY in_sec,
OUTPUT_BYTES_PER_SEC_DISPLAY out_sec
from V$RMAN_BACKUP_JOB_DETAILS
where input_type like 'DB%'
order by session_key desc;

set lines 2000
set pages 5000
select output
from gv$rman_output
where session_recid = 9102
and session_stamp = 950647866
order by recid;

select
session_recid,
session_stamp,
to_char(START_time,'dd-mon-rrrr hh24:mi:ss') as rman_START_time,
to_char(end_time,'dd-mon-rrrr hh24:mi:ss') as rman_end_time,
time_taken_display Time_taken,
input_bytes/1024/1024/1024 INPUT_size_gig,
output_bytes/1024/1024/1024 OUTPUT_size_gig,
compression_ratio,
INPUT_BYTES_PER_SEC_DISPLAY read_rate_per_second,
OUTPUT_BYTES_PER_SEC_DISPLAY write_rate_per_second,
status,
input_type
from v$rman_backup_job_details
where session_recid='9096'
order by start_time desc;

set linesize 1000
set pagesize 50
col dbsize_Gbytes      for 99,999,990 justify right head "DBSIZE_GB"
col input_Gbytes       for 99,999,990 justify right head "READ_GB"
col output_Gbytes      for 99,999,990 justify right head "WRITTEN_GB"
col output_device_type for a10           justify left head "DEVICE"
col complete           for 990        justify right head "COMPLETE %" 
col compression        for 990        justify right head "COMPRESS|% ORIG"
col est_complete       for a20           head "ESTIMATED COMPLETION"
col recid              for 9999999       head "ID"
select recid
, output_device_type
, dbsize_gbytes
, trunc(round (input_bytes/1024/1024/1024,0)) input_mbytes
, trunc(round(output_bytes/1024/1024/1024,0)) output_mbytes
, (output_bytes/input_bytes*100) compression
, round((mbytes_processed/1024/dbsize_gbytes*100),0) complete
, to_char(start_time + (sysdate-start_time)/(mbytes_processed/1024/dbsize_gbytes),'DD-MON-YYYY HH24:MI:SS') est_complete, sysdate as FECHA
from v$rman_status rs , (select sum(bytes)/1024/1024/1024 dbsize_gbytes from v$datafile) 
where status='RUNNING' and output_device_type is not null;

select spid,pga_used_mem,pga_max_mem from v$process where addr in
(select paddr from v$session where program like '%rman%')
order by pga_used_mem desc ;

select s.inst_id "Instancia", spid, s.sid, s.program, trunc(pga_used_mem/1024/1024) "USED(MB)",
trunc(pga_alloc_mem/1024/1024) "ALLOCATED(MB)" , trunc(pga_max_mem/1024/1024) "MAX(MB)"
from gv$process p,gv$session s
where pga_alloc_mem > 1048576
and p.addr = s.paddr and s.program like '%rman%'
order by s.inst_id asc;
  
https://hongwang.wordpress.com/2014/09/14/tuning-rman-backuprestore-with-memory-settings/
  