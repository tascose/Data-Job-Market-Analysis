{{ config(materialized='view', schema='intermediate') }}

with itviec as (
    select 
        job_id,
        title,
        company,
        location,
        salary,
        -- Nếu bên stg_itviec cột này đang là STRING, ta CAST nó về DATE để đồng bộ với VietnamWorks
        cast(posted_at as DATE) as posted_at, 
        tags,
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
        posted_at, -- Cột này đã là DATE sẵn từ file Python/Staging trước đó
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
        -- Nếu bên stg_careerviet cột này đang là STRING, ta cũng CAST nó về DATE
        cast(posted_at as DATE) as posted_at, 
        tags,
        url
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