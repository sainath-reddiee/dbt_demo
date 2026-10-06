{% macro clean_boolean(column_name) %}
    CASE
        WHEN UPPER(TRIM({{ column_name }})) IN ('Y', 'YES', '1', 'TRUE') THEN TRUE
        WHEN UPPER(TRIM({{ column_name }})) IN ('N', 'NO', '0', 'FALSE') THEN FALSE
        ELSE NULL
    END
{% endmacro %}
