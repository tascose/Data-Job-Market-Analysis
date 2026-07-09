{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_role_classified') }}
),

cleaned as (
    select
        *,
        trim(lower(salary)) as salary_clean
    from base
),

extracted as (
    select
        *,
        case
            when salary_clean = '' then null
            when regexp_contains(salary_clean, r'thương lượng|negotiate|negotiable|cạnh tranh|competitive|thoả thuận')
                then null
            when regexp_contains(salary_clean, r'usd|\$')
                then cast(regexp_replace(regexp_extract(salary_clean, r'([\d,\.]+)'), r',', '') as float64) * 26000
            when regexp_contains(salary_clean, r'triệu|tr\b|million')
                then cast(regexp_replace(regexp_extract(salary_clean, r'([\d,\.]+)'), r',', '') as float64) * 1000000
            else null
        end as salary_min_vnd,

        case
            when salary_clean = '' then null
            when regexp_contains(salary_clean, r'thương lượng|negotiate|negotiable|cạnh tranh|competitive|thoả thuận')
                then null
            when regexp_contains(salary_clean, r'usd|\$')
                then (select max(cast(regexp_replace(x, r',', '') as float64)) from unnest(regexp_extract_all(salary_clean, r'[\d,\.]+')) x) * 26000
            when regexp_contains(salary_clean, r'triệu|tr\b|million')
                then (select max(cast(regexp_replace(x, r',', '') as float64)) from unnest(regexp_extract_all(salary_clean, r'[\d,\.]+')) x) * 1000000
            else null
        end as salary_max_vnd
    from cleaned
)

select * from extracted