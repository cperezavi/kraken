select v$session.sid, username, value/1024/1024 redo_size_MB
from v$sesstat, v$statname, v$session
where v$sesstat.STATISTIC# = v$statname.STATISTIC#
and v$session.sid = v$sesstat.sid
and name = 'redo size'
and value > 0
and username is not null
order by value;