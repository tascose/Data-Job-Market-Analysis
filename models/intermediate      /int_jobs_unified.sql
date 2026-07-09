{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select 
        job_id,
        job_title_raw as job_title_clean,      -- 👈 Đổi tên thành _clean ngay từ gốc
        company_name_raw as company_name_clean,  -- 👈 Đổi tên thành _clean ngay từ gốc
        location_raw as location_clean,          -- 👈 Đổi tên thành _clean ngay từ gốc
        salary_raw as salary,
        cast(posted_date_raw as STRING) as posted_at, 
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
        job_title_raw as job_title_clean,
        company_name_raw as company_name_clean,
        location_raw as location_clean,
        salary_raw as salary,
        cast(posted_date_raw as STRING) as posted_at, 
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
        job_title_raw as job_title_clean,
        company_name_raw as company_name_clean,
        location_raw as location_clean,
        salary_raw as salary,
        cast(posted_date_raw as STRING) as posted_at, 
        raw_skill_tags as tags,
        url,
        full_text,
        source_platform,
        _collected_date,
        _loaded_at
    from {{ ref('stg_careerviet__jobs') }}
),

unioned as (
    select job_id, job_title_clean, company_name_clean, location_clean, salary, posted_at, tags, url, full_text, source_platform, _collected_date, _loaded_at from itviec
    union all
    select job_id, job_title_clean, company_name_clean, location_clean, salary, posted_at, tags, url, full_text, source_platform, _collected_date, _loaded_at from vietnamworks
    union all
    select job_id, job_title_clean, company_name_clean, location_clean, salary, posted_at, tags, url, full_text, source_platform, _collected_date, _loaded_at from careerviet
)

select * from unioned