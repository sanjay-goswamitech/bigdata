-- create database 
create database newprodb;
use newprodb;

-- create schema => raw 
create or replace schema newprodb.raw;

-- create table => csv_table
create or replace table cvs_table(
    transaction_id   STRING,
    store_id         STRING,
    store_name       STRING,
    store_city       STRING,
    store_region     STRING,
    cashier_id       STRING,
    customer_id      STRING,
    transaction_date DATE,
    transaction_time TIME,
    product_sku      STRING,
    product_name     STRING,
    category         STRING,
    subcategory      STRING,
    quantity         INT,
    unit_price       FLOAT,
    discount_pct     INT,
    total_amount     FLOAT,
    payment_method   STRING,
    loyalty_points   INT,
    load_timestamp TIMESTAMP,
    file_name STRING
);

-- **********   STORAGE INTEGRATION **********
create or replace storage integration s3_integration1
type = External_Stage
storage_provider = 's3'
enabled = True
storage_aws_role_arn='arn:aws:iam::418553863488:role/new_snowflake'  
storage_allowed_locations=('s3://sanjaynew-bucket/');

desc storage integration s3_integration1;

create or replace stage newprodb.raw.s3_stage1
url = 's3://sanjaynew-bucket/'
storage_integration = s3_integration1;


create or replace file format newprodb.raw.csv_format
type = 'CSV'
skip_header = 1
field_optionally_enclosed_by = '"';

list @newprodb.raw.s3_stage1;

copy into raw.cvs_table
from
(
    select
        t.$1,
        t.$2,
        t.$3,
        t.$4,
        t.$5,
        t.$6,
        t.$7,
        t.$8,
        t.$9,
        t.$10,
        t.$11,
        t.$12,
        t.$13,
        t.$14,
        t.$15,
        t.$16,
        t.$17,
        t.$18,
        t.$19,
        current_timestamp(),
        metadata$filename
    from @newprodb.raw.s3_stage1/csv/ t
)
file_format = (format_name = raw.csv_format);


select * from cvs_table;

create table json_table(user_col variant);
select * from json_table;


create or replace file format newprodb.raw.json_format
type = 'json'
strip_outer_array = true;

copy into  json_table 
from @newprodb.raw.s3_stage1/iot/

file_format = json_format;

select user_COL:device_id::varchar ,
user_col:event_id,user_col:event_type,user_col:metadata,user_col:readings,user_col,user_col:store_id,user_col:store_name,user_col:timestamp from json_table,;