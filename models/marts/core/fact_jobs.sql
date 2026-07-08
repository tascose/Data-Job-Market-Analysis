{{ config(
    materialized='table',
    schema='marts'
) }}

with base as (
    select * from {{ ref('int_jobs_deduplicated') }}
),

final as (
    select
        b.job_id,

        -- Foreign keys trỏ tới các bảng dim
        to_hex(md5(b.company_name_clean))                       as company_key,
        to_hex(md5(b.location_clean))                           as location_key,
        to_hex(md5(cast(b.posted_at as string)))                as date_key,

        -- Thông tin công việc
        b.title                                                 as job_title_raw, -- 👈 Sửa từ job_title_raw thành title
        b.job_title_clean,
        b.job_level,
        b.core_role,

        -- Lương
        b.salary                                                as salary_raw,    -- 👈 Sửa từ salary_raw thành salary
        b.salary_min_vnd,
        b.salary_max_vnd,
        case
            when b.salary_min_vnd is not null and b.salary_max_vnd is not null
            then (b.salary_min_vnd + b.salary_max_vnd) / 2
            else null
        end as salary_avg_vnd,

        -- Metadata
        b.source_platform,
        b.url,
        b.posted_at,                                            -- 👈 Sửa thành posted_at
        cast(null as DATE)                                      as _collected_date, -- Giữ tạm để không vỡ cấu trúc của bạn
        current_timestamp()                                     as _loaded_at

    from base b
    -- Chỉ giữ job có date_key hợp lệ (posted_at không null)
    where b.posted_at is not null
)

select * from final