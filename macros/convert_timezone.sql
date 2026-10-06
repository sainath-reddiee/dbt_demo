{% macro convert_timezone(column_name, target_tz='UTC') %}
    CONVERT_TIMEZONE('UTC', '{{ target_tz }}', {{ column_name }}::timestamp_ntz)
{% endmacro %}
