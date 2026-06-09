create database clonedb;
use clonedb;
create table customers(cid int , name varchar(20));
insert into customers values(10,'amaan'),(11,'abhi'),(12,'syam');

select * from customers;

-- create clone 
create  table customers_clone 
clone customers;
select * from customers;
select * from customers_clone;

insert into customers_clone values(13,'tushar');
update customers set name='regex';


-- cloning a temporay table => ye temapry hota h web bnd hone pr hat jata h 
create or replace temporary table temp_table(id int );
insert into temp_table values(10),(20);

-- create a clone for temporary table 
create or replace table table_copy clone temp_table;-- parmanent table ke liye tempoparry clone nhi bn sakte 

create or replace temporary table table_copy clone temp_table;-- temporary ke liye temporary clone 


-- create a schema raj 
create or replace schema raj;
create table test(id int);

create or replace transient schema raj_trans clone raj;
select * from raj_trans.test;


-- **********timetravel clone****************
create table table1(id int , age int );
insert into table1 values(1,33),(2,18),(3,20);

update table1 set age=122 where id=101;
insert into table1 values(4,22),(5,22);

create  table table_clone 
clone table1 at(offset => -60*2);

select * from table_clone;