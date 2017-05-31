set linesize 110
set pagesize 40
select * from (
select to_date(first_time,'dd-mon-rr') day,
       to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'999') "00",
       to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'999') "01",
       to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'999') "02",
       to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'999') "03",
       to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'999') "04",
       to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'999') "05",
       to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'999') "06",
       to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'999') "07",
       to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'999') "08",
       to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'999') "09",
       to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'999') "10",
       to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'999') "11",
       to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'999') "12",
       to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'999') "13",
       to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'999') "14",
       to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'999') "15",
       to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'999') "16",
       to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'999') "17",
       to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'999') "18",
       to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'999') "19",
       to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'999') "20",
       to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'999') "21",
       to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'999') "22",
       to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'999') "23"
 from v$log_history
 group by   to_date (first_time,'dd-mon-rr')
 order by 1 desc);