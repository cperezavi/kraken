set linesize 1000
col file_name format a75
select file_id,file_name, sum(bytes)/1024/1024 MB,autoextensible 
from dba_temp_files 
where tablespace_name IN('&tablespace_name') group by file_id,file_name,autoextensible;
