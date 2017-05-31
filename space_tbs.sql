set line 150
col "%Used" format a10
col "%Proy_1s" format a10
col "%Proy_1m" format a10
col tsname format a20
select tsname,
round(tablespace_size*t2.block_size/
1024/1024,2) TSize,
round(tablespace_usedsize*t2.block_size/1024/1024,0) TUsed,
round((tablespace_size-tablespace_usedsize)*t2.block_size/1024/1024,0) TFree,
round(val3*t2.block_size/1024/1024,0) "Dif_1s",
round(val4*t2.block_size/1024/1024,0) "Dif_1m",
round((tablespace_usedsize/tablespace_size)*100)||'%' "%Used",
round(((tablespace_usedsize+val3)/tablespace_size)*100)||'%' "%Proy_1s",
round(((tablespace_usedsize+val4)/tablespace_size)*100)||'%' "%Proy_1m"
from
(select distinct tsname,
rtime,
tablespace_size,
tablespace_usedsize,
tablespace_usedsize-first_value(tablespace_usedsize) 
over (partition by tablespace_id order by rtime rows 1 preceding) val1,
tablespace_usedsize-first_value(tablespace_usedsize) 
over (partition by tablespace_id order by rtime rows 24 preceding) val2,
tablespace_usedsize-first_value(tablespace_usedsize) 
over (partition by tablespace_id order by rtime rows 168 preceding) val3,
tablespace_usedsize-first_value(tablespace_usedsize) 
over (partition by tablespace_id order by rtime rows 720 preceding) val4
from (select t1.tablespace_size, t1.snap_id, t1.rtime,t1.tablespace_id, 
             t1.tablespace_usedsize-nvl(t3.space,0) tablespace_usedsize
     from dba_hist_tbspc_space_usage t1,
          dba_hist_tablespace_stat t2,
          (select ts_name,sum(space) space 
           from recyclebin group by ts_name) t3
     where t1.tablespace_id = t2.ts#
      and  t1.snap_id = t2.snap_id
      and  t2.tsname = t3.ts_name (+)) t1,
dba_hist_tablespace_stat t2
where t1.tablespace_id = t2.ts#
and t1.snap_id = t2.snap_id) t1,
dba_tablespaces t2
where t1.tsname = t2.tablespace_name
and rtime = (select max(rtime) from dba_hist_tbspc_space_usage)
order by "Dif_1s" desc, "Dif_1m" desc;