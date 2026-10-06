{% macro safe_divide(numerator, denominator) %}
    IFF({{ denominator }} = 0, NULL, {{ numerator }} / {{ denominator }})
{% endmacro %}
