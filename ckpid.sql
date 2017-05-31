set verify off
col username format a13 heading 'DB User' trunc
col osuser   format a12 heading 'OS User' trunc
col sid format 9999 heading SID
col serial# format 99999 heading SRL#
col spid format a6 heading DBPROC
col process format a8 heading APPPROC
col machine format a10
col mins format 9990.9 heading 'Status|mins'
col program format a30 trunc
set pagesize 24
set linesize 1000
set pause 'Mash Enter...'
prompt User Processes Order by Status, Minutes in that status (desc), DB User
accept pid char prompt 'What is the DB PID to search for: '
select s.username, s.osuser, p.spid, s.process, s.sid,s.serial#, s.terminal,s.command,s.status,s.
machine,
    (s.last_call_et /60) mins,
       substr(substr(replace(s.program,'C:\'), instr(replace(s.program,'C:\'),'\')+1),
     instr(substr(replace(s.program,'C:\'), instr(replace(s.program,'C:\'),'\')+1)   ,'\'
)+1 ) program,
     s.sql_hash_value
 from  v$session s, v$process p
where s.paddr = p.addr
  and p.spid = &&pid
order by s.status, mins desc, username
/
