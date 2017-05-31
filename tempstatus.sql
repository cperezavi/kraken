SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Temporary Sort Users                                        |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN instance_name      FORMAT a8                 HEADING 'Instance'
COLUMN tablespace_name    FORMAT a15                HEADING 'Tablespace Name'
COLUMN sid                FORMAT 99999              HEADING 'SID'
COLUMN serial_id          FORMAT 99999999           HEADING 'Serial ID'
COLUMN session_status     FORMAT a9                 HEADING 'Status'
COLUMN oracle_username    FORMAT a18                HEADING 'Oracle User'
COLUMN os_username        FORMAT a18                HEADING 'O/S User'
COLUMN os_pid             FORMAT a8                 HEADING 'O/S PID'
COLUMN session_terminal   FORMAT a10                HEADING 'Terminal'         TRUNC
COLUMN session_machine    FORMAT a30                HEADING 'Machine'          TRUNC
COLUMN session_program    FORMAT a20                HEADING 'Session Program'  TRUNC
COLUMN contents           FORMAT a9                 HEADING 'Contents'
COLUMN extents            FORMAT 999,999,999        HEADING 'Extents'
COLUMN blocks             FORMAT 999,999,999        HEADING 'Blocks'
COLUMN bytes              FORMAT 999,999,999,999    HEADING 'Bytes'
COLUMN segtype            FORMAT a12                HEADING 'Segment Type'

BREAK ON instance_name SKIP PAGE

SELECT
    i.instance_name       instance_name
  , t.tablespace          tablespace_name
  , s.sid                 sid
  , s.serial#             serial_id
  , s.status              session_status
  , s.username            oracle_username
  , s.osuser              os_username
  , p.spid                os_pid
  , s.program             session_program
  , t.contents            contents
  , t.segtype             segtype
  , (t.blocks * c.value)/1024/1024  bytes
FROM
    gv$instance     i
  , gv$session      s
  , gv$process      p
  , gv$sort_usage   t
  , (select value from v$parameter
     where name = 'db_block_size') c
WHERE
      s.inst_id = p.inst_id
  AND p.inst_id = i.inst_id
  AND t.inst_id = i.inst_id
  AND s.inst_id = i.inst_id
  AND s.saddr = t.session_addr
  AND s.paddr = p.addr
ORDER BY
    i.instance_name
  , s.sid;
