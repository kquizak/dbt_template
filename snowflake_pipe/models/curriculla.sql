{{ config(materialized='incremental') }}
select UUID_STRING() as id, t.* from (
    select distinct
        c.key as field
    from {{ref("cte_curriculla")}} c
) t
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t WHERE t.field = c.key
)
{% endif %}