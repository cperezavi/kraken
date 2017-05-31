SET SERVEROUTPUT ON

DECLARE
   V_STMT     VARCHAR2 (500);
   V_TBLSPC   VARCHAR2 (30) := '&tbs';

   CURSOR C1
   IS
      SELECT FILE_ID
        FROM DBA_DATA_FILES
       WHERE TABLESPACE_NAME = V_TBLSPC;
BEGIN
   FOR LINE IN C1
   LOOP
      SELECT    'ALTER DATABASE DATAFILE '
             || ''''
             || D.FILE_NAME
             || ''''
             || ' RESIZE '
             || NVL (CEIL (D.BYTES / 1024 / 1024 - TAKE_BACK.TAKE_BACK_MB),
                     D.BYTES / 1024 / 1024)
             || 'M;'
                SQL
        INTO V_STMT
        FROM DBA_DATA_FILES D,
             (SELECT SUM (BYTES) / 1024 / 1024 TAKE_BACK_MB
                FROM DBA_FREE_SPACE
               WHERE TABLESPACE_NAME = V_TBLSPC AND FILE_ID = LINE.FILE_ID
                     AND BLOCK_ID >=
                            NVL (
                               (SELECT (A.BLOCK_ID + (A.BYTES / B.BLOCK_SIZE))
                                  FROM DBA_EXTENTS A, DBA_TABLESPACES B
                                 WHERE A.BLOCK_ID =
                                          (SELECT MAX (BLOCK_ID)
                                             FROM DBA_EXTENTS
                                            WHERE FILE_ID = LINE.FILE_ID
                                                  AND TABLESPACE_NAME =
                                                         V_TBLSPC)
                                       AND A.FILE_ID = LINE.FILE_ID
                                       AND A.TABLESPACE_NAME = V_TBLSPC
                                       AND B.TABLESPACE_NAME = V_TBLSPC),
                               0)) TAKE_BACK
       WHERE D.FILE_ID = LINE.FILE_ID;

      DBMS_OUTPUT.PUT_LINE (V_STMT);
   END LOOP;
END;
/