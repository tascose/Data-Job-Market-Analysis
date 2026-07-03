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
        -- vietnamworks: posted_at kiểu DATE → cast sang string
        cast(posted_at as string)     as posted_date_raw,
        nullif(trim(salary), '')      as salary_raw,

        concat(
            coalesce(descriptions, ''), ' ',
            coalesce(requirements, '')
        ) as full_text,

        nullif(trim(tags), '')        as raw_skill_tags,
        url,

        -- Vietnamworks không có mode/benefits/top_reasons → NULL
        cast(null as string)          as job_mode,
        cast(null as string)          as benefits,
        cast(null as string)          as top_reasons,

        'vietnamworks'                                                        as source_platform,
        date(cast(year as int64), cast(month as int64), cast(day as int64))  as _collected_date,
        current_timestamp()                                                   as _loaded_at

    from source

),

final as (

    select *
    from renamed
    where job_title_raw is not null
      and company_name_raw is not null
      and url is not null

)

select * from final