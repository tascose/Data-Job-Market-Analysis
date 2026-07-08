select
    countif(core_role in ('Data Other', 'Non-Data')) as unclassified_count,
    count(*) as total_count,
    safe_divide(countif(core_role in ('Data Other', 'Non-Data')), count(*)) as unclassified_rate
from {{ ref('int_role_classified') }}
having safe_divide(countif(core_role in ('Data Other', 'Non-Data')), count(*)) > 0.40