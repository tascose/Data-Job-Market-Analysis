select source_platform, count(*) as job_count
from {{ ref('int_jobs_unified') }}
group by source_platform
having count(*) < 10