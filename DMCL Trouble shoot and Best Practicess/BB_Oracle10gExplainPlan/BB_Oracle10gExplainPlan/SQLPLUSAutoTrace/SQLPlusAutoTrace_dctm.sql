set heading on
set pagesize 1000
set linesize 120
set wrap on
col r_object_id for a10 wrap
col object_name for a20 wrap
col isdefault for a10
spool SQLPlusAutoTrace_dctm.out

@C:\oracle\product\10.1.0\db_1\RDBMS\ADMIN\utlxplan.sql
set autotrace traceonly explain statistics;
set timing on

select /* test40 */ r_object_id, object_name from acs53sp4.dm_sysobject_s where r_object_type= 'dm_cabinet';

/
spool off
/
