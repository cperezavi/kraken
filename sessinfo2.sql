set linesize 150
set verify off
set long 50000

column username format a20
column program format a15
column osuser format a15
column machine format a25
column sql_id new_value v_sql_id
column spid format a6
column sql_child_number new_value  v_sql_child_number

select sess.sid, sess.serial#, prc.spid, sess.username, sess.program, sess.osuser, 
       sess.machine, sess.sql_id, sess.sql_child_number
from gv$session sess, gv$process prc
where sess.inst_id = prc.inst_id
      and sess.paddr = prc.addr
      and sess.sid = '&sid'
      and sess.inst_id = &inst;

select sql_fulltext
from gv$sqlarea
where sql_id = '&v_sql_id';      

select * 
from table(dbms_xplan.display_cursor('&v_sql_id', &v_sql_child_number));

