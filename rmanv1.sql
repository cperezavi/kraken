set feedback on;
set linesize 1000;
set pagesize 150;
alter session set nls_date_format = 'DD-MM-YYYY hh24:mi:ss';
select to_char(sysdate, 'DD-MON-YY HH24:MI:SS') "Fecha" from dual;
col filename format a95
col bytes format a4
col inst format a3
col BUFFER_COUNT format a3
select inst_id "Instancia", sid, 'sync', status, round(BYTES/1024/1024,0) as GB, filename, BUFFER_COUNT as count, BUFFER_SIZE, buffer_size*buffer_count buffer_mem, substr(device_type,1,10) as device_type 
from gv$backup_sync_io
where status = 'IN PROGRESS'
union
select inst_id "Instancia",sid, 'async',status, round(BYTES/1024/1024/1024,0) as GB, filename, BUFFER_COUNT as count, BUFFER_SIZE, buffer_size*buffer_count buffer_mem, substr(device_type,1,10) as device_type 
from gv$backup_async_io
where status = 'IN PROGRESS'
order by device_type;

SELECT inst_id "Instancia", event, TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED, AVERAGE_WAIT, TIME_WAITED_MICRO, sysdate as SNAPSHOT_TIME
FROM gv$system_event
WHERE event LIKE 'Backup%';

COLUMN EVENT FORMAT a55
COLUMN SECONDS_IN_WAIT FORMAT 9999
COLUMN STATE FORMAT a20
COLUMN CLIENT_INFO FORMAT a30
COLUMN SPID format 999999
SELECT p.inst_id "Instancia", p.SPID, s.EVENT, s.SECONDS_IN_WAIT AS SEC_WAIT, 
       sw.STATE, s.CLIENT_INFO
FROM   gV$SESSION_WAIT sw, gV$SESSION s, gV$PROCESS p
WHERE  sw.EVENT LIKE '%MML%'
AND    s.SID=sw.SID
AND    s.PADDR=p.ADDR
and p.inst_id =  s.inst_id
and s.event like '%MML%';

column opname format a50;
select INST_ID as "Instancia", SID,SERIAL#, START_TIME "Hora Inicio",  OPNAME "Operacion" , sysdate + TIME_REMAINING/3600/24 "Hora Fin", ROUND(SOFAR/TOTALWORK*100,2) "%Completado"
from gv$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%';

select inst_id "Instancia", sid, CLIENT_INFO "channel", seq#, event, state, wait_time_micro/1000000 "Segundos"
from gv$session where program like '%rman%' and wait_time = 0 and not action is null;

select SID,OPERATION,STATUS,round(MBYTES_PROCESSED/1024,0) as GByte ,START_TIME "Hora Inicio", END_TIME "Hora Fin", OBJECT_TYPE "Tipo Objeto", OUTPUT_DEVICE_TYPE "Device Output"
from v$rman_status
where STATUS='RUNNING' and OPERATION IN('RESTORE','BACKUP')
order by START_TIME asc;

set linesize 1000
column Pct_Complete format 99.99
column client_info format a15
column sid format 9999999
column MB_X_SEG format 99999.99
column inst_id format a3
select s.client_info "Canal",
l.sofar,
l.totalwork,
round (l.sofar / l.totalwork*100,2) "%Completado",
aio.MB_X_SEG,
aio.LONG_WAIT_PCT
from gv$session_longops l,
gv$session s,
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
