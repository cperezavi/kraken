SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
COLUMN "Tablespace Name" FORMAT A20
COLUMN "File Name" FORMAT A80
 
SELECT  Substr(df.tablespace_name,1,20) "Tablespace Name",
        Substr(df.file_name,1,80) "File Name",
        Round(df.bytes/1024/1024,0) "Size (M)",
        decode(e.used_bytes,NULL,0,Round(e.used_bytes/1024/1024,0)) "Used (M)",
        decode(f.free_bytes,NULL,0,Round(f.free_bytes/1024/1024,0)) "Free (M)",
        decode(e.used_bytes,NULL,0,Round((e.used_bytes/df.bytes)*100,0)) "% Used"
FROM    DBA_DATA_FILES DF,
       (SELECT file_id,
               sum(bytes) used_bytes
        FROM dba_extents
        GROUP by file_id) E,
       (SELECT Max(bytes) free_bytes,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE    e.file_id (+) = df.file_id
AND      df.file_id  = f.file_id (+)
ORDER BY df.tablespace_name,
         df.file_name
/