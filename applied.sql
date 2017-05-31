SELECT THREAD#,sequence#, first_time, next_time, applied
FROM gv$archived_log where THREAD#=1
ORDER BY sequence#;