{{ config(materialized='incremental') }}
select 
    UUID_STRING() as id, t.*
from (
    select distinct 
        c.id as curricula_id,
        f.key as question_key,
        f.value:question as question
    from {{ref("cte_curriculla")}} t
    cross join table(flatten(t.value)) f
    join {{ref("curriculla")}} c on c.field = t.key
) t
{% if is_incremental() %}
where (f.key,c.id) not in (
    select question_key, curricula_id from {{ this }}
)
{% endif %}