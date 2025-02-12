{{ config(materialized='ephemeral') }}
select 
t.key ,
t.value
from {{ref("gcs_stage")}} gs,
table(flatten(gs.row_data:quiz)) t