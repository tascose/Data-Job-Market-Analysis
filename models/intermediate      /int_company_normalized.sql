{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_location_normalized') }} 
),

step1_lower as (
    select
        *,
        -- SỬA TẠI ĐÂY: Đổi company_name_raw thành company
        lower(trim(coalesce(company, ''))) as c
    from base
),

step2_remove_legal as (
    select
        *,
        trim(regexp_replace(c,
            r'\b(tập đoàn|tổng công ty|ngân hàng thương mại cổ phần|ngân hàng tmcp|ngân hàng|công ty cổ phần|công ty tnhh|cổ phần|cty tnhh|cty cp|cty|tnhh|co\.,?\s?ltd\.?|joint stock company|joint stock|jsc|corporation|corp\.?|inc\.?|llc|group|việt nam|vietnam|viet nam)\b',
            ''
        )) as c2
    from step1_lower
),

step3_remove_brackets as (
    select
        *,
        trim(regexp_replace(c2, r'\s*\([^)]*\)\s*', ' ')) as c3
    from step2_remove_legal
),

step4_clean_punctuation as (
    select
        *,
        trim(regexp_replace(
            regexp_replace(c3, r'[,\.\-–—&]+\s*$', ''), 
            r'^\s*[,\.\-–—&]+', ''                        
        )) as c4
    from step3_remove_brackets
),

step5_normalize_spaces as (
    select
        *,
        trim(regexp_replace(c4, r'\s+', ' ')) as company_name_clean
    from step4_clean_punctuation
),

final as (
    select
        -- Loại bỏ các cột nháp tạm thời và cột company_name_clean cũ để tránh trùng lặp trùng tên
        * except (c, c2, c3, c4, company_name_clean),
        case
            when company_name_clean = '' or company_name_clean is null then 'Unknown'
            else company_name_clean
        end as company_name_clean
    from step5_normalize_spaces
)

select * from final