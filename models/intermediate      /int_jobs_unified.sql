{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select 
        job_id,
        job_title_raw as title, 
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        -- Xử lý ngày của ITViec (5 hours ago, 1 day ago...)
        case 
            when posted_date_raw like '%ago%' or posted_date_raw like '%trước%' then current_date()
            else safe_cast(posted_date_raw as DATE)
        end as posted_at,
        raw_skill_tags as tags,
        url,
        source_platform
    from {{ ref('stg_itviec__jobs') }}
),

vietnamworks as (
    select 
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        -- VietnamWorks đã là ngày chuẩn, chỉ cần cast
        safe_cast(posted_date_raw as DATE) as posted_at, 
        raw_skill_tags as tags,
        url,
        source_platform
    from {{ ref('stg_vietnamworks__jobs') }}
),

careerviet as (
    select 
        job_id,
        job_title_raw as title,
        company_name_raw as company,
        location_raw as location,
        salary_raw as salary,
        -- CareerViet dạng DD-MM-YYYY, cần parse lại
        parse_date('%d-%m-%Y', posted_date_raw) as posted_at,
        raw_skill_tags as tags,
        url,
        source_platform
    from {{ ref('stg_careerviet__jobs') }}
),

unioned as (
    select * from itviec
    union all
    select * from vietnamworks
    union all
    select * from careerviet
)

select * from unioned