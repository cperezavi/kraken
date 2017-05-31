set linesize 1000
column namespace        heading "Library Object"
column gets             format 9999,999,999 heading "Gets"
column gethitratio      format 999.99   heading "Get Hit%"
column pins             format 9,999,999,999 heading "Pins"
column pinhitratio      format 999.99   heading "Pin Hit%"
column db format a10
select to_char(sysdate, 'DD-MON-YY HH24:MI:SS') "Fecha" from dual;
select namespace,gets,gethitratio*100 gethitratio,pins,pinhitratio*100 pinhitratio
from
v$librarycache;

select 	gethits, gets, trunc(gethitratio,4) as gethitratio
from 	v$librarycache
where 	namespace = 'SQL AREA';
