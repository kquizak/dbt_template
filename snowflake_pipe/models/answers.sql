{{ config( materialized='incremental',  unique_key=['question_id', 'option_value']) }}

with data as (
    select 
        parse_json(s.raw_data) as json
    from {{ref("gcs_stage")}} s
    where s.load_end_time is null
),
quiz as (
    select c.id,q.key, q.value
    from data d
        cross join table(flatten(json:quiz)) q
        join {{ref("curriculla")}} c on c.field = q.key
),
questions as (
    select 
        q.id as curriculla_id, q.key curriculla_key, 
        qq.id as question_id, c.key as question_key, c.value
    from quiz q
    cross join table(flatten(q.value)) c
    left join {{ref("questions")}} qq on qq.QUESTION_KEY = c.key and qq.curricula_id = q.id
),
source_data as (
    select 
        UUID_STRING() as id, 
        t.question_id,
        row_number() over (partition by t.question_id order by t.option_value) option_number,
        t.option_value, 
        t.is_correct, 
        t.effective_from, 
        t.effective_to, 
        t.is_active
    from (
        select distinct
            --UUID_STRING() as id,
            --c.curriculla_id,
            --c.curriculla_key,
            c.question_id,
            --c.question_key,
            --c.value:answer as correct_answer,
            --o.index  as option_number,
            o.value as option_value,
            case 
                when c.value:answer = o.value then 1
                else 0
            end as is_correct,
            '{{ run_started_at }}'::timestamp AS effective_from,
            NULL AS effective_to,
            TRUE AS is_active,
            row_number() over (partition by c.question_id,o.value order by 1) rn
        from questions c, 
            lateral flatten(c.value:options) o-- options
    ) t
    where rn = 1
)
{% if is_incremental() %}
,existing_data as (
    select * from {{ this }} where is_active = TRUE
)
, updated_existing AS (
    -- Mark old answers as inactive if there's a new version
    SELECT 
        e.id,
        e.question_id,
        e.option_number,
        e.option_value,
        e.is_correct,
        e.effective_from,
        '{{ run_started_at }}'::timestamp AS effective_to,
        FALSE AS is_active
    FROM existing_data e
    JOIN source_data s
    ON e.question_id = s.question_id 
    AND e.option_number = s.option_number
    AND e.option_value <> s.option_value -- Detect changes
)

{% endif %}
SELECT * FROM source_data
{% if is_incremental() %}
UNION ALL
SELECT * FROM updated_existing
{% endif %}