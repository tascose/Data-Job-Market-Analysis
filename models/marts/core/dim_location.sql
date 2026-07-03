{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select distinct
        location_clean,
        region
    from {{ ref('int_jobs_deduplicated') }}
    where location_clean is not null
)

select
    to_hex(md5(location_clean))     as location_key,
    location_clean                  as location_name,
    region

from base