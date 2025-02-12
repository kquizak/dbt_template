{% macro upd_load_end(model_name,column_name)%}
    UPDATE {{ ref(model_name) }} SET {{ column_name }} = CURRENT_TIMESTAMP WHERE {{ column_name }}  IS NULL
{% endmacro %}