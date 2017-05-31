set linesize 130
break on report
compute sum of "Size (MB)"     on report
compute sum of "Used (MB)"     on report
compute sum of "Free (MB)"     on report
column tablespace_name   format a30         heading 'Tablespace Name'
column "Size (MB)"       format 999,999     heading 'Size|(MB)'
column "Used (MB)"       format 999,999     heading 'Used|(MB)'
column "Free (MB)"       format 999,999     heading 'Free|(MB)'
column "% Used"          format 999.99      heading '% Used'
set linesize  150
set trimspool on
set pagesize  200
set verify    off
set feedback  off
select df.tablespace_name,
       trunc(df.bytes/1024/1024) "Size (MB)",
       trunc((df.bytes-fs.bytes)/1024/1024) "Used (MB)",
       trunc(fs.bytes/1024/1024) "Free (MB)",
       trunc((df.bytes-fs.bytes)/df.bytes*100,2) "% Used",
       decode(greatest(round(fs.bytes/df.bytes*100,2),15),15,'*','') "Warning"
from (select tablespace_name , sum(bytes) bytes
      from sys.dba_data_files
      group by tablespace_name) df,
     (select tablespace_name, sum(bytes) bytes
      from sys.dba_free_space
      group by tablespace_name) fs
where df.tablespace_name = fs.tablespace_name
order by 5 desc;