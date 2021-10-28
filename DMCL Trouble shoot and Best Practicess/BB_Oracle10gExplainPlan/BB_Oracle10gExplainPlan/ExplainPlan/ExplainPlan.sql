set heading on
set pagesize 1000
set linesize 120
set wrap on
col r_object_id for a10 wrap
col object_name for a20 wrap
col isdefault for a10
spool ExplainPlan.out

EXPLAIN PLAN
SET STATEMENT_ID='test40' FOR
select /* test40 */ r_object_id, object_name 
from acs53sp4.dm_sysobject_s 
where r_object_type= 'dm_cabinet';

SELECT plan_table_output 
FROM TABLE(dbms_xplan.display('plan_table','test40','serial'));

/
spool off
/


