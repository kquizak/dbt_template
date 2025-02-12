{{ config(materialized='table') }}
select 
    UUID_STRING() as id, 
    c.id as curricula_id,
    f.key as question_key,
    f.value:question as question
from {{ref("cte_curriculla")}} t
cross join table(flatten(t.value)) f
join {{ref("curriculla")}} c on c.field = t.key
