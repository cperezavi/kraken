select sql_text, sql_id, plan_hash_value, child_address, hash_value, child_number
from v$sql where sql_id = '&sqlid'; 
