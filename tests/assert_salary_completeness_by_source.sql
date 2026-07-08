{{ config(severity = 'warn') }}
select
    source_platform,
    count(*) as total_jobs,
    countif(salary_min_vnd is not null) as jobs_with_salary,
    safe_divide(countif(salary_min_vnd is not null), count(*)) as pct_with_salary
from {{ ref('int_jobs_deduplicated') }}
group by source_platform
having
    (source_platform = 'itviec' and safe_divide(countif(salary_min_vnd is not null), count(*)) > 0.10)
    or (source_platform in ('vietnamworks', 'careerviet') and safe_divide(countif(salary_min_vnd is not null), count(*)) < 0.03)