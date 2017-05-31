SET ver OFF term OFF feed OFF pages 255 lin 255 trims ON;
/*=============================================================================

bde_request.sql - Process and Session info for one Concurrent Request (11.5)

*************************************************************
This article is being delivered in Draft form and may contain
errors. Please use the MetaLink "Feedback" button to advise
Oracle of any issues related to this article.
*************************************************************


Overview
--------

Displays Process and Session details for one Concurrent Request.


Instructions
------------

1. Copy this whole Note, from '/*$Header', into a text file and name it bde_request.sql.

2. Open a SQL*Plus session connecting as APPS and execute:

SQL> START bde_request.sql 


Program Notes
-------------

1. Always download latest version from Metalink (Note:187504.1)

2. This script has been tested up to Oracle Apps 11.5.10.2 with Oracle 10.2.0.3

3. It executes bde_session.sql (Note:169630.1) at the end, if present.

4. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

5. A practical guide in Troubleshooting Oracle ERP Applications Performance
Issues can be found on Metalink under Note:169935.1


Parameters
----------

1. REQUEST_ID - Concurrent Request ID


Caution
-------

The sample program in this article is provided for educational purposes
only and is NOT supported by Oracle Support Services. It has been tested
internally, however, and works as documented. We do not guarantee that it
will work for you, so be sure to test it in your environment before
relying on it.


=============================================================================*/

SET ver OFF term ON feed OFF pages 255 lin 255 trims ON;
PROMPT Usage:
PROMPT sqlplus apps/apps
PROMPT SQL> START bde_request.sql 
PROMPT
SET term OFF;

DEF p_request_id = &1;

COL p_requested_by NEW_VALUE p_requested_by -
FORMAT 999999999999999;
COL p_phase_code NEW_VALUE p_phase_code -
FORMAT A1;
COL p_status_code NEW_VALUE p_status_code -
FORMAT A1;
COL p_program_application_id NEW_VALUE p_program_application_id -
FORMAT 999999999999999;
COL p_concurrent_program_id NEW_VALUE p_concurrent_program_id -
FORMAT 999999999999999;
COL p_controlling_manager NEW_VALUE p_controlling_manager -
FORMAT 999999999999999;
COL p_oracle_process_id NEW_VALUE p_oracle_process_id -
FORMAT A30;
COL p_oracle_session_id NEW_VALUE p_oracle_session_id -
FORMAT 999999999999999;
COL p_executable_application_id NEW_VALUE p_executable_application_id -
FORMAT 999999999999999;
COL p_executable_id NEW_VALUE p_executable_id -
FORMAT 999999999999999;
COL p_addr NEW_VALUE p_addr -
FORMAT A8;
COL p_sid NEW_VALUE p_sid -
FORMAT 99999;

COL request_id FORMAT 9999999999;
COL request_date FORMAT A20;
COL requested_by FORMAT 999999999999;
COL phase_code FORMAT A10;
COL status_code FORMAT A11;
COL requested_start_date FORMAT A20;
COL program_application_id FORMAT 9999999999999999999999;
COL concurrent_program_id FORMAT 999999999999999999999;
COL controlling_manager FORMAT 9999999999999999999;
COL actual_start_date FORMAT A20;
COL actual_completion_date FORMAT A22;
COL current_date FORMAT A20;
COL duration FORMAT 99999.99;
COL logfile_name FORMAT A70;
COL outfile_name FORMAT A70;
COL oracle_process_id FORMAT A17;
COL oracle_session_id FORMAT 99999999999999999;
COL os_process_id FORMAT A13;
COL enable_trace FORMAT A12;

COL user_id FORMAT 999999999999;
COL user_name FORMAT A20;
COL description FORMAT A60;

COL lookup_type FORMAT A11;
COL meaning FORMAT A11;

COL application_id FORMAT 99999999999999;
COL concurrent_program_name FORMAT A23;
COL executable_application_id FORMAT 9999999999999999999999999;
COL executable_id FORMAT 9999999999999;
COL optimizer_mode FORMAT A14;

COL language FORMAT A20;
COL user_concurrent_program_name FORMAT A80;

COL executable_name FORMAT A15;
COL execution_file_name FORMAT A19;
COL subroutine_name FORMAT A15;

COL concurrent_process_id FORMAT 999999999999999999999;
COL session_id FORMAT 999999999999999;
COL node_name FORMAT A20;
COL db_name FORMAT A8;
COL db_domain FORMAT A30;
COL logfile_name FORMAT A70;

COL addr FORMAT A8;
COL pid FORMAT 99999999;
COL spid FORMAT A9;
COL serial# FORMAT 9999999999;

COL saddr FORMAT A8;
COL sid FORMAT 9999999999;
COL serial# FORMAT 9999999999;
COL audsid FORMAT 9999999999;
COL paddr FORMAT A8;
COL process FORMAT A9;
COL module FORMAT A24;
COL action FORMAT A32;
COL client_info FORMAT A64;


SELECT requested_by p_requested_by,
phase_code p_phase_code,
status_code p_status_code,
program_application_id p_program_application_id,
concurrent_program_id p_concurrent_program_id,
controlling_manager p_controlling_manager,
oracle_process_id p_oracle_process_id,
oracle_session_id p_oracle_session_id
FROM fnd_concurrent_requests
WHERE request_id = TO_NUMBER('&p_request_id');

SELECT executable_application_id p_executable_application_id,
executable_id p_executable_id
FROM fnd_concurrent_programs
WHERE application_id = &p_program_application_id
AND concurrent_program_id = &p_concurrent_program_id;

SELECT addr p_addr
FROM v$process
WHERE spid = '&p_oracle_process_id';

SELECT sid p_sid
FROM v$session
WHERE paddr = '&p_addr';


SPOOL bde_request.txt;
SET term ON;

PROMPT
PROMPT
PROMPT FND_CONCURRENT_REQUESTS
PROMPT =======================
PROMPT

SELECT request_id,
requested_by,
phase_code,
status_code,
program_application_id,
concurrent_program_id,
controlling_manager,
oracle_process_id,
oracle_session_id,
os_process_id,
enable_trace
FROM fnd_concurrent_requests
WHERE request_id = TO_NUMBER('&p_request_id');

PROMPT
PROMPT REQUESTED_BY ref FND_USER.USER_ID
PROMPT PHASE_CODE ref FND_LOOKUPS.LOOKUP_CODE (LOOKUP_TYPE = 'CP_PHASE_CODE')
PROMPT STATUS_CODE ref FND_LOOKUPS.LOOKUP_CODE (LOOKUP_TYPE = 'CP_STATUS_CODE')
PROMPT PROGRAM_APPLICATION_ID ref FND_CONCURRENT_PROGRAMS.APPLICATION_ID
PROMPT CONCURRENT_PROGRAM_ID ref FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID
PROMPT CONTROLLING_MANAGER ref FND_CONCURRENT_PROCESSES.CONCURRENT_PROCESS_ID
PROMPT ORACLE_PROCESS_ID ref V$PROCESS.SPID (identifies SQL Trace filename)
PROMPT ORACLE_SESSION_ID ref V$SESSION.AUDSID
PROMPT
PROMPT OS_PROCESS_ID is Operating System Process ID for Concurrent Program
PROMPT

SELECT request_id,
TO_CHAR( request_date, 'DD-MON-YYYY HH24:MI:SS' )
request_date,
TO_CHAR( requested_start_date,'DD-MON-YYYY HH24:MI:SS' )
requested_start_date,
TO_CHAR( actual_start_date, 'DD-MON-YYYY HH24:MI:SS' )
actual_start_date,
TO_CHAR( actual_completion_date, 'DD-MON-YYYY HH24:MI:SS' )
actual_completion_date,
TO_CHAR( sysdate, 'DD-MON-YYYY HH24:MI:SS' )
current_date,
ROUND( ( NVL( actual_completion_date, sysdate ) - actual_start_date ) * 24, 2 )
duration
FROM fnd_concurrent_requests
WHERE request_id = TO_NUMBER('&p_request_id');

SELECT request_id,
logfile_name,
outfile_name,
oracle_process_id
FROM fnd_concurrent_requests
WHERE request_id = TO_NUMBER('&p_request_id');

PROMPT
PROMPT ORACLE_PROCESS_ID identifies SQL Trace filename under udump directory
PROMPT


PROMPT
PROMPT
PROMPT FND_USER
PROMPT ========
PROMPT

SELECT user_id,
user_name,
description
FROM fnd_user
WHERE user_id = &p_requested_by;


PROMPT
PROMPT
PROMPT FND_LOOKUPS
PROMPT ===========
PROMPT

SELECT SUBSTR(flu1.lookup_type,4,11) lookup_type,
fcr.phase_code,
flu1.meaning,
SUBSTR(flu2.lookup_type,4,11) lookup_type,
fcr.status_code,
flu2.meaning
FROM fnd_concurrent_requests fcr,
fnd_lookups flu1,
fnd_lookups flu2
WHERE fcr.request_id = TO_NUMBER('&p_request_id')
AND flu1.lookup_type = 'CP_PHASE_CODE'
AND fcr.phase_code = flu1.lookup_code
AND flu2.lookup_type = 'CP_STATUS_CODE'
AND fcr.status_code = flu2.lookup_code;


PROMPT
PROMPT
PROMPT FND_CONCURRENT_PROGRAMS
PROMPT =======================
PROMPT

SELECT application_id,
concurrent_program_id,
concurrent_program_name,
executable_application_id,
executable_id,
enable_trace,
optimizer_mode
FROM fnd_concurrent_programs
WHERE application_id = &p_program_application_id
AND concurrent_program_id = &p_concurrent_program_id;

PROMPT
PROMPT EXECUTABLE_APPLICATION_ID ref FND_EXECUTABLES.APPLICATION_ID
PROMPT EXECUTABLE_ID ref FND_EXECUTABLES.EXECUTABLE_ID
PROMPT


PROMPT
PROMPT
PROMPT FND_CONCURRENT_PROGRAMS_TL
PROMPT ==========================
PROMPT

SELECT application_id,
concurrent_program_id,
language,
user_concurrent_program_name
FROM fnd_concurrent_programs_tl
WHERE application_id = &p_program_application_id
AND concurrent_program_id = &p_concurrent_program_id
AND language = USERENV('LANG');


PROMPT
PROMPT
PROMPT FND_EXECUTABLES
PROMPT ===============
PROMPT

SELECT application_id,
executable_id,
executable_name,
execution_file_name,
subroutine_name
FROM fnd_executables
WHERE application_id = &p_executable_application_id
AND executable_id = &p_executable_id;


PROMPT
PROMPT
PROMPT FND_CONCURRENT_PROCESSES
PROMPT ========================
PROMPT

SELECT concurrent_process_id,
session_id,
TO_CHAR( oracle_process_id ) oracle_process_id,
os_process_id,
node_name,
db_name,
db_domain
FROM fnd_concurrent_processes
WHERE concurrent_process_id = TO_NUMBER( TO_CHAR( '&p_controlling_manager' ) );

PROMPT
PROMPT OS_PROCESS_ID is Operating System Process ID for Concurrent Manager
PROMPT

SELECT concurrent_process_id,
logfile_name
FROM fnd_concurrent_processes
WHERE concurrent_process_id = TO_NUMBER( TO_CHAR( '&p_controlling_manager' ) );


PROMPT
PROMPT
PROMPT V$PROCESS
PROMPT =========
PROMPT

SELECT addr,
pid,
spid,
serial#
FROM v$process
WHERE spid = '&p_oracle_process_id';


PROMPT
PROMPT
PROMPT V$SESSION
PROMPT =========
PROMPT


SELECT saddr,
sid,
serial#,
audsid,
paddr,
process
FROM v$session
WHERE paddr = '&p_addr'
AND audsid = TO_NUMBER( TO_CHAR( '&p_oracle_session_id' ) );

PROMPT
PROMPT PADDR ref V$PROCESS.ADDR
PROMPT

SELECT saddr,
sid,
serial#,
module,
action,
client_info
FROM v$session
WHERE paddr = '&p_addr'
AND audsid = TO_NUMBER( TO_CHAR( '&p_oracle_session_id' ) );

SPOOL OFF;
SET ver ON feed ON pages 24 lin 80 trims OFF;
PROMPT
PROMPT Executing bde_session.sql for sid &p_sid
PROMPT
START bde_session.sql &p_sid;
PROMPT
COLUMN ENDEDCR FORMAT A21 HEADING 'bde_request.sql ended';
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') ENDEDCR FROM SYS.DUAL;
