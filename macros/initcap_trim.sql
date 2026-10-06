{% macro initcap_trim(column_name) %}
    INITCAP(TRIM({{ column_name }}))
{% endmacro %}
