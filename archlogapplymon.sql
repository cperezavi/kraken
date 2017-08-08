REM +======================================================================+
REM																				
REM File Name: archlogapplymon.sql
REM 
REM Description:
REM   Query To Get Archive Log Apply Rate Speed of a standby Database
REM   
REM Notes:
REM   Usage: sqlplus "/ as sysdba" @archlogapplymon.sql 
REM
REM   
REM +======================================================================+

set linesize 400
col Values for a70
col Recovery_start for a21
select to_char(START_TIME,'dd.mm.yyyy hh24:mi:ss') "Recovery_start",
to_char(item)||' = '||to_char(sofar)||' '||to_char(units)||' '|| to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') "Values" 
from v$recovery_progress 
where start_time=(select max(start_time) from v$recovery_progress);