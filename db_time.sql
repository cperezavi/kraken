-- -----------------------------------------------------------------------------------
-- File Name    : db_time.sql
-- Author       : Vishal More
-- Description  : Display DB Time between two AWR snapshots.
-- Requirements : Access to the AWR views which requires an extra licence.
-- Call Syntax  : @db_time
-- Last Modified: 12-APR-2015
-- -----------------------------------------------------------------------------------

SELECT * FROM
(
SELECT 
  A.INSTANCE_NUMBER,
  LAG(A.SNAP_ID) OVER (ORDER BY A.SNAP_ID) BEGIN_SNAP_ID,
  A.SNAP_ID END_SNAP_ID,
  TO_CHAR(B.BEGIN_INTERVAL_TIME,'DD-MON-YY HH24:MI') SNAP_BEGIN_TIME,
  TO_CHAR(B.END_INTERVAL_TIME ,'DD-MON-YY HH24:MI') SNAP_END_TIME,
  ROUND((A.VALUE-LAG(A.VALUE) OVER (ORDER BY A.SNAP_ID ))/1000000/60,2) DB_TIME_MIN
FROM
DBA_HIST_SYS_TIME_MODEL A, DBA_HIST_SNAPSHOT B
WHERE
A.SNAP_ID = B.SNAP_ID AND
A.INSTANCE_NUMBER = B.INSTANCE_NUMBER AND
A.STAT_NAME = 'DB time'
)
WHERE DB_TIME_MIN IS NOT NULL AND DB_TIME_MIN > 0
ORDER BY 2 DESC;