{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_company_normalized') }}
)

select *
from base
where core_role != 'Non-Data'