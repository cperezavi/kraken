set linesize 1000
SELECT ses.sid,  
ses.serial#, ses.username, machine, status,LOCKWAIT,COMMAND
FROM v$session ses,  
v$process pro 
WHERE ses.paddr = pro.addr 
AND pro.spid IN (SELECT oracle_process_id  
FROM apps.fnd_concurrent_requests  
WHERE request_id = '&request_id');
