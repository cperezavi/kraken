select sid,serial#, SQL_ID, ACTION, BLOCKING_SESSION,
BLOCKING_SESSION_STATUS, EVENT
from v$session where event='enq: TX - contention';
