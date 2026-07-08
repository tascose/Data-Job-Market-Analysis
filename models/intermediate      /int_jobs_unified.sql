{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        cast(null as STRING) as salary,
        case
            when posted_date_raw like '%ago%' or posted_date_raw like '%trước%' then current_date()
            else safe_cast(posted_date_raw as DATE)
        end as posted_at,
        cast(null as STRING) as tags,
        url,
        'itviec' as source_platform
    from {{ ref('stg_itviec__jobs') }}
),

vietnamworks as (
    select
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        safe_cast(posted_date_raw as DATE) as posted_at,
        raw_skill_tags as tags,
        url,
        'vietnamworks' as source_platform
    from {{ ref('stg_vietnamworks__jobs') }}
),

careerviet as (
    select
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        coalesce(
            safe_cast(posted_date_raw as DATE),
            safe.parse_date('%d-%m-%Y', posted_date_raw),
            safe.parse_date('%d/%m/%Y', posted_date_raw)
        ) as posted_at,
        raw_skill_tags as tags,
        url,
        'careerviet' as source_platform
    from {{ ref('stg_careerviet__jobs') }}
),

unioned as (
    select job_id, title, company, location, salary, posted_at, tags, url, source_platform from itviec
    union all
    select job_id, title, company, location, salary, posted_at, tags, url, source_platform from vietnamworks
    union all
    select job_id, title, company, location, salary, posted_at, tags, url, source_platform from careerviet
)

select * from unioned