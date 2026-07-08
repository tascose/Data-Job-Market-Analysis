{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select 
        job_id,
        title,
        company,
        location,
        -- ITViec không có cột salary trong JSON, ta chủ động bù NULL để đồng bộ cấu trúc
        cast(null as STRING) as salary, 
        
        -- XỬ LÝ NGÀY THÁNG: Vì ITViec cào về dạng "5 hours ago", "1 day ago"... 
        -- Nếu không phải định dạng ngày chuẩn YYYY-MM-DD, ta để tạm CURRENT_DATE() hoặc NULL để tránh crash
        case 
            when posted_at like '%ago%' or posted_at like '%trước%' then current_date()
            else safe_cast(posted_at as DATE)
        end as posted_at,
        
        -- ITViec không có cột tags (chỉ có kĩ năng), ta điền NULL hoặc map từ cột khác nếu cần
        cast(null as STRING) as tags,
        url
    from {{ ref('stg_itviec__jobs') }}
),

vietnamworks as (
    select 
        job_id,
        title,
        company,
        location,
        salary,
        -- VietnamWorks ở tầng staging hoặc python đã được đưa về DATE (YYYY-MM-DD)
        cast(posted_at as DATE) as posted_at, 
        tags,
        url
    from {{ ref('stg_vietnamworks__jobs') }}
),

careerviet as (
    select 
        job_id,
        title,
        company,
        location,
        salary,
        -- XỬ LÝ NGÀY THÁNG: Chuỗi của CareerViet là '08-07-2026' (DD-MM-YYYY)
        -- Ta cần dùng PARSE_DATE để BigQuery hiểu đúng cấu trúc ngày trước khi UNION
        parse_date('%d-%m-%Y', posted_at) as posted_at,
        tags,
        url
    from {{ ref('stg_careerviet__jobs') }}
),

unioned as (
    select job_id, title, company, location, salary, posted_at, tags, url from itviec
    union all
    select job_id, title, company, location, salary, posted_at, tags, url from vietnamworks
    union all
    select job_id, title, company, location, salary, posted_at, tags, url from careerviet
)

select * from unioned