{{ config(materialized='view', schema='intermediate') }}

with base as (
    select * from {{ ref('int_jobs_filtered_it') }}
),

scored as (
    select
        *,
        (case when salary_raw is not null and salary_raw != '' then 2 else 0 end)
        + (case when posted_date is not null then 1 else 0 end)
        as quality_score
    from base
),

ranked as (
    select
        *,
        row_number() over (
            partition by
                job_title_clean,
                company_name_clean,
                location_clean
            order by
                quality_score desc,
                case source_platform
                    when 'itviec'       then 1
                    when 'careerviet'   then 2
                    when 'vietnamworks' then 3
                    else 4
                end,
                posted_date desc nulls last,
                _loaded_at desc
        ) as dedup_rank
    from scored
)

select * except (dedup_rank, quality_score)
from ranked
where dedup_rank = 1