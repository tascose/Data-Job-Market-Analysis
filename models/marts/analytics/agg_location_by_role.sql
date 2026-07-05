{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select
        f.core_role,
        l.location_name,
        l.region,
        f.job_id
    from {{ ref('fact_jobs') }} f
    inner join {{ ref('dim_location') }} l on f.location_key = l.location_key
)

select
    core_role,
    location_name,
    region,
    count(distinct job_id) as job_count
from base
group by core_role, location_name, region