set verify off
set linesize 1000
accept trgthash number default 0 prompt 'What is the SQL Hash Value : '
select t.sql_text 
from v$sqltext_with_newlines t
where t.hash_value + 0 = &trgthash
and &trgthash != 0
order by t.piece
/
