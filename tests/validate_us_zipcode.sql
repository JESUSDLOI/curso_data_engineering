{% macro validate_us_zipcode(column_name) %}
    {{ column_name }} ~ '^\d{5}(-\d{4})?$'
{% endmacro %}
