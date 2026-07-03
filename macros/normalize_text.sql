{% macro normalize_for_compare(column) %}
    lower(trim(
        regexp_replace(
        regexp_replace(
            {{ column }},
            r'[^\w\s]', ' '   -- xóa ký tự đặc biệt
        ),
        r'\s+', ' '           -- xóa khoảng trắng thừa
        )
    ))
{% endmacro %}

{% macro test_row_count_between(model, min_rows, max_rows) %}

select count(*) as row_count
from {{ model }}
having count(*) < {{ min_rows }} or count(*) > {{ max_rows }}

{% endmacro %}
