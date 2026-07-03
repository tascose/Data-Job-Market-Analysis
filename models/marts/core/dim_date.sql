{{ config(materialized='table', schema='marts') }}

with base as (
    select distinct posted_date
    from {{ ref('int_jobs_deduplicated') }}
    where posted_date is not null
)

select
    to_hex(md5(cast(posted_date as string)))    as date_key,
    posted_date,
    extract(year from posted_date)              as year,
    extract(quarter from posted_date)           as quarter,
    extract(month from posted_date)             as month,
    extract(day from posted_date)               as day,        -- ← thêm mới
    extract(isoweek from posted_date)           as week,
    extract(dayofweek from posted_date)         as day_of_week,
    format_date('%A', posted_date)              as day_name,   -- ← thêm tên thứ
    format_date('%B', posted_date)              as month_name,
    format_date('%Y-%m', posted_date)           as year_month

from base