--Script para revisar el consumo de tablespace Temporal.

set linesize 1000
SELECT   A.tablespace_name "Tablespace", 
		D.mb_total "Total en MBytes" ,
        SUM (A.used_blocks * D.block_size)/1024/1024 "MBytes Usados",
        D.mb_total - SUM (A.used_blocks * D.block_size)/1024/1024 "Mbytes Libres",
        ROUND(NVL((((SUM (A.used_blocks * D.block_size)/ 1024/1024) *100)/D.mb_total),0)) "% Utilizacion"
FROM     v$sort_segment A,
        (
        SELECT   B.name, C.block_size, SUM (C.bytes)/1024/1024 mb_total
        FROM     v$tablespace B, v$tempfile C
        WHERE    B.ts#= C.ts#
        GROUP BY B.name, C.block_size
        ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;
