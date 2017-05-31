COLUMN tablespace                                   HEADING 'Tablespace'  					ENTMAP off
COLUMN filename                                     HEADING 'Nombre'                      	ENTMAP off
COLUMN filesize        FORMAT 999,999,999,999 		HEADING 'Tamano en MBytes'              ENTMAP off
COLUMN autoextensible                               HEADING 'Autoextensible'                ENTMAP off

SELECT /*+ ordered */
d.tablespace_name  as tablespace
  , d.file_name as filename
  , d.bytes/1024/1024 as filesize
  , d.autoextensible as autoextensible
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
UNION
SELECT
    d.tablespace_name as tablespace 
  , d.file_name  as filename
  , d.bytes/1024/1024 as filesize
  , d.autoextensible as autoextensible
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
UNION
SELECT
null
, a.member
  , b.bytes/1024/1024
  , null
FROM
    v$logfile a
  , v$log b
WHERE a.type IN('ONLINE','STANDBY')
UNION
SELECT
    null
  , a.name
  , null
  , null
FROM v$controlfile a
ORDER BY 1, 2;