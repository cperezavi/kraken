set pagesize  200
set verify    off
set feedback  off
select df.tablespace_name,
       trunc(df.bytes/1024/1024) "Size (MB)",
       trunc((df.bytes-fs.bytes)/1024/1024) "Used (MB)",
       trunc(fs.bytes/1024/1024) "Free (MB)",
       trunc((df.bytes-fs.bytes)/df.bytes*100,2) "% Used",
       decode(greatest(round(fs.bytes/df.bytes*100,2),5),5,'*','') "Warning"
from (select tablespace_name , sum(bytes) bytes
      from sys.dba_data_files
      group by tablespace_name) df,
     (select tablespace_name, sum(bytes) bytes
      from sys.dba_free_space
      group by tablespace_name) fs
where df.tablespace_name = fs.tablespace_name
order by 5 desc;