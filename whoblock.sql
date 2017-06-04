SELECT vh.sid locking_sid,
 vs.status status,
 vs.program program_holding,
 vw.sid waiter_sid,
 vsw.program program_waiting
FROM v$lock vh,
 v$lock vw,
 v$session vs,
 v$session vsw
WHERE     (vh.id1, vh.id2) IN (SELECT id1, id2
 FROM v$lock
 WHERE request = 0
 INTERSECT
 SELECT id1, id2
 FROM v$lock
 WHERE lmode = 0)
 AND vh.id1 = vw.id1
 AND vh.id2 = vw.id2
 AND vh.request = 0
 AND vw.lmode = 0
 AND vh.sid = vs.sid
 AND vw.sid = vsw.sid;