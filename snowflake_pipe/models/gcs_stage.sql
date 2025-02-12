{{ config(materialized='incremental' , unique_key='md5') }}


WITH staged_files AS (
    SELECT
       UUID_STRING() as id,
        CURRENT_TIMESTAMP() AS load_time,
        cast(null as timestamp) as load_end_time,
        METADATA$FILENAME AS file_name,
        METADATA$FILE_CONTENT_KEY AS md5,
        $1 AS raw_data
    FROM {{ var("gcs_stage") }}
)

SELECT * 
FROM staged_files sf
{% if is_incremental() %}
WHERE NOT EXISTS (
    SELECT 1 FROM {{ this }} t WHERE t.md5 = sf.md5
)
{% endif %}