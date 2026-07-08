{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select 
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        posted_date_raw as posted_at, 
        raw_skill_tags as tags,
        url,
        full_text,
        source_platform,
        _collected_date,
        _loaded_at
    from {{ ref('stg_itviec__jobs') }}
),

vietnamworks as (
    select 
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        posted_date_raw as posted_at, 
        raw_skill_tags as tags,
        url,
        full_text,
        source_platform,
        _collected_date,
        _loaded_at
    from {{ ref('stg_vietnamworks__jobs') }}
),

careerviet as (
    select 
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        posted_date_raw as posted_at, 
        raw_skill_tags as tags,
        url,
        full_text,
        source_platform,
        _collected_date,
        _loaded_at
    from {{ ref('stg_careerviet__jobs') }}
),

unioned as (
    select job_id, title, company, location, salary, posted_at, tags, url, full_text, source_platform, _collected_date, _loaded_at from itviec
    union all
    select job_id, title, company, location, salary, posted_at, tags, url, full_text, source_platform, _collected_date, _loaded_at from vietnamworks
    union all
    select job_id, title, company, location, salary, posted_at, tags, url, full_text, source_platform, _collected_date, _loaded_at from careerviet
)

select * from unioned