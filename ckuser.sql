set verify off
col status format a8
col username format a13 heading 'DB User' trunc
col osuser   format a12 heading 'OS User' trunc
col sid format 9999 heading SID
col serial# format 99999 heading SRL#
col spid format a6 heading DBPROC
col process format a10 heading APPPROC
col mins format 9990.9 heading 'Status|mins'
col program format a20 trunc
set linesize 1000
set pause on
set pause 'Hit Enter...'
prompt User Processes Order by Status, Minutes in that status (desc), DB User
accept srchuser char prompt 'What is the DB/OS username to search for: '
select s.username, s.osuser, p.spid, s.process, s.sid, s.serial#, s.terminal, s.status,
    (s.last_call_et /60) mins,
       substr(substr(replace(s.program,'C:\'), instr(replace(s.program,'C:\'),'\')+1),
     instr(substr(replace(s.program,'C:\'), instr(replace(s.program,'C:\'),'\')+1)   ,'\')+1 ) program,
     s.sql_hash_value, to_char(s.logon_time,'dd-mm-rrrr hh24:mi:ss') ini_sess,s.module
 from  v$session s, v$process p
where s.type = 'USER'
  and s.paddr = p.addr
  and (s.username like upper('%&&srchuser%')
       or upper(s.osuser) like upper('%&&srchuser%'))
order by s.status, mins desc, username
/
set pause off
