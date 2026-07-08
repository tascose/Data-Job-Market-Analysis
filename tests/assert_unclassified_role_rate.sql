select
    countif(core_role in ('Other Data', 'Unknown')) as unclassified_count,
    count(*) as total_count,
    safe_divide(countif(core_role in ('Other Data', 'Unknown')), count(*)) as unclassified_rate
from {{ ref('int_role_classified') }}
having safe_divide(countif(core_role in ('Other Data', 'Unknown')), count(*)) > 0.30