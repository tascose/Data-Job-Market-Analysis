{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_salary_parsed') }}
),

normalized as (
    select
        *,
        case
            when regexp_contains(lower(coalesce(location,'')), r'hà\s*nội|ha\s*noi|hanoi')
                then 'Hà Nội'
            when regexp_contains(lower(coalesce(location,'')), r'hồ\s*chí\s*minh|ho\s*chi\s*minh|\bhcm\b|tp\.?\s*hcm|sài\s*gòn|saigon|tphcm')
                then 'Hồ Chí Minh'
            when regexp_contains(lower(coalesce(location,'')), r'đà\s*nẵng|da\s*nẵng|da\s*nang|danang|đanẵng')
                then 'Đà Nẵng'
            when regexp_contains(lower(coalesce(location,'')), r'\bremote\b|từ\s*xa|work\s*from\s*home|\bwfh\b|toàn\s*quốc|nationwide')
                then 'Remote'
            when location is null or trim(location) = ''
                then 'Không xác định'
            else 'Khác'
        end as location_clean
    from base
),

regioned as (
    select
        *,
        case
            when location_clean = 'Hà Nội' then 'Miền Bắc'
            when location_clean = 'Hồ Chí Minh' then 'Miền Nam'
            when location_clean = 'Đà Nẵng' then 'Miền Trung'
            when location_clean = 'Remote' then 'Remote'
            else 'Khác'
        end as region
    from normalized
)

select * from regioned