set verify off
set linesize 120
set pagesize 60
column sort_id noprint
column priv_type format a35
column priv format a60
column grantable heading "ADM" format a3
column default_role heading "DEF" format a3
spool showAllPrivs.txt
 select
    1 as sort_id,
    'ROLE' as priv_type,
    a.granted_role as priv,
    a.admin_option as grantable,
    a.default_role as default_role
  from
    DBA_ROLE_PRIVS a
  where
    grantee = '&&enter_username'
union
 select
    2 as sort_id,
    'SYS PRIV' as priv_type,
    b.privilege as priv,
    b.admin_option as grantable,
    null as default_role
  from
    DBA_SYS_PRIVS b
  where
    grantee = '&&enter_username'
union
 select
    5 as sort_id,
    'TAB PRIV (ROLE "' || c.granted_role || '")' as priv_type,
    d.privilege || ' on "' || d.owner ||
       '"."' || d.table_name || '"'
       as priv,
    d.grantable as grantable,
    c.default_role as default_role
  from
    DBA_ROLE_PRIVS c,
    DBA_TAB_PRIVS d
  where
    c.grantee = '&&enter_username'
    and d.grantee = c.granted_role
union
 select
    7 as sort_id,
    'COL PRIV (ROLE "' || e.granted_role || '")' as priv_type,
    f.privilege || ' on "' || f.owner ||
       '"."' || f.table_name || '" ("' || f.column_name || '"
;)'
       as priv,
    f.grantable as grantable,
    e.default_role as default_role
  from
    DBA_ROLE_PRIVS e,
    DBA_COL_PRIVS f
  where
    e.grantee = '&&enter_username'
    and f.grantee = e.granted_role
union
 select
    4 as sort_id,
    'TAB PRIV' as priv_type,
    g.privilege || ' on "' || g.owner ||
       '"."' || g.table_name || '"'
       as priv,
    g.grantable as grantable,
    null as default_role
  from
    DBA_TAB_PRIVS g
  where
    g.grantee = '&&enter_username'
union
 select
    6 as sort_id,
    'COL PRIV' as priv_type,
    h.privilege || ' on "' || h.owner ||
       '"."' || h.table_name || '" ("' || h.column_name || '"
;)'
       as priv,
    h.grantable as grantable,
    null as default_role
  from
    DBA_COL_PRIVS h
  where
    h.grantee = '&&enter_username'
union
 select
    3 as sort_id,
    'SYS PRIV (ROLE "' || i.granted_role || '")' as priv_type,
    j.privilege as priv,
    j.admin_option as grantable,
    i.default_role as default_role
  from
    DBA_ROLE_PRIVS i,
    DBA_SYS_PRIVS j
  where
    i.grantee = '&&enter_username'
    and j.grantee = i.granted_role
order by 1, 2, 3 ;
undefine enter_username
clear columns
spool off
set linesize 80
set verify on