{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select core_role, job_level, job_id
    from {{ ref('fact_jobs') }}
),

aggregated as (
    select
        core_role,
        job_level,
        count(distinct job_id) as job_count
    from base
    group by core_role, job_level
)

select
    *,
    safe_divide(job_count, sum(job_count) over (partition by core_role)) as pct_within_role
from aggregated