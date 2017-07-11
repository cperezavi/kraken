-- ===================================================================
--
--   Script Name:  rman_backup_progress.sql
--        Author:  Robert Taylor
--        Run as:  DBA user
--
--   Description:
--   ------------
--
--   Outputs information on RMAN backups that are currently running.
--
-- ===================================================================

col dbsize_mbytes      for 99,999,990.00 justify right head "DBSIZE_MB"
col input_mbytes       for 99,999,990.00 justify right head "READ_MB"
col output_mbytes      for 99,999,990.00 justify right head "WRITTEN_MB"
col output_device_type for a10           justify left head "DEVICE"
col complete           for 990.00        justify right head "COMPLETE %" 
col compression        for 990.00        justify right head "COMPRESS|% ORIG"
col est_complete       for a20           head "ESTIMATED COMPLETION"
col recid              for 9999999       head "ID"

prompt
prompt  ============================================================================
prompt  . Current backup session details
prompt  ============================================================================

col event for a40
col client_info for a30

select client_info
     , event 
  from v$session 
 where event like 'Backup%'
 order by client_info;
 
prompt
prompt  ============================================================================
prompt  . Backup progress
prompt  ============================================================================

select recid
     , output_device_type
     , dbsize_mbytes
     , input_bytes/1024/1024 input_mbytes
     , output_bytes/1024/1024 output_mbytes
     , (output_bytes/input_bytes*100) compression
     , (mbytes_processed/dbsize_mbytes*100) complete
     , to_char(start_time + (sysdate-start_time)/(mbytes_processed/dbsize_mbytes),'DD-MON-YYYY HH24:MI:SS') est_complete
  from v$rman_status rs
     , (select sum(bytes)/1024/1024 dbsize_mbytes from v$datafile) 
 where status='RUNNING'
   and output_device_type is not null
/
