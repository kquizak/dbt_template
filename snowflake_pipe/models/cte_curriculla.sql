{{ config(materialized='ephemeral') }}
select 
t.key ,
t.value
from {{ref("gcs_stage")}} gs,
table(flatten(gs.raw_data:quiz)) t
where gs.load_end_time is null -- do not reprocess file already loaded