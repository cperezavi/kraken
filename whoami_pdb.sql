set line 232
col os_pid for a7
col tracefile for a80 
col username for a15
col con_name for a10
SELECT distinct s.con_id, c.con_name, s.username, s.user#, s.sid, s.serial#, s.prev_hash_value, schemaname, p.spid os_pid
 FROM V$SESSION S, v$process p, v$active_services c,
(SELECT sid FROM v$mystat WHERE rownum=1) sid
 WHERE audsid = SYS_CONTEXT('userenv','sessionid')
 and p.addr = s.paddr
 and sid.sid = s.sid
 and s.username is not null
and s.con_id=c.con_id
and s.con_id=p.con_id
-- and sid.con_id=s.con_id
/
