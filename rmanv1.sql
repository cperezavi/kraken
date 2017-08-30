set feedback on;
set linesize 1000;
set pagesize 650;
alter session set nls_date_format = 'DD-MM-YYYY hh24:mi:ss';
select to_char(sysdate, 'DD-MON-YY HH24:MI:SS') "Fecha" from dual;
col filename format a70
col bytes format a4
col inst format a3
col BUFFER_COUNT format a3
select inst_id "Instancia", sid, 'sync', status, round(BYTES/1024/1024/1024,0) GB, filename, BUFFER_COUNT "#Buffers", BUFFER_SIZE "Buffer Size", buffer_size*buffer_count "Total Buffer", substr(device_type,1,10) device_type
from gv$backup_sync_io
where status = 'IN PROGRESS'
union
select inst_id "Instancia", sid, 'async' ,status, round(BYTES/1024/1024/1024,0) GB, filename, BUFFER_COUNT "#Buffers", BUFFER_SIZE "Buffer Size", buffer_size*buffer_count "Total Buffer", substr(device_type,1,10) device_type
from gv$backup_async_io
where status = 'IN PROGRESS'
order by device_type;

column opname format a40;
select sysdate "Fecha", inst_id "Instancia", sid, start_time "Hora Inicio Canal", opname "Operacion", sysdate + TIME_REMAINING/3600/24 "Hora Fin Canal", round(SOFAR/TOTALWORK*100,0) "%Completado"
from gv$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%';

select sysdate "Fecha", start_time "Inicio Respaldo", sid, operation "Operacion", status "Estatus", round(MBYTES_PROCESSED/1024,0) "GB", object_type "Tipo Objeto", output_device_type "Device Output"
from v$rman_status
where status in ('RUNNING','RUNNING WITH ERRORS') and operation IN('BACKUP')
order by start_time asc;

select sysdate "Fecha", start_time "Inicio Respaldo", round(INPUT_BYTES/1024/1024/1024,0) "Input GB", round(OUTPUT_BYTES/1024/1024/1024,0) "Output GB", round(INPUT_BYTES/1024/1024/1024,0)
 - round(OUTPUT_BYTES/1024/1024/1024,0) "Diferencia GB", INPUT_TYPE "Tipo Respaldo", round(ELAPSED_SECONDS/60,0) "Minutos", OUTPUT_DEVICE_TYPE "Device Output"
from V$RMAN_BACKUP_JOB_DETAILS
where status in('RUNNING','RUNNING WITH ERRORS') and input_type LIKE 'DB%';

set linesize 1000
column Pct_Complete format 99.99
column client_info format a10
column sid format 9999999
column MB_X_SEG format 99999.99
column inst_id format a3
select sysdate "Fecha",
s.client_info "Canal",
l.sofar "Realizado",
l.totalwork "Total",
round (l.sofar / l.totalwork*100,0) "%Completado",
aio.MB_X_SEG,
aio.LONG_WAIT_PCT
from gv$session_longops l, gv$session s,
(select sid,
serial,
100* sum (long_waits) / sum (io_count) as "LONG_WAIT_PCT",
sum (effective_bytes_per_second)/1024/1024 as "MB_X_SEG"
from gv$backup_async_io
group by sid, serial) aio
where aio.sid = s.sid
and aio.serial = s.serial#
and l.opname like 'RMAN%'
and l.opname not like '%aggregate%'
and l.totalwork != 0
and l.sofar <> l.totalwork
and s.sid = l.sid
and s.serial# = l.serial#
order by 1;

col dbsize_Gbytes      for 999,999,990 justify right head "DB Size GB"
col input_Gbytes       for 999,999,990 justify right head "Read GB"
col output_Gbytes      for 999,999,990 justify right head "Written GB"
col output_device_type for a10 justify left head "Device Output"
col complete           for 990 justify right head "%Completado" 
col est_complete       for a20 head "Fecha Estimada Fin"
col recid              for 9999999 head "IDRMAN"
select sysdate "Fecha"
, recid
, output_device_type
, dbsize_gbytes
, trunc(round (input_bytes/1024/1024/1024,0)) input_gbytes
, trunc(round(output_bytes/1024/1024/1024,0)) output_gbytes
, round (input_bytes/1024/1024/1024,0) - round(output_bytes/1024/1024/1024,0) "Diferiencia"
, round((mbytes_processed/1024/dbsize_gbytes*100),1) complete
, start_time "Inicio Respaldo"
, to_char(start_time + (sysdate-start_time)/(mbytes_processed/1024/dbsize_gbytes),'DD-MM-YYYY HH24:MI:SS') est_complete
from v$rman_status rs , (select sum(bytes)/1024/1024/1024 dbsize_gbytes from v$datafile) 
where status IN('RUNNING','RUNNING WITH ERRORS') and output_device_type is not null;

col inst_id for 990 justify right head "Instancia"
select sysdate "Fecha", inst_id, pool "Pool", round(bytes/1024/1024,0) "Free Memory MB"
from gv$sgastat
where name Like '%free memory%' and pool='large pool'
order by inst_id asc;

exit;
