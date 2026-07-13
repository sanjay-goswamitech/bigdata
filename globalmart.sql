-- Global Mart database setup with time travel examples
-- Co-authored with CoCo
create database global_mart;
drop database global_mart;
use global_mart;
create or replace table employees(emp_id number,emp_name string,salary number);
show tables like 'employees%';
insert into employees values(10,'abd',1000),(21,'asd',12345);--01c5adc8-3202-eec3-0000-0017a60e8071
select * from employees;
--time_travel first method => using offset 

select * from employees before(offset => -220);
-- before => usse phle ka time are not set 
-- at => at the moment fix time 

select * from employees before (statement => '01c5adc8-3202-eec3-0000-0017a60e8071');

-- history_dekhtii h 
select * from snowflake.account_usage.query_history order by start_time desc;----
                                                                                 |
select * from table(information_schema.query_history()) order by start_time desc;-----

delete from employees where emp_id =10;

select * from employees;
-- with new table use timetravel 
insert into employees 
select * from employees at (offset => -120)
where emp_id = 10;

create or replace table emp_clone 
clone employees at (offset => -120);
select * from emp_clone;

-- drop and undrop 
-- fail safe=> provide a non configurable , 7 days data protection period for permanent tables that begins immediately after time travel expires

-- 2026-07-13 03:13:57.948 -0700
select * from employees;
SHOW TABLES LIKE 'EMPLOYEES';
delete from employees;

-- FIX: Don't use CREATE OR REPLACE with time travel (it destroys history first).
-- Instead, use INSERT INTO to restore deleted rows:
INSERT INTO employees
SELECT * FROM employees BEFORE(STATEMENT => '01c5adc8-3202-eec3-0000-0017a60e8071');
create or replace table new(name string , id number);
insert into new values
('ram',12),('sam',11);--2026-07-13 04:27:15.494 -0700
SHOW TABLES LIKE 'new';

delete from new where id=11;

SELECT *
FROM new
AT (TIMESTAMP => '2026-07-13 04:27:15.494 -0700');

-- time travel timestamp 
-- fail safe and time travel se alag kyu h 
-- snowflake archteture 
-- whats is merge commend syntaax 
-- whats zero copy cloning 