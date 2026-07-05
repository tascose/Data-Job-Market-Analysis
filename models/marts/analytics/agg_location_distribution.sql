{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select
        f.job_id,
        f.core_role,
        l.location_name,
        l.region,
        d.year,
        d.month
    from {{ ref('fact_jobs') }} f
    inner join {{ ref('dim_location') }} l on f.location_key = l.location_key
    inner join {{ ref('dim_date') }} d on f.date_key = d.date_key
),

aggregated as (
    select
        year,
        month,
        region,
        location_name,
        core_role,
        count(distinct job_id) as job_count

    from base
    group by year, month, region, location_name, core_role
)

select
    *,
    sum(job_count) over (partition by year, month) as total_jobs_month,
    safe_divide(job_count, sum(job_count) over (partition by year, month)) as pct_of_total

from aggregated