set heading on
set pagesize 1000
set linesize 120
set wrap on
col SQL_ID for a20 wrap
col SQL_TEXT for a40 wrap
col isdefault for a10
spool 2QueryAWR.out

select sql_id, sql_text 
from v$sql 
where sql_text like '%test_emc43%';
/
spool off
/
