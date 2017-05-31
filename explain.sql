select * from table(dbms_xplan.DISPLAY_CURSOR('&sqlid',null,'ALL'))
/


SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('&sqlid', null, null, 'ALL'))
/