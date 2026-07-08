select f.job_id, d.posted_date
from {{ ref('fact_jobs') }} f
join {{ ref('dim_date') }} d on f.date_key = d.date_key
where d.posted_date > current_date()