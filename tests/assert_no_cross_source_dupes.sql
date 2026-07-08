select job_title_clean, company_name_clean, posted_date, location_clean, count(*) as cnt
from {{ ref('int_jobs_deduplicated') }}
group by job_title_clean, company_name_clean, posted_date, location_clean
having count(*) > 1