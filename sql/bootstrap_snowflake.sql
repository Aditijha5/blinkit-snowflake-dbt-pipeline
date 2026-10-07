-- bootstrap: warehouse, database, schemas, file format, external stage, raw table, load
-- placeholders ({{S3_PATH}}, {{AWS_KEY_ID}}, {{AWS_SECRET_KEY}}) are filled in memory by
-- scripts/run_pipeline.py from environment variables. never hard-code keys in this file.

create warehouse if not exists blinkit_wh
    warehouse_size = 'XSMALL'
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;

create database if not exists blinkit_db;
create schema if not exists blinkit_db.raw;
create schema if not exists blinkit_db.staging;
create schema if not exists blinkit_db.marts;

use warehouse blinkit_wh;
use database blinkit_db;
use schema raw;

create or replace file format blinkit_csv_format
    type = 'csv'
    skip_header = 1
    field_optionally_enclosed_by = '"'
    null_if = ('', 'NULL', 'null')
    empty_field_as_null = true;

create or replace stage blinkit_s3_stage
    url = '{{S3_PATH}}'
    credentials = (aws_key_id = '{{AWS_KEY_ID}}' aws_secret_key = '{{AWS_SECRET_KEY}}')
    file_format = blinkit_csv_format;

-- column order must match the csv header of the blinkit grocery dataset
create or replace table blinkit_orders_raw (
    item_fat_content          varchar,
    item_identifier           varchar,
    item_type                 varchar,
    outlet_establishment_year number,
    outlet_identifier         varchar,
    outlet_location_type      varchar,
    outlet_size               varchar,
    outlet_type               varchar,
    item_visibility           float,
    item_weight               float,
    sales                     float,
    rating                    float
);

copy into blinkit_orders_raw
    from @blinkit_s3_stage
    file_format = (format_name = blinkit_csv_format)
    on_error = 'abort_statement';
