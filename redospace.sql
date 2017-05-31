set linesize 80
select le.leseq "Current log sequence No",
       round(cp.cpodr_bno/le.lesiz*100,2) "Percent Full",
       cp.cpodr_bno  "Current Block No",
       le.lesiz "Size of Log in Blocks"
from x$kcccp cp, x$kccle le
where le.leseq =cp.cpodr_seq
and bitand(le.leflg,24) = 8;