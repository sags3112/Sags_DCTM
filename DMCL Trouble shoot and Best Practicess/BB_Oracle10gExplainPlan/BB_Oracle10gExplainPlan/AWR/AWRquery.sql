set heading on
set pagesize 1000
set linesize 120
set wrap on
col r_object_id for a10 wrap
col object_name for a20 wrap
col isdefault for a10
spool AWRquery.out

REM ****************************************
REM SQL Statement
REM ****************************************
select /* test_emc43 */ r_object_id, object_name 
from acs53sp4.dm_sysobject_s 
where r_object_type= 'dm_cabinet';




REM ****************************************
REM Manually load AWR
REM ****************************************

exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;



REM ****************************************
REM  Use the DBMS_XPLAN.DISPLAY_AWR () function to retrieve the execution plan
REM ****************************************

SELECT tf.* FROM DBA_HIST_SQLTEXT ht, 
table (DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf 
WHERE ht.sql_text like '%test_emc43%';

/
spool off
/
