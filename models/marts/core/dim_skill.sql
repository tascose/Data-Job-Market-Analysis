{{ config(materialized='table', schema='marts') }}

with base as (
    select distinct skill, category
    from {{ ref('int_skill_normalized') }}
    where skill is not null
      and trim(skill) != ''
)

select
    to_hex(md5(skill))  as skill_key,
    skill               as skill_name,
    category            as skill_category

from base