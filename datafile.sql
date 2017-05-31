set linesize 1000;
col file_name format a95;
select  file_name, file_id, sum(bytes)/1024/1024 MB,autoextensible,online_status 
from dba_data_files where tablespace_name IN('&tablespace_name') 
group by file_name,autoextensible,online_status,file_id;