{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select * from {{ ref('stg_itviec__jobs') }}
),

vietnamworks as (
    select * from {{ ref('stg_vietnamworks__jobs') }}
),

careerviet as (
    select * from {{ ref('stg_careerviet__jobs') }}
),

unioned as (
    select * from itviec
    union all
    select * from vietnamworks
    union all
    select * from careerviet
)

select * from unioned