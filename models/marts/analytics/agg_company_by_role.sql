{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select
        f.core_role,
        c.company_key,
        c.company_name,
        f.job_id
    from {{ ref('fact_jobs') }} f
    inner join {{ ref('dim_company') }} c on f.company_key = c.company_key
)

select
    core_role,
    company_key,
    company_name,
    count(distinct job_id) as job_count
from base
group by core_role, company_key, company_name