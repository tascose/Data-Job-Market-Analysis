{{ config(materialized='table', schema='marts') }}

with base as (
    select distinct posted_at
    from {{ ref('int_jobs_deduplicated') }}
    where posted_at is not null
)

select
    -- Dùng format_date định dạng cố định YYYY-MM-DD để băm MD5 không bao giờ bị lệch múi giờ
    to_hex(md5(format_date('%Y-%m-%d', posted_at))) as date_key,
    posted_at,
    extract(year from posted_at)                as year,
    extract(quarter from posted_at)             as quarter,
    extract(month from posted_at)               as month,
    extract(day from posted_at)                 as day,
    extract(isoweek from posted_at)             as week,
    extract(dayofweek from posted_at)           as day_of_week,
    format_date('%A', posted_at)                as day_name,
    format_date('%B', posted_at)                as month_name,
    format_date('%Y-%m', posted_at)             as year_month

from base