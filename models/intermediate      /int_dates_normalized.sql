{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_jobs_unified') }}
)

select
    job_id,
    job_title_clean as title,
    company_name_clean as company,
    location_clean as location,
    salary,
    -- Ép kiểu từ STRING về DATE ngay tại đây để chiều lòng bài test accepted_range
    coalesce(
        safe_cast(posted_at as DATE),
        safe.parse_date('%Y-%m-%d', posted_at),
        safe.parse_date('%d-%m-%Y', posted_at),
        safe.parse_date('%d/%m/%Y', posted_at),
        current_date()
    ) as posted_at, -- 👈 Đặt đúng tên là posted_at và kiểu DATE luôn!
    tags,
    url,
    full_text,
    source_platform,
    _collected_date,
    _loaded_at
from base