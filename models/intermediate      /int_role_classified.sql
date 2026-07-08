{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_title_parsed') }}
),

classified as (
    select
        *,
        case
            -- 1. Data Engineer (Bổ sung thêm: pipeline, platform, bdp, dwh)
            when regexp_contains(job_title_clean, r'data engineer|kỹ sư dữ liệu|\bde\b|data pipeline|big data|data platform|dwh engineer')
                then 'Data Engineer'
                
            -- 2. Data Analyst (Bổ sung thêm: analytics, insight, product analyst)
            when regexp_contains(job_title_clean, r'data analyst|business analyst|phân tích|\bba\b|\bda\b|analytics engineer|insight|product analyst|bi analyst')
                then 'Data Analyst'
                
            -- 3. Data Scientist/ML (Bổ sung thêm: deep learning, computer vision, r&d ai)
            when regexp_contains(job_title_clean, r'data scientist|machine learning|ml engineer|\bai\b|deep learning|computer vision|ai engineer|researcher')
                then 'Data Scientist/ML'
                
            -- 4. BI Developer
            when regexp_contains(job_title_clean, r'\bbi\b|business intelligence|báo cáo|report|tableau|power bi|looker')
                then 'BI Developer'
                
            -- 5. Data Architect
            when regexp_contains(job_title_clean, r'data architect|kiến trúc dữ liệu|solution architect')
                then 'Data Architect'
                
            -- 6. Database Admin
            when regexp_contains(job_title_clean, r'dba|database admin|quản trị cơ sở dữ liệu|database administrator')
                then 'Database Admin'
                
            -- 7. Các role liên quan tới Data nhưng chung chung khác
            when regexp_contains(job_title_clean, r'data|dữ liệu|thống kê|statistics')
                then 'Data Other'
                
            else 'Non-Data'
        end as core_role
    from base
)

select * from classified