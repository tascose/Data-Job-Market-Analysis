with source as (

    select *
    from {{ source('raw_jobdata', 'vietnamworks_raw') }}

),

renamed as (

    select
        to_hex(md5(concat(
            coalesce(trim(title), ''), '|',
            coalesce(trim(company), ''), '|',
            coalesce(trim(url), '')
        ))) as job_id,

        nullif(trim(title), '')       as job_title_raw,
        nullif(trim(company), '')     as company_name_raw,
        nullif(trim(location), '')    as location_raw,

        -- posted_at ở nguồn là STRING (vd "11/06/2026" hoặc "N/A")
        -- parse an toàn: sai định dạng hoặc "N/A" đều ra NULL thay vì làm vỡ query
        safe.parse_date('%d/%m/%Y', nullif(trim(cast(posted_at as string)), 'N/A')) as posted_date_raw,

        nullif(trim(salary), '')      as salary_raw,

        concat(
            coalesce(descriptions, ''), ' ',
            coalesce(requirements, '')
        ) as full_text,

        nullif(trim(tags), '')        as raw_skill_tags,
        url,

        cast(null as string)          as job_mode,
        cast(null as string)          as benefits,
        cast(null as string)          as top_reasons,

        'vietnamworks'                                                        as source_platform,
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