select 'alter system kill session '''||sid||','||serial#||'''IMMEDIATE;' from v$session where
username not in 




select 'alter system kill session '''||sid||','||serial#||'''IMMEDIATE;' from v$session where status = 'INACTIVE' 
and WAIT_CLASS='Idle' 
and username in 
('CTRLVEH5W');

CTRLVEH5W

('MDSYS','DIP','DMSYS','TSMSYS','OUTLN','MGMT_VIEW','CTXSYS','OLAPSYS','SYSTEM','EXFSYS','ORDSYS','SYSMAN','ORDPLUGINS','MDDATA','SYS','PERFSTAT','WMSYS');