{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_dates_normalized') }}
),

cleaned as (
    select
        *,
        -- SỬA TẠI ĐÂY: Đổi job_title_raw thành title để khớp với tầng dữ liệu trước
        trim(lower(title)) as job_title_clean
    from base
),

leveled as (
    select
        * except (job_title_clean),
        job_title_clean,
        case
            when regexp_contains(job_title_clean, r'\b(intern|internship|thực tập|thực tập sinh)\b') then 'Intern'
            when regexp_contains(job_title_clean, r'\b(fresher|entry.?level|junior fresher)\b') then 'Fresher'
            when regexp_contains(job_title_clean, r'\b(junior|jr\.?)\b') then 'Junior'
            when regexp_contains(job_title_clean, r'\b(senior|sr\.?|experienced|expert|chuyên gia|chuyên viên cao cấp)\b') then 'Senior'
            when regexp_contains(job_title_clean, r'\b(lead|leader|manager|head of|trưởng nhóm|trưởng phòng|quản lý|principal|director|architect)\b') then 'Manager/Lead'
            when regexp_contains(job_title_clean, r'\b([4-9]|[1-9]\d)\s*(yoe|year|năm)\b') then 'Senior'
            when regexp_contains(job_title_clean, r'\b([2-3])\s*(yoe|year|năm)\b') then 'Middle'
            when regexp_contains(job_title_clean, r'\b([0-1])\s*(yoe|year|năm)\b') then 'Junior'
            else 'Null'
        end as job_level
    from cleaned
)

select * from leveled