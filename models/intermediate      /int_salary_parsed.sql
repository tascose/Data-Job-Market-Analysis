{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_dates_normalized') }} -- Hoặc ref('int_jobs_unified')
),

cleaned as (
    select
        *,
        -- SỬA TẠI ĐÂY: Đổi salary_raw thành salary
        trim(lower(salary)) as salary_clean 
    from base
),
...