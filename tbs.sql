--script que muestra el espacio total, usado, libre, ademas de porcentajes de uso y libre de los tablespace de la base de datos

set linesize 1000
set pages 250
col  tname  format         a35 justify c heading 'Tablespaces'
col totsiz  format         999,999,999,990 justify c heading 'Total|(MB)'
col avasiz  format         999,999,999,990 justify c heading 'Disponible|(MB)'
col pctusd  format         990 justify c heading 'Pct|Used'
comp sum of TOTAL_SPACE(Mb) Free_space(Mb) Used_space(Mb) on report
break on report
SELECT unique Total.tablespace_name,
round(total_space,0),
round(nvl(Free_space, 0)) Free_space,
round(nvl(total_space-Free_space, 0)) Used_space,
round(NVL(Free_space/total_space,0)*100,2) PCT_Libre,
(100-round(NVL(Free_space/total_space,0)*100,2)) PCT_ocupado
FROM
(select unique tablespace_name, sum(bytes/1024/1024) Free_Space
from sys.dba_free_space
group by tablespace_name)Free,
(select unique b.tablespace_name, sum(bytes/1024/1024) TOTAL_SPACE
from dba_data_files b
group by b.tablespace_name) Total
WHERE Free.Tablespace_name(+) = Total.tablespace_name 
ORDER BY 6 asc;