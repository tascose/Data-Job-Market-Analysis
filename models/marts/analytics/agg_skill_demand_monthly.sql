{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select
        fs.skill_key,
        sk.skill_name,
        sk.skill_category,
        d.year,
        d.month,
        f.job_id,
        f.core_role
    from {{ ref('fact_job_skills') }} fs
    inner join {{ ref('fact_jobs') }} f on fs.job_id = f.job_id
    inner join {{ ref('dim_skill') }} sk on fs.skill_key = sk.skill_key
    inner join {{ ref('dim_date') }} d on f.date_key = d.date_key
),

aggregated as (
    select
        year,
        month,
        skill_key,
        skill_name,
        skill_category,
        count(distinct job_id) as job_count,
        count(distinct core_role) as role_diversity_count

    from base
    group by year, month, skill_key, skill_name, skill_category
)

select
    *,
    rank() over (
        partition by year, month
        order by job_count desc
    ) as demand_rank

from aggregated