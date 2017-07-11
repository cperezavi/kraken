col STATUS format a9
col hrs format 999.99
select SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi') end_time,
round(elapsed_seconds/3600,0) hrs 
from V$RMAN_BACKUP_JOB_DETAILS
where INPUT_TYPE = 'DB FULL' and STATUS='COMPLETED'
order by session_key;

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