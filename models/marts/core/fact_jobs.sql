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
        to_hex(md5(cast(b.posted_date as string)))              as date_key,

        -- Thông tin công việc
        b.job_title_raw,
        b.job_title_clean,
        b.job_level,
        b.core_role,

        -- Lương
        b.salary_raw,
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
        b.posted_date,
        b._collected_date,
        b._loaded_at

    from base b
    -- Chỉ giữ job có date_key hợp lệ (posted_date không null)
    where b.posted_date is not null
)

select * from final