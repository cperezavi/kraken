SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET LINESIZE 1000
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF
SPOOL /home/oracle/reporte_aj8cbuvdjrybs.htm
SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => 'aj8cbuvdjrybs',
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;
SPOOL OFF;

SET SERVEROUTPUT ON

DECLARE
  l_taskname     VARCHAR2(30)   := 'Accessadvisor_PDORA08K';
  l_task_desc    VARCHAR2(128)  := 'SQL Access Task PDORA08K';
  l_wkld_name    VARCHAR2(30)   := 'test_work_load';
  l_saved_rows   NUMBER         := 0;
  l_failed_rows  NUMBER         := 0;
  l_num_found    NUMBER;
BEGIN
  -- Create a SQL Access Advisor task.
  DBMS_ADVISOR.create_task (
    advisor_name => DBMS_ADVISOR.sqlaccess_advisor,
    task_name    => l_taskname,
    task_desc    => l_task_desc);
    
  -- Reset the task.
  DBMS_ADVISOR.reset_task(task_name => l_taskname);

  -- Create a workload.
  SELECT COUNT(*)
  INTO   l_num_found
  FROM   user_advisor_sqlw_sum
  WHERE  workload_name = l_wkld_name;

  IF l_num_found = 0 THEN
    DBMS_ADVISOR.create_sqlwkld(workload_name => l_wkld_name);
  END IF;

  -- Link the workload to the task.
  SELECT count(*)
  INTO   l_num_found
  FROM   user_advisor_sqla_wk_map
  WHERE  task_name     = l_taskname
  AND    workload_name = l_wkld_name;
  
  IF l_num_found = 0 THEN
    DBMS_ADVISOR.add_sqlwkld_ref(
      task_name     => l_taskname,
      workload_name => l_wkld_name);
  END IF;
  
  -- Set workload parameters.
  DBMS_ADVISOR.set_sqlwkld_parameter(l_wkld_name, 'ACTION_LIST', DBMS_ADVISOR.ADVISOR_UNUSED);
  DBMS_ADVISOR.set_sqlwkld_parameter(l_wkld_name, 'MODULE_LIST', DBMS_ADVISOR.ADVISOR_UNUSED);
  DBMS_ADVISOR.set_sqlwkld_parameter(l_wkld_name, 'SQL_LIMIT', DBMS_ADVISOR.ADVISOR_UNLIMITED);
  DBMS_ADVISOR.set_sqlwkld_parameter(l_wkld_name, 'ORDER_LIST', 'PRIORITY,OPTIMIZER_COST');
  DBMS_ADVISOR.set_sqlwkld_parameter(l_wkld_name, 'USERNAME_LIST', DBMS_ADVISOR.ADVISOR_UNUSED);
  DBMS_ADVISOR.set_sqlwkld_parameter(l_wkld_name, 'VALID_TABLE_LIST', DBMS_ADVISOR.ADVISOR_UNUSED);

  DBMS_ADVISOR.import_sqlwkld_sqlcache(l_wkld_name, 'REPLACE', 2, l_saved_rows, l_failed_rows);

  -- Set task parameters.
  DBMS_ADVISOR.set_task_parameter(l_taskname, '_MARK_IMPLEMENTATION', 'FALSE');
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'EXECUTION_TYPE', 'INDEX_ONLY');
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'MODE', 'COMPREHENSIVE');
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'STORAGE_CHANGE', DBMS_ADVISOR.ADVISOR_UNLIMITED);
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'DML_VOLATILITY', 'TRUE');
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'ORDER_LIST', 'PRIORITY,OPTIMIZER_COST');
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'WORKLOAD_SCOPE', 'PARTIAL');
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'DEF_INDEX_TABLESPACE', DBMS_ADVISOR.ADVISOR_UNUSED);
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'DEF_INDEX_OWNER', DBMS_ADVISOR.ADVISOR_UNUSED);
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'DEF_MVIEW_TABLESPACE', DBMS_ADVISOR.ADVISOR_UNUSED);
  DBMS_ADVISOR.set_task_parameter(l_taskname, 'DEF_MVIEW_OWNER', DBMS_ADVISOR.ADVISOR_UNUSED);

  -- Execute the task.
  DBMS_ADVISOR.execute_task(task_name => l_taskname);
END;
/

-- Display the resulting script.
SET LONG 100000
SET PAGESIZE 50000
SELECT DBMS_ADVISOR.get_task_script('Accessadvisor_PDORA08K') AS script
FROM   dual;
SET PAGESIZE 24

