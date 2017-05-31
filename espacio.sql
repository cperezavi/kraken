set lines 150 pages 66 feedback off
column tablespace_name                format a20        heading 'Tablespace'
column autoextensible                 format a15        heading 'Autoextensible'
column files_in_tablespace            format 999        heading 'Files'
column total_used_pct                 format 999        heading 'Usage %'
column total_tablespace_space_mb      format 99,999,999 heading 'Size Mb'
column total_tablespace_free_space_mb format 99,999,999 heading 'Free Mb'
column total_used_space_mb            format 99,999,999 heading 'Used Mb'
column total_free_pct                 format 999        heading 'Free %'
column max_size_of_tablespace_mb      format 99,999,999 heading 'Max Mb'
column used_pct_of_max                format 999        heading 'Used % of Max'

ttitle left _date center "Tablespace Space Utilization Status Report" skip 2

with 
tbs_auto as
     (select distinct tablespace_name, autoextensible
      from dba_data_files
      where autoextensible = 'YES'),
files as
     (select tablespace_name, count (*) tbs_files,
             sum (bytes) total_tbs_bytes
      from dba_data_files
      group by tablespace_name),
fragments as
     (select tablespace_name, count (*) tbs_fragments,
             sum (bytes) total_tbs_free_bytes,
             max (bytes) max_free_chunk_bytes
      from dba_free_space
      group by tablespace_name),
autoextend as
     (select tablespace_name, sum (size_to_grow) total_growth_tbs
      from (select tablespace_name, sum (maxbytes) size_to_grow
            from dba_data_files
            where autoextensible = 'YES'
            group by tablespace_name
            union
            select   tablespace_name, sum (bytes) size_to_grow
            from dba_data_files
            where autoextensible = 'NO'
            group by tablespace_name)
      group by tablespace_name)
select a.tablespace_name,
       case tbs_auto.autoextensible
        when 'YES'
          then 'YES'
        else 'NO'
       end as autoextensible,
       files.tbs_files files_in_tablespace,
       round((((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/files.total_tbs_bytes)*100))total_used_pct,
       files.total_tbs_bytes/1024/1024 total_tablespace_space_mb,
       round(fragments.total_tbs_free_bytes/1024/1024) total_tablespace_free_space_mb,
       round((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/1024/1024) total_used_space_mb,
       round(((fragments.total_tbs_free_bytes / files.total_tbs_bytes)*100))total_free_pct,
       autoextend.total_growth_tbs/1024/1024 max_size_of_tablespace_mb,
       round((((files.total_tbs_bytes - fragments.total_tbs_free_bytes)/autoextend.total_growth_tbs)*100)) used_pct_of_max,
       decode(greatest(round(100-(((files.total_tbs_bytes-fragments.total_tbs_free_bytes)/autoextend.total_growth_tbs)*100)),10),10,'*','') "Warning"
from dba_tablespaces a, files, fragments, autoextend, tbs_auto
where a.tablespace_name = files.tablespace_name
  and a.tablespace_name = fragments.tablespace_name
  and a.tablespace_name = autoextend.tablespace_name
  and a.tablespace_name = tbs_auto.tablespace_name(+)
order by used_pct_of_max desc;