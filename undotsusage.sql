REM +======================================================================+
REM																				
REM File Name: undotsusage.sql
REM 
REM Description:
REM   Query To check transacation/query exhausting the UNDO tablespace
REM   
REM Notes:
REM   Usage: sqlplus "/ as sysdba" @undotsusage.sql 
REM   
REM +======================================================================+

Clear columns
SET pages 100
SET Lines 280
select a.sid, a.serial#, a.username, b.used_urec, b.used_ublk
from   v$session a,
       v$transaction b
where  a.saddr = b.ses_addr
order by b.used_ublk desc;