set timing on;
EXEC DBMS_STATS.gather_dictionary_stats;
EXEC DBMS_STATS.gather_fixed_objects_stats;
EXEC DBMS_STATS.gather_system_stats;
EXEC DBMS_STATS.gather_database_stats(estimate_percent => 15, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('INBROKER_FASE2', estimate_percent => 15, cascade => TRUE);