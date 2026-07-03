{{ config(
    materialized='table',
    schema='marts'
) }}

with skills as (
    select * from {{ ref('int_skill_normalized') }}
),

jobs as (
    select job_id from {{ ref('fact_jobs') }}
)

select
    s.job_id,
    to_hex(md5(s.skill))    as skill_key,
    s.skill                 as skill_name

from skills s
-- Chỉ giữ skill của job có trong fact_jobs (đã qua filter)
inner join jobs j on s.job_id = j.job_id