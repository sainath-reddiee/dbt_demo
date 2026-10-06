{% macro standardize_phone(column_name) %}
    REGEXP_REPLACE({{ column_name }}, '[^0-9]', '')
{% endmacro %}
