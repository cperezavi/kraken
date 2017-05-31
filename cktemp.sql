set linesize 1000;
column SID_SERIAL format a15;
column OSUSER format a15;
column USERNAME format a15;
column MODULE format a55;
column PROGRAM format a40;
column TABLESPACE format a20;
set pages 1000;
SELECT   s.sid || ',' || s.serial# sid_serial, s.username, s.osuser, s.module,
s.program, SUM (t.blocks) * tbs.block_size/1024/1024 mb_used, t.tablespace,
COUNT(*) sort_ops, t.segtype
FROM v$sort_usage t, v$session s, dba_tablespaces tbs, v$process p
WHERE t.session_addr = s.saddr
AND s.paddr = p.addr
AND t.tablespace = tbs.tablespace_name
GROUP BY s.sid, s.serial#, s.username, s.osuser, p.spid, s.module,
s.program, tbs.block_size, t.tablespace,t.segtype
ORDER BY mb_used DESC;