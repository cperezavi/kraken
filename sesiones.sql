select 'alter system kill session '''||sid||','||serial#||'''IMMEDIATE;' from v$session where status = 'INACTIVE' and WAIT_CLASS='Idle' and username in  ('CTRLVEH5W');

select 'alter system kill session '''||sid||','||serial#||'''IMMEDIATE;' from v$session where status = 'INACTIVE' and username in  ('CTRLVEH5W');