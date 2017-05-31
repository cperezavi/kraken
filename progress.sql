set linesize 1000
select START_TIME,TYPE, ITEM,UNITS,SOFAR,TIMESTAMP from v$recovery_progress where ITEM='Last Applied Redo';
