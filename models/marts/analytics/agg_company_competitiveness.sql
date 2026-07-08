{{ config(
    materialized='table',
    schema='marts'
) }}

with company_jobs as (
    select
        f.job_id,
        c.company_key,
        c.company_name,
        f.core_role,
        f.salary_min_vnd,
        f.salary_max_vnd,
        f.salary_avg_vnd
    from {{ ref('fact_jobs') }} f
    inner join {{ ref('dim_company') }} c on f.company_key = c.company_key
),

company_skills as (
    select
        cj.company_key,
        count(distinct fs.skill_key) as unique_skill_count
    from company_jobs cj
    inner join {{ ref('fact_job_skills') }} fs on cj.job_id = fs.job_id
    group by cj.company_key
),

company_agg as (
    select
        company_key,
        company_name,
        count(distinct job_id)        as total_job_postings,
        count(distinct core_role)     as role_diversity_count,
        avg(salary_avg_vnd)           as avg_salary_offered_vnd

    from company_jobs
    group by company_key, company_name
)

select
    a.*,
    s.unique_skill_count,
    a.avg_salary_offered_vnd - avg(a.avg_salary_offered_vnd) over () as salary_diff_vs_market_avg

from company_agg a
left join company_skills s on a.company_key = s.company_key