set heading on
set pagesize 1000
set linesize 120
set wrap on
col SQL_ID for a20 wrap
col SQL_TEXT for a40 wrap
col isdefault for a10
spool 5QueryAWR_DictView.out

SELECT PLAN_TABLE_OUTPUT 
FROM TABLE (DBMS_XPLAN.DISPLAY_AWR('478vrzcybmm9z'));

/
spool off
/
