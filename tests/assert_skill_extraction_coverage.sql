select count(distinct f.job_id) as jobs_without_skill
from {{ ref('fact_jobs') }} f
left join {{ ref('fact_job_skills') }} fs on f.job_id = fs.job_id
where fs.job_id is null
having count(distinct f.job_id) > (select count(*) * 0.5 from {{ ref('fact_jobs') }})