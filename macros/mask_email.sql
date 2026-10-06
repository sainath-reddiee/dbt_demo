{% macro mask_email(column_name) %}
    CASE
        WHEN {{ column_name }} LIKE '%@%' THEN CONCAT(LEFT({{ column_name }}, 2), '***', SUBSTR({{ column_name }}, POSITION('@' IN {{ column_name }})))
        ELSE '***INVALID_EMAIL***'
    END
{% endmacro %}
