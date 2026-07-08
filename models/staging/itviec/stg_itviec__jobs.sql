with source as (

    select *
    from {{ source('raw_jobdata', 'itviec_raw') }}

),

renamed as (

    select
        -- Sinh job_id bằng MD5
        to_hex(md5(concat(
            coalesce(trim(title), ''), '|',
            coalesce(trim(company), ''), '|',
            coalesce(trim(url), '')
        ))) as job_id,

        -- Chuẩn hóa các trường
        nullif(trim(title), '')       as job_title_raw,
        nullif(trim(company), '')     as company_name_raw,
        nullif(trim(location), '')    as location_raw,

        -- posted_at có thể là "N/A" hoặc rỗng → chuẩn hóa về NULL trước khi lưu string
        nullif(trim(cast(posted_at as string)), 'N/A') as posted_date_raw,

        -- itviec KHÔNG có salary → đặt NULL để khớp schema với 2 bảng kia
        cast(null as string)          as salary_raw,

        concat(
            coalesce(descriptions, ''), ' ',
            coalesce(requirements, '')
        ) as full_text,

        nullif(trim(tags), '')        as raw_skill_tags,
        url,

        -- Cột riêng của itviec
        nullif(trim(mode), '')        as job_mode,
        nullif(trim(benefits), '')    as benefits,
        nullif(trim(top_reasons), '') as top_reasons,

        -- Metadata
        'itviec'                                                              as source_platform,
        date(cast(year as int64), cast(month as int64), cast(day as int64))  as _collected_date,
        current_timestamp()                                                   as _loaded_at

    from source

),

filtered as (

    select *
    from renamed
    where job_title_raw is not null
      and company_name_raw is not null
      and url is not null

),

dedup as (

    select *,
        row_number() over (
            partition by job_id
            order by _loaded_at desc
        ) as rn

    from filtered

),

final as (

    select * except(rn)
    from dedup
    where rn = 1

)

select * from final