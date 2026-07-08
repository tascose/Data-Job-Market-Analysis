{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_jobs_unified') }}
)

select * from base