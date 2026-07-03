{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_title_parsed') }}
),

classified as (
    select
        *,
        case
            when regexp_contains(job_title_clean, r'data engineer|kỹ sư dữ liệu|\bde\b')
                then 'Data Engineer'
            when regexp_contains(job_title_clean, r'data analyst|business analyst|phân tích|\bba\b|\bda\b')
                then 'Data Analyst'
            when regexp_contains(job_title_clean, r'data scientist|machine learning|ml engineer|\bai\b')
                then 'Data Scientist/ML'
            when regexp_contains(job_title_clean, r'\bbi\b|business intelligence|báo cáo')
                then 'BI Developer'
            when regexp_contains(job_title_clean, r'data architect|kiến trúc dữ liệu')
                then 'Data Architect'
            when regexp_contains(job_title_clean, r'dba|database admin|quản trị cơ sở dữ liệu')
                then 'Database Admin'
            when regexp_contains(job_title_clean, r'data|dữ liệu')
                then 'Data Other'
            else 'Non-Data'
        end as core_role
    from base
)

select * from classified