SET LINESIZE 100
select substr(DECODE(request,0,'Holder: ','Waiter: ')||sid,1,12) sess,
id1, id2, lmode, request, type, inst_id
FROM gv$lock
WHERE (id1, id2, type) IN
(SELECT id1, id2, type FROM gv$lock WHERE request>0)
ORDER BY id1, request;