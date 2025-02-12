{{ config(materialized='incremental') }}
select 
    UUID_STRING() as id, 
    c.key as field
from {{ref("cte_curriculla")}} c
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t WHERE t.field = c.key
)
{% endif %}