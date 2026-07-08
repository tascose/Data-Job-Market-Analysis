{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select
        f.job_id,
        f.core_role,
        f.job_level,
        d.year,
        d.month
    from {{ ref('fact_jobs') }} f
    inner join {{ ref('dim_date') }} d on f.date_key = d.date_key
),

aggregated as (
    select
        year,
        month,
        core_role,
        job_level,
        count(distinct job_id) as job_count

    from base
    group by year, month, core_role, job_level
),

with_growth as (
    select
        *,
        lag(job_count) over (
            partition by core_role, job_level
            order by year, month
        ) as job_count_prev_month

    from aggregated
)

select
    *,
    safe_divide(job_count - job_count_prev_month, job_count_prev_month) as mom_growth_rate

from with_growth