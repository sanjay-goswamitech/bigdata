create or replace transient database regex_db;
-- create a example table 
create or replace table sales_raw_staging(
    id varchar,
    product varchar,
    price varchar,
    amount varchar,
    store_id varchar 
);
-- insert values in table 
insert into sales_raw_staging
    values 
        (1,'tv',1.99,1,1),
        (2,'mobile',0.99,1,1),
        (3,'laptop',1.79,1,2),
        (4,'washing machine',1.89,1,2),
        (5,'cereals',5.98,2,1);

select * from sales_raw_staging;


-- create a store_table 
create or replace table store_table(
    store_id number,
    location varchar,
    employees number);

insert into store_table values(1,'jaipur',100);
insert into store_table values(2,'jodhpur',200);

select * from store_table ;


-- create a sales_final_table 
create or replace table sales_final_table(
    id int,
    product varchar,
    price number,
    amount int,
    store_id int,
    location varchar,
    employees int);
-- insert into sales_final_table 
insert into sales_final_table
select sa.id,sa.product,sa.price,sa.amount,sal.store_id,sal.location,sal.employees from sales_raw_staging as sa inner join
store_table as sal on sa.store_id=sal.store_id;


-- create a stream 
create or replace stream sales_stream on table sales_raw_staging;
show streams;

-- show streams 
desc stream sales_stream;
-- get changes on data using stream (inserts)
select * from sales_stream;
-- insert values 
insert into sales_raw_staging
    values
        (6,'mobile cover',5.99,1,2),(7,'headphones',7.88,1,2);
-- get changes on data using stream (inserts)
select * from sales_stream;

select * from sales_final_table before(offset => -60*5);
select * from sales_raw_staging; -- added 2 new rows (7)


select * from sales_final_table;
select * from sales_stream;


insert into sales_final_table
select
s.id,
s.product,
s.price,
s.amount,
s.store_id,
sr.location,
sr.employees
from sales_stream  as s 
 inner join
store_table as 
sr on s.store_id=sr.store_id; 

select * from sales_final_table;


-- ********update 1 ***********

UPDATE sales_final_table
SET product = 'tablet'
WHERE id=3;

select * from sales_final_table;--target table 
select * from sales_stream;-- source table 


merge into sales_final_table as target -- target table to merge changes from source table 
using sales_stream as source -- stream that has captured the changes 
on target.id=source.id 
when matched and source.metadata$action='insert' and source.metadata$isupdate ='true' then 
    update set target.product=source.product , target.price=source.price,target.amount=source.amount,target.store_id=source.store_id;

select * from sales_final_table;
select * from sales_raw_staging;



-- ******* with insert , update , delete in sales_raw_staging table ******
INSERT INTO sales_raw_staging
VALUES(8,'keyboard',15.99,1,1);

UPDATE sales_raw_staging
SET product = 'smart tv'
WHERE id = 1;

DELETE FROM sales_raw_staging
WHERE id = 2;

select * from sales_stream;
select * from sales_raw_staging;


merge into sales_final_table sj
using
    sales_stream st 

    on sj.id=st.id

when matched 
and
st.METADATA$ACTION = 'INSERT'
And st.METADATA$ISUPDATE = 'TRUE'

then update set 
sj.product = st.product,
sj.price = st.price,
sj.amount = st.amount,
sj.store_id = st.store_id


when not matched and 
st.METADATA$ACTION = 'INSERT' and st.METADATA$ISUPDATE = 'FALSE'

then insert (
 id,
    product,
    price,
    amount,
    store_id
)
VALUES (
    st.id,
    st.product,
    st.price,
    st.amount,
    st.store_id )
    
    
WHEN MATCHED  
AND st.METADATA$ACTION = 'DELETE' and st.METADATA$ISUPDATE = 'FALSE'

THEN DELETE;

SELECT * FROM sales_final_table;

select * from sales_stream;
select * from sales_raw_staging;