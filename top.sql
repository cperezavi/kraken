-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/top_sessions.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays information on all database sessions ordered by executions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @top_sessions.sql (reads, execs or cpu)
-- Last Modified: 21/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF
COLUMN username FORMAT A9
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20
COLUMN module FORMAT A45
COLUMN osuser FORMAT A9
COLUMN program FORMAT A45
SELECT NVL(a.username, '(oracle)') AS username,
       a.osuser,
       a.sid,
       a.serial#,
       c.value AS &1,
       a.lockwait,
       a.status,
       a.module,
       a.machine,
       a.program
FROM   v$session a,
       v$sesstat c,
       v$statname d
WHERE  a.sid = c.sid
AND    c.statistic#=d.statistic#
AND    d.name=DECODE(UPPER('&1'), 'READS', 'session logical reads','EXECS', 'execute count','CPU','CPU used by this session','CPU used by this session') 
ORDER BY c.value DESC;
