set heading on
set pagesize 1000
set linesize 120
set wrap on
col SQL_ID for a20 wrap
col SQL_TEXT for a40 wrap
col isdefault for a10
spool 3dba_hist_sqltext.out

SELECT SQL_ID, SQL_TEXT 
FROM dba_hist_sqltext 
WHERE SQL_ID='cstgya8t79a43';
/
spool off
/
