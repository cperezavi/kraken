/*$Header: bde_last_analyzed.sql 163208.1 2008/04/25 csierra $*/

DEF SCHEMA = ALL
--DEF SCHEMA = APPLSYS

SET TERM OFF
SET FEED OFF
SET VER OFF
SET PAGES 50000
SET LIN 10000
SET HEA OFF
SET TRIMS ON

DROP TABLE bde_schemas;
DROP TABLE bde_tables_summary;
DROP TABLE bde_indexes_summary;

DROP TABLE bde_tables;
DROP TABLE bde_indexes;
DROP TABLE bde_tab_partitions;
DROP TABLE bde_ind_partitions;

/******************************************************************************/

SET TERM ON
PRO Generating BDE_TABLES staging table...
SET TERM OFF
CREATE TABLE bde_tables AS
SELECT
owner,
table_name,
ini_trans,
max_trans,
freelists,
freelist_groups,
logging,
num_rows,
blocks,
empty_blocks,
avg_space,
chain_cnt,
avg_row_len,
degree,
cache,
sample_size,
last_analyzed,
partitioned,
iot_type,
temporary,
global_stats
FROM all_tables
WHERE owner = DECODE(UPPER('&&SCHEMA'), 'ALL', owner, UPPER('&&SCHEMA'));

SET TERM ON
PRO Generating BDE_INDEXES staging table...
SET TERM OFF
CREATE TABLE bde_indexes AS
SELECT
owner,
index_name,
index_type,
table_owner,
table_name,
uniqueness,
ini_trans,
max_trans,
freelists,
freelist_groups,
logging,
blevel,
leaf_blocks,
distinct_keys,
avg_leaf_blocks_per_key,
avg_data_blocks_per_key,
clustering_factor,
status,
num_rows,
sample_size,
last_analyzed,
degree,
partitioned,
temporary,
global_stats,
domidx_status,
funcidx_status
FROM all_indexes
WHERE owner = DECODE(UPPER('&&SCHEMA'), 'ALL', owner, UPPER('&&SCHEMA'));

SET TERM ON
PRO Generating BDE_TAB_PARTITIONS staging table...
SET TERM OFF
CREATE TABLE bde_tab_partitions AS
SELECT
table_owner,
table_name,
composite,
partition_name,
subpartition_count,
partition_position,
ini_trans,
max_trans,
freelists,
freelist_groups,
logging,
num_rows,
blocks,
empty_blocks,
avg_space,
chain_cnt,
avg_row_len,
sample_size,
last_analyzed,
global_stats
FROM all_tab_partitions
WHERE table_owner = DECODE(UPPER('&&SCHEMA'), 'ALL', table_owner, UPPER('&&SCHEMA'));

SET TERM ON
PRO Generating BDE_IND_PARTITIONS staging table...
SET TERM OFF
CREATE TABLE bde_ind_partitions AS
SELECT
index_owner,
index_name,
composite,
partition_name,
subpartition_count,
partition_position,
status,
ini_trans,
max_trans,
freelists,
freelist_groups,
logging,
blevel,
leaf_blocks,
distinct_keys,
avg_leaf_blocks_per_key,
avg_data_blocks_per_key,
clustering_factor,
num_rows,
sample_size,
last_analyzed,
global_stats
FROM all_ind_partitions
WHERE index_owner = DECODE(UPPER('&&SCHEMA'), 'ALL', index_owner, UPPER('&&SCHEMA'));

/******************************************************************************/

SET TERM ON
PRO Generating BDE_TABLES spool file...
SET TERM OFF
SPO bde_last_analyzed_tables.html
PRO <html><!-- $Header: bde_last_analyzed.sql 163208.1 2005/06/27 csierra $ -->
PRO <head><title>BDE_LAST_ANALYZED_TABLES</title>
PRO <meta http-equiv="CONTENT-TYPE" content="TEXT/HTML; CHARSET=US-ASCII">
PRO <style type="text/css">
PRO a:active {color:#ff6600}
PRO a:link {color:#663300}
PRO a:visited {color:#996633}
PRO body {font-family:courier new,monospace,arial,helvetica;font-size:9pt;background-color:#ffffff}
PRO h1 {font-size:16pt;color:#336699;font-weight:bold}
PRO h2 {font-size:14pt;color:#336699;font-weight:bold}
PRO h3 {font-size:12pt;color:#336699;font-weight:bold}
PRO h4 {font-size:10pt;color:#336699;font-weight:bold}
PRO table {font-size:8pt;text-align:center}
PRO th {background-color:#cccc99;color:#336699;vertical-align:bottom;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td {background-color:#f7f7e7;color:#000000;vertical-align:top;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td.left {text-align:left}
PRO td.right {text-align:right}
PRO td.title {font-weight:bold;text-align:right;background-color:#cccc99;color:#336699}
PRO td.white {background-color:#ffffff}
PRO font.footer {font-style:italic;color:#999999}
PRO </style>
PRO </head><body>
PRO <h1>BDE_LAST_ANALYZED_TABLES Report</h1>
PRO <h2>Tables</h2>
PRO <table>
PRO <tr>
PRO <th>Owner.Table Name</th>
PRO <th>Last<br>Analyzed</th>
PRO <th>Sample<br>Size</th>
PRO <th>Num<br>Rows</th>
PRO <th>Blocks</th>
PRO <th>Global<br>Stats</th>
PRO <th>Empty<br>Blocks</th>
PRO <th>Avg<br>Space</th>
PRO <th>Chain<br>Cnt</th>
PRO <th>Avg<br>Row<br>Len</th>
PRO <th>Logging</th>
PRO <th>Degree</th>
PRO <th>Cache</th>
PRO <th>Partitioned</th>
PRO <th>IOT<br>Type</th>
PRO <th>Temporary</th>
PRO <th>Ini<br>Trans</th>
PRO <th>Max<br>Trans</th>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'.'||table_name||'</td>'||
'<td nowrap>'||TO_CHAR(last_analyzed, 'DD-MON-YY HH24:MI')||'</td>'||
'<td class="right">'||sample_size||'</td>'||
'<td class="right">'||num_rows||'</td>'||
'<td class="right">'||blocks||'</td>'||
'<td>'||global_stats||'</td>'||
'<td class="right">'||empty_blocks||'</td>'||
'<td class="right">'||avg_space||'</td>'||
'<td class="right">'||chain_cnt||'</td>'||
'<td class="right">'||avg_row_len||'</td>'||
'<td>'||logging||'</td>'||
'<td>'||degree||'</td>'||
'<td>'||cache||'</td>'||
'<td>'||partitioned||'</td>'||
'<td>'||iot_type||'</td>'||
'<td>'||temporary||'</td>'||
'<td>'||ini_trans||'</td>'||
'<td>'||max_trans||'</td>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'</tr>'
FROM bde_tables
ORDER BY owner, table_name;
PRO </table>
PRO </tbody><br><hr size="1">
SELECT '<font class="footer">bde_last_analyzed '||TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')||'</font>' FROM DUAL;
PRO </body></html>
SPO OFF

/******************************************************************************/

SET TERM ON
PRO Generating BDE_INDEXES spool file...
SET TERM OFF
SPO bde_last_analyzed_indexes.html
PRO <html><!-- $Header: bde_last_analyzed.sql 163208.1 2005/06/27 csierra $ -->
PRO <head><title>BDE_LAST_ANALYZED_INDEXES</title>
PRO <meta http-equiv="CONTENT-TYPE" content="TEXT/HTML; CHARSET=US-ASCII">
PRO <style type="text/css">
PRO a:active {color:#ff6600}
PRO a:link {color:#663300}
PRO a:visited {color:#996633}
PRO body {font-family:courier new,monospace,arial,helvetica;font-size:9pt;background-color:#ffffff}
PRO h1 {font-size:16pt;color:#336699;font-weight:bold}
PRO h2 {font-size:14pt;color:#336699;font-weight:bold}
PRO h3 {font-size:12pt;color:#336699;font-weight:bold}
PRO h4 {font-size:10pt;color:#336699;font-weight:bold}
PRO table {font-size:8pt;text-align:center}
PRO th {background-color:#cccc99;color:#336699;vertical-align:bottom;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td {background-color:#f7f7e7;color:#000000;vertical-align:top;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td.left {text-align:left}
PRO td.right {text-align:right}
PRO td.title {font-weight:bold;text-align:right;background-color:#cccc99;color:#336699}
PRO td.white {background-color:#ffffff}
PRO font.footer {font-style:italic;color:#999999}
PRO </style>
PRO </head><body>
PRO <h1>BDE_LAST_ANALYZED_INDEXES Report</h1>
PRO <h2>Indexes</h2>
PRO <table>
PRO <tr>
PRO <th>Table Owner.Table Name</th>
PRO <th>Owner.Index Name</th>
PRO <th>Last<br>Analyzed</th>
PRO <th>Sample<br>Size</th>
PRO <th>Num<br>Rows</th>
PRO <th>Leaf<br>Blocks</th>
PRO <th>Global<br>Stats</th>
PRO <th>Blevel</th>
PRO <th>Distinct<br>Keys</th>
PRO <th>Avg<br>Leaf<br>Blocks<br>per<br>Key</th>
PRO <th>Avg<br>Data<br>Blocks<br>per<br>Key</th>
PRO <th>Clustering<br>Factor</th>
PRO <th>Index<br>Type</th>
PRO <th>Uniqueness</th>
PRO <th>Logging</th>
PRO <th>Status</th>
PRO <th>Degree</th>
PRO <th>Partitioned</th>
PRO <th>Temporary</th>
PRO <th>Domidx<br>Status</th>
PRO <th>Funcidx<br>Status</th>
PRO <th>Ini<br>Trans</th>
PRO <th>Max<br>Trans</th>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||table_owner||'.'||table_name||'</td>'||
'<td class="left">'||owner||'.'||index_name||'</td>'||
'<td nowrap>'||TO_CHAR(last_analyzed, 'DD-MON-YY HH24:MI')||'</td>'||
'<td class="right">'||sample_size||'</td>'||
'<td class="right">'||num_rows||'</td>'||
'<td class="right">'||leaf_blocks||'</td>'||
'<td>'||global_stats||'</td>'||
'<td>'||blevel||'</td>'||
'<td class="right">'||distinct_keys||'</td>'||
'<td class="right">'||avg_leaf_blocks_per_key||'</td>'||
'<td class="right">'||avg_data_blocks_per_key||'</td>'||
'<td class="right">'||clustering_factor||'</td>'||
'<td>'||index_type||'</td>'||
'<td>'||uniqueness||'</td>'||
'<td>'||logging||'</td>'||
'<td>'||status||'</td>'||
'<td>'||degree||'</td>'||
'<td>'||partitioned||'</td>'||
'<td>'||temporary||'</td>'||
'<td>'||domidx_status||'</td>'||
'<td>'||funcidx_status||'</td>'||
'<td>'||ini_trans||'</td>'||
'<td>'||max_trans||'</td>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'</tr>'
FROM bde_indexes
ORDER BY table_owner, table_name, owner, index_name;
PRO </table>
PRO </tbody><br><hr size="1">
SELECT '<font class="footer">bde_last_analyzed '||TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')||'</font>' FROM DUAL;
PRO </body></html>
SPO OFF

/******************************************************************************/

SET TERM ON
PRO Generating BDE_TAB_PARTITIONS spool file...
SET TERM OFF
SPO bde_last_analyzed_tab_partitions.html
PRO <html><!-- $Header: bde_last_analyzed.sql 163208.1 2005/06/27 csierra $ -->
PRO <head><title>BDE_LAST_ANALYZED_TAB_PARTITIONS</title>
PRO <meta http-equiv="CONTENT-TYPE" content="TEXT/HTML; CHARSET=US-ASCII">
PRO <style type="text/css">
PRO a:active {color:#ff6600}
PRO a:link {color:#663300}
PRO a:visited {color:#996633}
PRO body {font-family:courier new,monospace,arial,helvetica;font-size:9pt;background-color:#ffffff}
PRO h1 {font-size:16pt;color:#336699;font-weight:bold}
PRO h2 {font-size:14pt;color:#336699;font-weight:bold}
PRO h3 {font-size:12pt;color:#336699;font-weight:bold}
PRO h4 {font-size:10pt;color:#336699;font-weight:bold}
PRO table {font-size:8pt;text-align:center}
PRO th {background-color:#cccc99;color:#336699;vertical-align:bottom;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td {background-color:#f7f7e7;color:#000000;vertical-align:top;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td.left {text-align:left}
PRO td.right {text-align:right}
PRO td.title {font-weight:bold;text-align:right;background-color:#cccc99;color:#336699}
PRO td.white {background-color:#ffffff}
PRO font.footer {font-style:italic;color:#999999}
PRO </style>
PRO </head><body>
PRO <h1>BDE_LAST_ANALYZED_TAB_PARTITIONS Report</h1>
PRO <h2>Table Partitions</h2>
PRO <table>
PRO <tr>
PRO <th>Table Owner.Table Name.Partition Name</th>
PRO <th>Last<br>Analyzed</th>
PRO <th>Sample<br>Size</th>
PRO <th>Num<br>Rows</th>
PRO <th>Blocks</th>
PRO <th>Global<br>Stats</th>
PRO <th>Empty<br>Blocks</th>
PRO <th>Avg<br>Space</th>
PRO <th>Chain<br>Cnt</th>
PRO <th>Avg<br>Row<br>Len</th>
PRO <th>Logging</th>
PRO <th>Composite</th>
PRO <th>Subpartition<br>Count</th>
PRO <th>Partition<br>Position</th>
PRO <th>Ini<br>Trans</th>
PRO <th>Max<br>Trans</th>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||table_owner||'.'||table_name||'.'||partition_name||'</td>'||
'<td nowrap>'||TO_CHAR(last_analyzed, 'DD-MON-YY HH24:MI')||'</td>'||
'<td class="right">'||sample_size||'</td>'||
'<td class="right">'||num_rows||'</td>'||
'<td class="right">'||blocks||'</td>'||
'<td>'||global_stats||'</td>'||
'<td class="right">'||empty_blocks||'</td>'||
'<td class="right">'||avg_space||'</td>'||
'<td class="right">'||chain_cnt||'</td>'||
'<td class="right">'||avg_row_len||'</td>'||
'<td>'||logging||'</td>'||
'<td>'||composite||'</td>'||
'<td>'||subpartition_count||'</td>'||
'<td>'||partition_position||'</td>'||
'<td>'||ini_trans||'</td>'||
'<td>'||max_trans||'</td>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'</tr>'
FROM bde_tab_partitions
ORDER BY table_owner, table_name, partition_position, partition_name;
PRO </table>
PRO </tbody><br><hr size="1">
SELECT '<font class="footer">bde_last_analyzed '||TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')||'</font>' FROM DUAL;
PRO </body></html>
SPO OFF

/******************************************************************************/

SET TERM ON
PRO Generating BDE_IND_PARTITIONS spool file...
SET TERM OFF
SPO bde_last_analyzed_ind_partitions.html
PRO <html><!-- $Header: bde_last_analyzed.sql 163208.1 2005/06/27 csierra $ -->
PRO <head><title>BDE_LAST_ANALYZED_IND_PARTITIONS</title>
PRO <meta http-equiv="CONTENT-TYPE" content="TEXT/HTML; CHARSET=US-ASCII">
PRO <style type="text/css">
PRO a:active {color:#ff6600}
PRO a:link {color:#663300}
PRO a:visited {color:#996633}
PRO body {font-family:courier new,monospace,arial,helvetica;font-size:9pt;background-color:#ffffff}
PRO h1 {font-size:16pt;color:#336699;font-weight:bold}
PRO h2 {font-size:14pt;color:#336699;font-weight:bold}
PRO h3 {font-size:12pt;color:#336699;font-weight:bold}
PRO h4 {font-size:10pt;color:#336699;font-weight:bold}
PRO table {font-size:8pt;text-align:center}
PRO th {background-color:#cccc99;color:#336699;vertical-align:bottom;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td {background-color:#f7f7e7;color:#000000;vertical-align:top;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td.left {text-align:left}
PRO td.right {text-align:right}
PRO td.title {font-weight:bold;text-align:right;background-color:#cccc99;color:#336699}
PRO td.white {background-color:#ffffff}
PRO font.footer {font-style:italic;color:#999999}
PRO </style>
PRO </head><body>
PRO <h1>BDE_LAST_ANALYZED_IND_PARTITIONS Report</h1>
PRO <h2>Index Partitions</h2>
PRO <table>
PRO <tr>
PRO <th>Index Owner.Index Name.Partition Name</th>
PRO <th>Last<br>Analyzed</th>
PRO <th>Sample<br>Size</th>
PRO <th>Num<br>Rows</th>
PRO <th>Leaf<br>Blocks</th>
PRO <th>Global<br>Stats</th>
PRO <th>Blevel</th>
PRO <th>Distinct<br>Keys</th>
PRO <th>Avg<br>Leaf<br>Blocks<br>per<br>Key</th>
PRO <th>Avg<br>Data<br>Blocks<br>per<br>Key</th>
PRO <th>Clustering<br>Factor</th>
PRO <th>Logging</th>
PRO <th>Status</th>
PRO <th>Composite</th>
PRO <th>Subpartition<br>Count</th>
PRO <th>Partition<br>Position</th>
PRO <th>Ini<br>Trans</th>
PRO <th>Max<br>Trans</th>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||index_owner||'.'||index_name||'.'||partition_name||'</td>'||
'<td nowrap>'||TO_CHAR(last_analyzed, 'DD-MON-YY HH24:MI')||'</td>'||
'<td class="right">'||sample_size||'</td>'||
'<td class="right">'||num_rows||'</td>'||
'<td class="right">'||leaf_blocks||'</td>'||
'<td>'||global_stats||'</td>'||
'<td>'||blevel||'</td>'||
'<td class="right">'||distinct_keys||'</td>'||
'<td class="right">'||avg_leaf_blocks_per_key||'</td>'||
'<td class="right">'||avg_data_blocks_per_key||'</td>'||
'<td class="right">'||clustering_factor||'</td>'||
'<td>'||logging||'</td>'||
'<td>'||status||'</td>'||
'<td>'||composite||'</td>'||
'<td>'||subpartition_count||'</td>'||
'<td>'||partition_position||'</td>'||
'<td>'||ini_trans||'</td>'||
'<td>'||max_trans||'</td>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'</tr>'
FROM bde_ind_partitions
ORDER BY index_owner, index_name, partition_position, partition_name;
PRO </table>
PRO </tbody><br><hr size="1">
SELECT '<font class="footer">bde_last_analyzed '||TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')||'</font>' FROM DUAL;
PRO </body></html>
SPO OFF

/******************************************************************************/

SET TERM ON
PRO Generating BDE_SUMMARY spool file...
SET TERM OFF
SPO bde_last_analyzed_summary.html
PRO <html><!-- $Header: bde_last_analyzed.sql 163208.1 2005/06/27 csierra $ -->
PRO <head><title>BDE_LAST_ANALYZED_SUMMARY</title>
PRO <meta http-equiv="CONTENT-TYPE" content="TEXT/HTML; CHARSET=US-ASCII">
PRO <style type="text/css">
PRO a:active {color:#ff6600}
PRO a:link {color:#663300}
PRO a:visited {color:#996633}
PRO body {font-family:courier new,monospace,arial,helvetica;font-size:9pt;background-color:#ffffff}
PRO h1 {font-size:16pt;color:#336699;font-weight:bold}
PRO h2 {font-size:14pt;color:#336699;font-weight:bold}
PRO h3 {font-size:12pt;color:#336699;font-weight:bold}
PRO h4 {font-size:10pt;color:#336699;font-weight:bold}
PRO table {font-size:8pt;text-align:center}
PRO th {background-color:#cccc99;color:#336699;vertical-align:bottom;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td {background-color:#f7f7e7;color:#000000;vertical-align:top;padding-left:3pt;padding-right:3pt;padding-top:1pt;padding-bottom:1pt}
PRO td.left {text-align:left}
PRO td.right {text-align:right}
PRO td.title {font-weight:bold;text-align:right;background-color:#cccc99;color:#336699}
PRO td.white {background-color:#ffffff}
PRO font.footer {font-style:italic;color:#999999}
PRO </style>
PRO </head><body>
PRO <h1>BDE_LAST_ANALYZED_SUMMARY Report</h1>
PRO <ul>
PRO   <li><a href="#cbo_stats_la">CBO Statistics Age by Last Analyzed</a></li>
PRO   <li><a href="#cbo_stats_schema">CBO Statistics Age per Schema Owner</a></li>
PRO   <li><a href="#cbo_stats_dd">CBO Statistics for Data Dictionary</a></li>
PRO   <li><a href="#partitioned_objects">Partitioned Objects</a></li>
PRO   <li><a href="#la_schema">Last Analyzed per Schema Owner</a></li>
PRO   <li><a href="#la_date">Last Analyzed per Date</a></li>
PRO   <li><a href="#attributes">Additional Attributes</a></li>
PRO </ul>


/******************************************************************************/

PRO <a name="cbo_stats_la"></a>
PRO <h2>CBO Statistics Age by Last Analyzed</h2>

PRO <h3>Overall Average Age in Days</h3>
PRO <table>
PRO <tr>
PRO <th>Tables</th>
PRO <th>Indexes</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||t.days_t||'</td>'||
'<td>'||i.days_i||'</td>'||
'</tr>'
FROM
(SELECT ROUND(AVG(SYSDATE - last_analyzed)) days_t FROM bde_tables )  t,
(SELECT ROUND(AVG(SYSDATE - last_analyzed)) days_i FROM bde_indexes ) i;
PRO </table>
PRO As a good practice, CBO stats should be less than 30 days old

PRO <h3>Table Count grouped by Last Analyzed column</h3>
PRO <table>
PRO <tr>
PRO <th>Last<br>Analyzed</th>
PRO <th>Age<br>(days)</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||TO_CHAR(last_analyzed, 'DD-MON-RR')||'</td>'||
'<td>'||ROUND(TRUNC(SYSDATE) - TO_DATE(TO_CHAR(last_analyzed, 'DD-MON-RR'), 'DD-MON-RR'))||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY TO_CHAR(last_analyzed, 'YYYYMMDD'), TO_CHAR(last_analyzed, 'DD-MON-RR')
ORDER BY TO_CHAR(last_analyzed, 'YYYYMMDD');
PRO </table>
PRO If Last Analyzed cell is blank, that means lack of CBO Stats

PRO <h3>Index Count grouped by Last Analyzed column</h3>
PRO <table>
PRO <tr>
PRO <th>Last<br>Analyzed</th>
PRO <th>Age<br>(days)</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||TO_CHAR(last_analyzed, 'DD-MON-RR')||'</td>'||
'<td>'||ROUND(TRUNC(SYSDATE) - TO_DATE(TO_CHAR(last_analyzed, 'DD-MON-RR'), 'DD-MON-RR'))||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY TO_CHAR(last_analyzed, 'YYYYMMDD'), TO_CHAR(last_analyzed, 'DD-MON-RR')
ORDER BY TO_CHAR(last_analyzed, 'YYYYMMDD');
PRO </table>
PRO If Last Analyzed cell is blank, that means lack of CBO Stats

/******************************************************************************/

PRO <a name="cbo_stats_schema"></a>
PRO <h2>CBO Statistics Age per Schema Owner</h2>
PRO <table>
PRO <tr>
PRO <th>Owner</th>
PRO <th>Tables<br>with<br>CBO Stats</th>
PRO <th>Avg<br>CBO Stats<br>Age (days)</th>
PRO <th>Tables<br>without<br>CBO Stats</th>
PRO <th>Indexes<br>with<br>CBO Stats</th>
PRO <th>Avg<br>CBO Stats<br>Age (days)</th>
PRO <th>Indexes<br>without<br>CBO Stats</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'</td>'||
'<td class="right">'||SUM(tlann)||'</td>'||
'<td class="right">'||SUM(taa)||'</td>'||
'<td class="right">'||SUM(tlan)||'</td>'||
'<td class="right">'||SUM(ilann)||'</td>'||
'<td class="right">'||SUM(iaa)||'</td>'||
'<td class="right">'||SUM(ilan)||'</td>'||
'</tr>'
FROM (
SELECT owner, COUNT(last_analyzed) tlann, ROUND(AVG(SYSDATE - last_analyzed)) taa, SUM(DECODE(last_analyzed, NULL, 1, 0)) tlan, 0 ilann, 0 iaa, 0 ilan
FROM bde_tables
GROUP BY owner
UNION ALL
SELECT owner, 0 tlann, 0 taa, 0 tlan, COUNT(last_analyzed) ilann, ROUND(AVG(SYSDATE - last_analyzed)) iaa, SUM(DECODE(last_analyzed, NULL, 1, 0)) ilan
FROM bde_indexes
GROUP BY owner
) temp
GROUP BY owner
ORDER BY owner;
PRO </table>

/******************************************************************************/

PRO <a name="cbo_stats_dd"></a>
PRO <h2>CBO Statistics for Data Dictionary</h2>

PRO <h3>CBO Statistics Age for SYS and SYSTEM</h3>
PRO <table>
PRO <tr>
PRO <th>Owner</th>
PRO <th>Tables<br>with<br>CBO Stats</th>
PRO <th>Avg<br>CBO Stats<br>Age (days)</th>
PRO <th>Tables<br>without<br>CBO Stats</th>
PRO <th>Indexes<br>with<br>CBO Stats</th>
PRO <th>Avg<br>CBO Stats<br>Age (days)</th>
PRO <th>Indexes<br>without<br>CBO Stats</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'</td>'||
'<td class="right">'||SUM(tlann)||'</td>'||
'<td class="right">'||SUM(taa)||'</td>'||
'<td class="right">'||SUM(tlan)||'</td>'||
'<td class="right">'||SUM(ilann)||'</td>'||
'<td class="right">'||SUM(iaa)||'</td>'||
'<td>'||SUM(ilan)||'</td>'||
'</tr>'
FROM (
SELECT owner, COUNT(last_analyzed) tlann, ROUND(AVG(SYSDATE - last_analyzed)) taa, SUM(DECODE(last_analyzed, NULL, 1, 0)) tlan, 0 ilann, 0 iaa, 0 ilan
FROM bde_tables
WHERE owner IN ('SYS', 'SYSTEM')
GROUP BY owner
UNION ALL
SELECT owner, 0 tlann, 0 taa, 0 tlan, COUNT(last_analyzed) ilann, ROUND(AVG(SYSDATE - last_analyzed)) iaa, SUM(DECODE(last_analyzed, NULL, 1, 0)) ilan
FROM bde_indexes
WHERE owner IN ('SYS', 'SYSTEM')
GROUP BY owner
) temp
GROUP BY owner
ORDER BY owner;
PRO </table>
PRO Starting with 9i, CBO Stats on Data Dictionary are OK

PRO <h3>CBO Statistics for SYS.DUAL</h3>
PRO <table>
PRO <tr>
PRO <th>Last Analyzed</th>
PRO </tr>
SELECT
'<tr>'||
'<td nowrap>'||TO_CHAR(last_analyzed, 'DD-MON-YY HH24:MI')||'</td>'||
'</tr>'
FROM bde_tables
WHERE owner = 'SYS' AND table_name = 'DUAL';
PRO </table>
PRO If using CBO, DUAL should have Stats

/******************************************************************************/

PRO <a name="partitioned_objects"></a>
PRO <h2>Partitioned Objects</h2>

PRO <h3>Partitioned Tables</h3>
PRO <table>
PRO <tr>
PRO <th>Owner.Table Name</th>
PRO <th>Partitioning<br>Type</th>
PRO <th>Subpartitioning<br>Type</th>
PRO <th>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'.'||table_name||'</td>'||
'<td>'||partitioning_type||'</td>'||
'<td>'||subpartitioning_type||'</td>'||
'<td class="right">'||partition_count||'</td>'||
'</tr>'
FROM all_part_tables
WHERE owner = DECODE(UPPER('&&SCHEMA'), 'ALL', owner, UPPER('&&SCHEMA'))
ORDER BY owner, table_name;
PRO </table>

PRO <h3>Partitioned Indexes</h3>
PRO <table>
PRO <tr>
PRO <th>Owner.Index Name</th>
PRO <th>Partitioning<br>Type</th>
PRO <th>Subpartitioning<br>Type</th>
PRO <th>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'.'||index_name||'</td>'||
'<td>'||partitioning_type||'</td>'||
'<td>'||subpartitioning_type||'</td>'||
'<td class="right">'||partition_count||'</td>'||
'</tr>'
FROM all_part_indexes
WHERE owner = DECODE(UPPER('&&SCHEMA'), 'ALL', owner, UPPER('&&SCHEMA'))
ORDER BY owner, index_name;
PRO </table>

PRO <h3>Partitioned Tables with Global and Partition CBO Stats out of sync</h3>
PRO <table>
PRO <tr>
PRO <th>Owner.Table Name</th>
PRO <th>Global<br>CBO Stats</th>
PRO <th>Partition<br>CBO Stats</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||bt.owner||'.'||bt.table_name||'</td>'||
'<td>'||TO_CHAR(bt.last_analyzed, 'DD-MON-RR')||'</td>'||
'<td>'||TO_CHAR(btp.last_analyzed, 'DD-MON-RR')||'</td>'||
'</tr>'
FROM bde_tables bt,
(SELECT table_owner owner, table_name, TRUNC(MAX(last_analyzed)) last_analyzed
FROM bde_tab_partitions
GROUP BY table_owner, table_name ) btp
WHERE bt.partitioned = 'YES'
AND bt.global_stats = 'YES'
AND bt.owner = btp.owner
AND bt.table_name = btp.table_name
AND TRUNC(bt.last_analyzed) <> btp.last_analyzed
ORDER BY bt.owner, bt.table_name;
PRO </table>
PRO You can syncronize Global and Partition CBO Stats deleting the Global Stats for the Table

PRO <h3>Partitioned Indexes with Global and Partition CBO Stats out of sync</h3>
PRO <table>
PRO <tr>
PRO <th>Owner.Index Name</th>
PRO <th>Global<br>CBO Stats</th>
PRO <th>Partition<br>CBO Stats</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||bi.owner||'.'||bi.index_name||'</td>'||
'<td>'||TO_CHAR(bi.last_analyzed, 'DD-MON-RR')||'</td>'||
'<td>'||TO_CHAR(bip.last_analyzed, 'DD-MON-RR')||'</td>'||
'</tr>'
FROM bde_indexes bi,
(SELECT index_owner owner, index_name, TRUNC(MAX(last_analyzed)) last_analyzed
FROM bde_ind_partitions
GROUP BY index_owner, index_name ) bip
WHERE bi.partitioned = 'YES'
AND bi.global_stats = 'YES'
AND bi.owner = bip.owner
AND bi.index_name = bip.index_name
AND TRUNC(bi.last_analyzed) <> bip.last_analyzed
ORDER BY bi.owner, bi.index_name;
PRO </table>
PRO You can syncronize Global and Partition CBO Stats deleting the Global Stats for the Index

/******************************************************************************/

PRO <a name="la_schema"></a>
PRO <h2>Last Analyzed per Schema Owner</h2>

PRO <h3>Tables</h3>
PRO <table>
PRO <tr>
PRO <th>Schema<br>Owner</th>
PRO <th>Last<br>Analyzed</th>
PRO <th>Age<br>(days)</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'</td>'||
'<td>'||TO_CHAR(last_analyzed, 'DD-MON-RR')||'</td>'||
'<td class="right">'||ROUND(TRUNC(SYSDATE) - TO_DATE(TO_CHAR(last_analyzed, 'DD-MON-RR'), 'DD-MON-RR'))||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY owner, TO_CHAR(last_analyzed, 'YYYYMMDD'), TO_CHAR(last_analyzed, 'DD-MON-RR')
ORDER BY owner, TO_CHAR(last_analyzed, 'YYYYMMDD');
PRO </table>
PRO If Last Analyzed cell is blank, that means lack of CBO Stats

PRO <h3>Indexes</h3>
PRO <table>
PRO <tr>
PRO <th>Schema<br>Owner</th>
PRO <th>Last<br>Analyzed</th>
PRO <th>Age<br>(days)</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||owner||'</td>'||
'<td>'||TO_CHAR(last_analyzed, 'DD-MON-RR')||'</td>'||
'<td class="right">'||ROUND(TRUNC(SYSDATE) - TO_DATE(TO_CHAR(last_analyzed, 'DD-MON-RR'), 'DD-MON-RR'))||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY owner, TO_CHAR(last_analyzed, 'YYYYMMDD'), TO_CHAR(last_analyzed, 'DD-MON-RR')
ORDER BY owner, TO_CHAR(last_analyzed, 'YYYYMMDD');
PRO </table>
PRO If Last Analyzed cell is blank, that means lack of CBO Stats

/******************************************************************************/

PRO <a name="la_date"></a>
PRO <h2>Last Analyzed per Date</h2>

PRO <h3>Tables</h3>
PRO <table>
PRO <tr>
PRO <th>Last<br>Analyzed</th>
PRO <th>Age<br>(days)</th>
PRO <th>Schema<br>Owner</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||TO_CHAR(last_analyzed, 'DD-MON-RR')||'</td>'||
'<td class="right">'||ROUND(TRUNC(SYSDATE) - TO_DATE(TO_CHAR(last_analyzed, 'DD-MON-RR'), 'DD-MON-RR'))||'</td>'||
'<td class="left">'||owner||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY TO_CHAR(last_analyzed, 'YYYYMMDD'), TO_CHAR(last_analyzed, 'DD-MON-RR'), owner
ORDER BY TO_CHAR(last_analyzed, 'YYYYMMDD'), owner;
PRO </table>
PRO If Last Analyzed cell is blank, that means lack of CBO Stats

PRO <h3>Indexes</h3>
PRO <table>
PRO <tr>
PRO <th>Last<br>Analyzed</th>
PRO <th>Age<br>(days)</th>
PRO <th>Schema<br>Owner</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||TO_CHAR(last_analyzed, 'DD-MON-RR')||'</td>'||
'<td class="right">'||ROUND(TRUNC(SYSDATE) - TO_DATE(TO_CHAR(last_analyzed, 'DD-MON-RR'), 'DD-MON-RR'))||'</td>'||
'<td class="left">'||owner||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY TO_CHAR(last_analyzed, 'YYYYMMDD'), TO_CHAR(last_analyzed, 'DD-MON-RR'), owner
ORDER BY TO_CHAR(last_analyzed, 'YYYYMMDD'), owner;
PRO </table>
PRO If Last Analyzed cell is blank, that means lack of CBO Stats

/******************************************************************************/

PRO <a name="attributes"></a>
PRO <h2>Additional Attributes</h2>

PRO <h3>Tables: Chained Rows</h3>
PRO <table>
PRO <tr>
PRO <th>Chained<br>Rows?</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||DECODE(NVL(chain_cnt, 0), 0, 'No', 'Yes')||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY DECODE(NVL(chain_cnt, 0), 0, 'No', 'Yes')
ORDER BY DECODE(NVL(chain_cnt, 0), 0, 'No', 'Yes');
PRO </table>

PRO <h3>Tables: Logging</h3>
PRO <table>
PRO <tr>
PRO <th>Logging?</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||logging||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY logging
ORDER BY logging;
PRO </table>

PRO <h3>Tables: Degree</h3>
PRO <table>
PRO <tr>
PRO <th>Degree</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||degree||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY degree
ORDER BY degree;
PRO </table>

PRO <h3>Tables: Cache</h3>
PRO <table>
PRO <tr>
PRO <th>Cache?</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||cache||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY cache
ORDER BY cache;
PRO </table>

PRO <h3>Tables: Initial Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Ini<br>Trans</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||ini_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY ini_trans
ORDER BY ini_trans;
PRO </table>

PRO <h3>Tables: Maximum Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Max<br>Trans</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||max_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY max_trans
ORDER BY max_trans;
PRO </table>

PRO <h3>Tables: Freelists</h3>
PRO <table>
PRO <tr>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO <th>Total<br>Freelists</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'<td>'||freelist_groups * freelists||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY freelist_groups, freelists
ORDER BY freelist_groups, freelists;
PRO </table>

PRO <h3>Tables: Partitioned</h3>
PRO <table>
PRO <tr>
PRO <th>Partitioned?</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||partitioned||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY partitioned
ORDER BY partitioned;
PRO </table>

PRO <h3>Tables: Index-Organized Table Type</h3>
PRO <table>
PRO <tr>
PRO <th>IOT<br>Type</th>
PRO <th>Table<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||iot_type||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tables
GROUP BY iot_type
ORDER BY iot_type;
PRO </table>

/******************************************************************************/

PRO <h3>Indexes: Logging</h3>
PRO <table>
PRO <tr>
PRO <th>Logging?</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||logging||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY logging
ORDER BY logging;
PRO </table>

PRO <h3>Indexes: Degree</h3>
PRO <table>
PRO <tr>
PRO <th>Degree</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||degree||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY degree
ORDER BY degree;
PRO </table>

PRO <h3>Indexes: Type</h3>
PRO <table>
PRO <tr>
PRO <th>Index<br>Type</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||index_type||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY index_type
ORDER BY index_type;
PRO </table>

PRO <h3>Indexes: Initial Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Ini<br>Trans</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||ini_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY ini_trans
ORDER BY ini_trans;
PRO </table>

PRO <h3>Indexes: Maximum Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Max<br>Trans</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||max_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY max_trans
ORDER BY max_trans;
PRO </table>

PRO <h3>Indexes: Freelists</h3>
PRO <table>
PRO <tr>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO <th>Total<br>Freelists</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'<td>'||freelist_groups * freelists||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY freelist_groups, freelists
ORDER BY freelist_groups, freelists;
PRO </table>

PRO <h3>Indexes: Partitioned</h3>
PRO <table>
PRO <tr>
PRO <th>Partitioned?</th>
PRO <th>Index<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||partitioned||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_indexes
GROUP BY partitioned
ORDER BY partitioned;
PRO </table>

/******************************************************************************/

PRO <h3>Table Partitions: Chained Rows</h3>
PRO <table>
PRO <tr>
PRO <th>Chained<br>Rows?</th>
PRO <th>Table<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||DECODE(NVL(chain_cnt, 0), 0, 'No', 'Yes')||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tab_partitions
GROUP BY DECODE(NVL(chain_cnt, 0), 0, 'No', 'Yes')
ORDER BY DECODE(NVL(chain_cnt, 0), 0, 'No', 'Yes');
PRO </table>

PRO <h3>Table Partitions: Logging</h3>
PRO <table>
PRO <tr>
PRO <th>Logging?</th>
PRO <th>Table<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||logging||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tab_partitions
GROUP BY logging
ORDER BY logging;
PRO </table>

PRO <h3>Table Partitions: Initial Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Ini<br>Trans</th>
PRO <th>Table<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||ini_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tab_partitions
GROUP BY ini_trans
ORDER BY ini_trans;
PRO </table>

PRO <h3>Table Partitions: Maximum Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Max<br>Trans</th>
PRO <th>Table<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||max_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tab_partitions
GROUP BY max_trans
ORDER BY max_trans;
PRO </table>

PRO <h3>Table Partitions: Freelists</h3>
PRO <table>
PRO <tr>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO <th>Total<br>Freelists</th>
PRO <th>Table<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'<td>'||freelist_groups * freelists||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tab_partitions
GROUP BY freelist_groups, freelists
ORDER BY freelist_groups, freelists;
PRO </table>

PRO <h3>Table Partitions: Subpartitions</h3>
PRO <table>
PRO <tr>
PRO <th>Subpartitions</th>
PRO <th>Table<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||subpartition_count||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_tab_partitions
GROUP BY subpartition_count
ORDER BY subpartition_count;
PRO </table>

/******************************************************************************/

PRO <h3>Index Partitions: Logging</h3>
PRO <table>
PRO <tr>
PRO <th>Logging?</th>
PRO <th>Index<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||logging||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_ind_partitions
GROUP BY logging
ORDER BY logging;
PRO </table>

PRO <h3>Index Partitions: Initial Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Ini<br>Trans</th>
PRO <th>Index<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||ini_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_ind_partitions
GROUP BY ini_trans
ORDER BY ini_trans;
PRO </table>

PRO <h3>Index Partitions: Maximum Transactions</h3>
PRO <table>
PRO <tr>
PRO <th>Max<br>Trans</th>
PRO <th>Index<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||max_trans||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_ind_partitions
GROUP BY max_trans
ORDER BY max_trans;
PRO </table>

PRO <h3>Index Partitions: Freelists</h3>
PRO <table>
PRO <tr>
PRO <th>Freelist<br>Groups</th>
PRO <th>Freelists</th>
PRO <th>Total<br>Freelists</th>
PRO <th>Index<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||freelist_groups||'</td>'||
'<td>'||freelists||'</td>'||
'<td>'||freelist_groups * freelists||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_ind_partitions
GROUP BY freelist_groups, freelists
ORDER BY freelist_groups, freelists;
PRO </table>

PRO <h3>Index Partitions: Subpartitions</h3>
PRO <table>
PRO <tr>
PRO <th>Subpartitions</th>
PRO <th>Index<br>Partition<br>Count</th>
PRO </tr>
SELECT
'<tr>'||
'<td>'||subpartition_count||'</td>'||
'<td class="right">'||COUNT(*)||'</td>'||
'</tr>'
FROM bde_ind_partitions
GROUP BY subpartition_count
ORDER BY subpartition_count;
PRO </table>

/******************************************************************************/

PRO </tbody><br><hr size="1">
SELECT '<font class="footer">bde_last_analyzed '||TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')||'</font>' FROM DUAL;
PRO </body></html>
SPO OFF

DROP TABLE bde_tables;
DROP TABLE bde_indexes;
DROP TABLE bde_tab_partitions;
DROP TABLE bde_ind_partitions;

SET TERM ON

PRO
PRO All bde_last_analyzed.html spool files have been generated.
PRO
PRO Recover and compress all 5 spool files into one zip file.
PRO
PRO Upload and/or send compressed zip file for further analysis.

/******************************************************************************/

UNDEF SCHEMA

SET FEED ON
SET VER ON
SET PAGES 24
SET LIN 80
SET HEA ON
SET TRIMS OFF
