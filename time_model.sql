-- -----------------------------------------------------------------------------------
-- File Name    : time_model.sql
-- Author       : Vishal More
-- Description  : Display Time Model Statistics bwtween two AWR snapshots.
-- Requirements : Access to the AWR views which requires an extra licence.
-- Call Syntax  : @time_model
-- Last Modified: 15-APR-2015
-- -----------------------------------------------------------------------------------

SELECT a.STAT_NAME,
  ROUND((b.VALUE -a.VALUE)/1000000,2) "Time(s)"
FROM SYS.DBA_HIST_SYS_TIME_MODEL a,
  SYS.DBA_HIST_SYS_TIME_MODEL b
WHERE a.snap_id                        = &start_snap_id
AND b.snap_id                          = &end_snap_id
AND a.STAT_NAME                        = b.STAT_NAME
AND ROUND((b.VALUE -a.VALUE)/1000000,2)>0
ORDER BY 2 DESC;