{{ config(materialized='table', schema='marts') }}

with base as (
    select 
        skill, 
        max(category) as category -- Chỉ lấy 1 category đại diện
    from {{ ref('int_skill_normalized') }}
    where skill is not null
      and trim(skill) != ''
    group by skill -- Gom nhóm theo từng skill duy nhất
)

select
    to_hex(md5(skill))  as skill_key,
    skill               as skill_name,
    category            as skill_category
from base