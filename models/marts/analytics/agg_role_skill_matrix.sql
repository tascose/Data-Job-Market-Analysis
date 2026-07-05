{{ config(
    materialized='table',
    schema='marts'
) }}

with jobs_by_role as (
    select
        core_role,
        count(distinct job_id) as total_jobs_in_role
    from {{ ref('fact_jobs') }}
    group by core_role
),

skill_role_pairs as (
    select
        f.core_role,
        fs.skill_key,
        sk.skill_name,
        sk.skill_category,
        f.job_id
    from {{ ref('fact_jobs') }} f
    inner join {{ ref('fact_job_skills') }} fs on f.job_id = fs.job_id
    inner join {{ ref('dim_skill') }} sk on fs.skill_key = sk.skill_key
),

aggregated as (
    select
        core_role,
        skill_key,
        skill_name,
        skill_category,
        count(distinct job_id) as job_count
    from skill_role_pairs
    group by core_role, skill_key, skill_name, skill_category
)

select
    a.*,
    r.total_jobs_in_role,
    safe_divide(a.job_count, r.total_jobs_in_role) as pct_of_role_jobs,
    rank() over (partition by a.core_role order by a.job_count desc) as skill_rank_within_role
from aggregated a
inner join jobs_by_role r on a.core_role = r.core_role