{{ config(materialized='ephemeral') }}
select 
t.key ,
t.value
from {{ref("gcs_stage")}} gs,
table(flatten(gs.raw_data:quiz)) t