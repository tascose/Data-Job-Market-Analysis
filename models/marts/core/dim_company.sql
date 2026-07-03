{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select distinct
        company_name_clean
    from {{ ref('int_jobs_deduplicated') }}
    where company_name_clean is not null
      and company_name_clean != 'Unknown'
)

select
    to_hex(md5(company_name_clean))     as company_key,
    company_name_clean                  as company_name

from base