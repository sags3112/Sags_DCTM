set heading on
set pagesize 1000
set linesize 120
set wrap on
spool SQLPlusAutoTrace_sys.out

@C:\oracle\product\10.1.0\db_1\sqlplus\admin\plustrce.sql
grant plustrace to acs53sp4;
/
spool off
/
