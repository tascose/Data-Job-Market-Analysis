select
    countif(core_role = 'Non-Data') as non_data_count,
    count(*) as total_count,
    safe_divide(countif(core_role = 'Non-Data'), count(*)) as non_data_rate
from {{ ref('int_role_classified') }}
having safe_divide(countif(core_role = 'Non-Data'), count(*)) > 0.30 