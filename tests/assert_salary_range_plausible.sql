select job_id, salary_min_vnd, salary_max_vnd
from {{ ref('fact_jobs') }}
where salary_min_vnd is not null
  and (salary_min_vnd < 3000000 or salary_min_vnd > 500000000)