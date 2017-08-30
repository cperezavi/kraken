SET SERVEROUTPUT ON

-- Tuning task created for specific a statement from the AWR.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          begin_snap  => ,
                          end_snap    => ,
                          sql_id      => '5pysskyvturj9',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => '5pysskyvturj9_AWR',
                          description => 'Tuning task for statement 5pysskyvturj9 in AWR.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => '5pysskyvturj9_AWR');

SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 200
SELECT DBMS_SQLTUNE.report_tuning_task('5pysskyvturj9_AWR') AS recommendations FROM dual;
SET PAGESIZE 24	


##########################################################################################################
##########################################################################################################
##########################################################################################################
select SID, SERIAL#, INST_ID, USERNAME, STATUS, PROGRAM, SQL_ID, event
 from gv$session 
where username = 'REPORTS'
and status = 'ACTIVE' ;

SET SERVEROUTPUT ON
declare
stmt_task VARCHAR2(40);
begin
stmt_task := DBMS_SQLTUNE.CREATE_TUNING_TASK(sql_id => '4vbyjm9pqnm9h', time_limit => 4000, scope => DBMS_SQLTUNE.scope_comprehensive);
DBMS_OUTPUT.put_line('task_id: ' || stmt_task );
end;
/


begin
DBMS_SQLTUNE.EXECUTE_TUNING_TASK(task_name => '&&task_id');
end;
/

SELECT TASK_NAME, STATUS FROM DBA_ADVISOR_LOG WHERE TASK_NAME = '&&task_id'; 

SET LONG 1000000000
SET LONGCHUNKSIZE 30000
SET LINESIZE 30000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('&&task_id') AS recommendations FROM dual;


##################################################################################################################
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SPOOL /home/oracle/report_sql_detail_f4xzjsxf75jng.html
SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => 'f4xzjsxf75jng',
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;
SPOOL OFF;
exit;

##################################################################################################################
col opname for a20
col ADVISOR_NAME for a20
SELECT SID,SERIAL#,USERNAME,OPNAME,ADVISOR_NAME,TARGET_DESC,START_TIME SOFAR, TOTALWORK 
FROM   V$ADVISOR_PROGRESS 
WHERE  USERNAME = 'SYS';