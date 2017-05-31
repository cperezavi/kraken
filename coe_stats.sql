/*$Header: coe_stats.sql 12.1 156968.1 2010/01/05 csierra coe $*/
SET TERM OFF VER OFF ECHO OFF FEED OFF TRIMS ON;
/*=============================================================================

coe_stats.sql - Automates CBO Stats Gathering using FND_STATS and Table sizes

 Overview
 --------
    coe_stats.sql verifies the statistics in the data dictionary for all tables
    owned by installed Oracle Apps modules.  It generates a dynamic script
    coe_fix_stats.sql and a report COE_STATS.TXT.

    The generated report COE_STATS.TXT contains the list of tables that need
    to be analyzed.

    The dynamic script generated coe_fix_stats.sql includes the commands to
    execute the FND_STATS package to gather the statistics based on the number
    of days since last analyzed and the size of the table.

    The following ranges, percentages and frequencies are suggested, and must
    be reviewed and adjusted by each client according to specific needs:

 1. No statistics: Sample 30%.

 2. NumRows between 0 and 1M: Sample 100% every 3 weeks.

 3. NumRows between 1M and 10M: Sample 30% every 4 weeks.

 4. NumRows between 10M and 100M: Sample 10% every 5 weeks.

 5. NumRows between 100M and 1B: Sample 3% every 6 weeks.

 6. NumRows greater than 1B: Sample 1% every 7 weeks.

 Instructions
 ------------
 1. Review and adjust ranges, percentages and frequencies accordingly.
    Then run coe_stats.sql connectes as apps with no parameters:

    # sqlplus apps/apps
    SQL> START coe_stats.sql;

 2. Review spooled output file COE_STATS.TXT file.  The spool file gets
    created on same directory from which this script is executed.
    On NT, files may get created under $ORACLE_HOME/bin.

 3. This script coe_stats.sql executes at the end the dynamically generated
    script coe_fix_stats.sql.  If you want to disable the automatic execution
    of the generated script refreshing your stats, delete the line at the end
    containing the execution command 'START coe_fix_stats;'.

 Program Notes
 -------------
 1. Always download latest version from Note:156968.1

 2. This script can be used on any Oracle Apps 11i/R12 database.

 3. This coe_stats.sql script should be run at least once per week, during a
    quiet period (low load).

 4. Be aware that deleting or gathering stats of any object, may cause any
    parsed SQL statement referencing that object to be invalidated from the
    shared pool or library cache.  This means that deleting or gathering stats
    should be done during a quiet period in order to reduce users impact.

 Parameters
 ----------
    None.

 Caution
 -------
    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.

=============================================================================*/

SET TERM ON VER OFF ECHO OFF FEED OFF TRIMS ON;
PRO
PRO Generating COE staging tables...
PRO
SET TERM OFF;

VARIABLE v_degree VARCHAR2;
BEGIN
    SELECT TO_CHAR(GREATEST(MIN(TO_NUMBER(value) * 2), 1))
      INTO :v_degree
      FROM v$parameter
     WHERE NAME IN ('parallel_max_servers','cpu_count');
END;
/

DROP   TABLE coe_schemas;
CREATE TABLE coe_schemas (
  owner VARCHAR2(30)
);

DROP   TABLE coe_tables;
CREATE TABLE coe_tables (
  owner         VARCHAR2(30),
  table_name    VARCHAR2(30),
  num_rows      NUMBER,
  last_analyzed DATE,
  percent       NUMBER,
  partitioned   VARCHAR2(3)
);

INSERT INTO coe_schemas
SELECT oracle_username
  FROM applsys.fnd_oracle_userid
 WHERE oracle_id BETWEEN 900 AND 999
   AND read_only_flag = 'U'
 UNION
SELECT a.oracle_username
  FROM applsys.fnd_oracle_userid a,
       applsys.fnd_product_installations b
 WHERE a.oracle_id = b.oracle_id;

INSERT INTO coe_tables
SELECT dt.owner,
       dt.table_name,
       dt.num_rows,
       dt.last_analyzed,
       CASE
       WHEN dt.num_rows IS NULL OR dt.last_analyzed IS NULL THEN 30
       WHEN dt.num_rows BETWEEN 0 AND 1e6 THEN 100
       WHEN dt.num_rows BETWEEN 1e6 AND 1e7 THEN 30
       WHEN dt.num_rows BETWEEN 1e7 AND 1e8 THEN 10
       WHEN dt.num_rows BETWEEN 1e8 AND 1e9 THEN 3
       ELSE 1 END percent,
       dt.partitioned
  FROM dba_tables  dt,
       coe_schemas cs
 WHERE cs.owner = dt.owner
   AND (dt.iot_type IS NULL OR dt.iot_type <> 'IOT_OVERFLOW')
   AND dt.temporary = 'N'
   AND (dt.num_rows IS NULL OR
        dt.last_analyzed IS NULL OR
        dt.last_analyzed < SYSDATE - 49 OR
        (dt.num_rows BETWEEN 0 AND 1e6 AND dt.last_analyzed < SYSDATE - 21) OR
        (dt.num_rows BETWEEN 1e6 AND 1e7 AND dt.last_analyzed < SYSDATE - 28) OR
        (dt.num_rows BETWEEN 1e7 AND 1e8 AND dt.last_analyzed < SYSDATE - 35) OR
        (dt.num_rows BETWEEN 1e8 AND 1e9 AND dt.last_analyzed < SYSDATE - 42)
       )
   AND NOT EXISTS (
SELECT NULL
  FROM applsys.fnd_exclude_table_stats fets
 WHERE fets.table_name = dt.table_name )
   AND NOT EXISTS (
SELECT NULL
 FROM dba_external_tables de
WHERE de.table_name = dt.table_name
  AND de.owner = dt.owner )
;

SET TERM ON;
PRO
PRO Generating coe_fix_stats.sql script...
PRO
SET TERM OFF;

SET VER OFF ECHO OFF FEED OFF TRIMS ON HEAD OFF PAGES 0 LIN 300;
COL dummy1 FORMAT A100 NOPRINT;
SPOOL coe_fix_stats.sql;
SELECT
    LPAD(NVL(num_rows, 0), 15, '0')||
    LPAD(99999 - NVL(ROUND(SYSDATE - last_analyzed), 99999), 5, '0')||
    owner||table_name||'1' dummy1,
    '-- Table:'||owner||'.'||table_name||
    ' NumRows:'||num_rows||
    ' Partitioned:'||partitioned||
    ' LastAnalyzed:'||TO_CHAR(last_analyzed, 'DD-MON-YY HH24:MI:SS')||
    ' AgeDays:'||ROUND(SYSDATE - last_analyzed)
FROM coe_tables
UNION ALL
SELECT
    LPAD(NVL(num_rows, 0), 15, '0')||
    LPAD(99999 - NVL(ROUND(SYSDATE - last_analyzed), 99999), 5, '0')||
    owner||table_name||'2' dummy1,
    SUBSTR('EXEC apps.fnd_stats.gather_table_stats('||
    'ownname=>'''||owner||''','||
    'tabname=>'''||table_name||''','||
    'percent=>'||TO_CHAR(percent)||','||
    'degree=>'||
    (CASE WHEN NVL(num_rows, 0) < 100000 THEN '1' ELSE :v_degree END)||','||
    'granularity=>''DEFAULT'');',1,300)
FROM coe_tables
ORDER BY 1;
SPOOL OFF;

COL module FORMAT A30 HEADING 'Module';
COL module_total FORMAT 99,999,999 HEADING 'Tables|Requiring|Stats|Gathering';
COL last_analyzed_date FORMAT A14 HEADING 'Last Analyzed';
COL tables FORMAT 999,999 HEADING 'Tables';

SET HEAD ON PAGES 1000 FEED ON TERM ON;
SPOOL coe_stats.txt;
SELECT COUNT(*) module_total
FROM coe_tables;

SELECT NVL(TO_CHAR(last_analyzed, 'YYYY-MM-DD'), '0000-00-00') last_analyzed_date,
       COUNT(*) tables
  FROM coe_tables
 GROUP BY NVL(TO_CHAR(last_analyzed, 'YYYY-MM-DD'), '0000-00-00')
 ORDER BY NVL(TO_CHAR(last_analyzed, 'YYYY-MM-DD'), '0000-00-00');

SELECT COUNT(*) module_total, SUBSTR(owner, 1, 30) module
FROM coe_tables
GROUP BY owner
ORDER BY module_total DESC;

SET PAGES 0 ECHO ON TIM ON;
START coe_fix_stats.sql;
SPOOL OFF;
SET VER ON TRIMS OFF PAGES 24 LIN 80 TIM OFF;
CL COL;
DROP TABLE coe_schemas;
DROP TABLE coe_tables;
