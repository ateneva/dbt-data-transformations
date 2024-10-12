{% macro round_numeric(column_name, decimal_places=2) %}
    round( 1.0 * {{ column_name }}, {{ decimal_places }})
{% endmacro %}
