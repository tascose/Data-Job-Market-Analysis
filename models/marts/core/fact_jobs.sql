{{ config(
    materialized='table',
    schema='marts'
) }}

-- FIX: cột _collected_date trước đây bị hard-code "cast(null as DATE)" (đặt NULL
-- cứng có chủ đích tạm thời), khiến toàn bộ fact_jobs mất giá trị ngày cào dữ
-- liệu thật. Giá trị thật (b._collected_date) đã tồn tại sẵn từ staging và
-- chảy nguyên vẹn qua toàn bộ chain intermediate tới đây -> dùng lại nó thay
-- vì hard-code NULL.

with base as (
    select * from {{ ref('int_jobs_deduplicated') }}
),

final as (
    select
        b.job_id,

        -- Foreign keys trỏ tới các bảng dim
        to_hex(md5(b.company_name_clean))                       as company_key,
        to_hex(md5(b.location_clean))                           as location_key,
        to_hex(md5(format_date('%Y-%m-%d', b.posted_at)))        as date_key,

        -- Thông tin công việc
        b.title                                                 as job_title_raw,
        b.job_title_clean,
        b.job_level,
        b.core_role,

        -- Lương
        b.salary                                                as salary_raw,
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
        b.posted_at,
        b._collected_date                                       as _collected_date, -- 👈 FIX: dùng giá trị thật thay vì NULL cứng
        current_timestamp()                                     as _loaded_at

    from base b
    -- Chỉ giữ job có date_key hợp lệ (posted_at không null)
    where b.posted_at is not null
)

select * from final