{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_jobs_unified') }}
),

extracted_dates as (
    select
        *,
        -- Sử dụng safe_cast (dấu gạch dưới) để ép kiểu an toàn trong BigQuery
        coalesce(safe_cast(posted_date_raw as date), current_date()) as posted_date
    from base
),

final as (
    select
        *,
        to_hex(md5(cast(posted_date as string)))    as date_key,
        extract(year from posted_date)              as year,
        extract(quarter from posted_date)           as quarter,
        extract(month from posted_date)             as month,
        extract(day from posted_date)               as day,        
        extract(isoweek from posted_date)           as week,
        extract(dayofweek from posted_date)         as day_of_week,
        format_date('%A', posted_date)              as day_name,   
        format_date('%B', posted_date)              as month_name,
        format_date('%Y-%m', posted_date)           as year_month
    from extracted_dates
)

select * from final