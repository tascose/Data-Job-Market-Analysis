{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select
        f.job_id,
        f.core_role,
        f.job_level,
        f.salary_min_vnd,
        f.salary_max_vnd,
        f.salary_avg_vnd
    from {{ ref('fact_jobs') }} f
    where f.salary_min_vnd is not null
      and f.salary_max_vnd is not null
),

percentiles as (
    select
        core_role,
        job_level,
        count(*) as sample_size,
        approx_quantiles(salary_avg_vnd, 100)[offset(25)] as p25_salary_vnd,
        approx_quantiles(salary_avg_vnd, 100)[offset(50)] as median_salary_vnd,
        approx_quantiles(salary_avg_vnd, 100)[offset(75)] as p75_salary_vnd,
        approx_quantiles(salary_avg_vnd, 100)[offset(90)] as p90_salary_vnd,
        min(salary_avg_vnd) as min_salary_vnd,
        max(salary_avg_vnd) as max_salary_vnd

    from base
    group by core_role, job_level
)

select
    *,
    case
        when sample_size < 5 then true
        else false
    end as is_low_sample_warning

from percentiles