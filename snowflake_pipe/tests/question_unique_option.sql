select 
a.question_id, a.option_value, count(1) duplicates
from {{ref("answers")}} a
group by a.question_id, a.option_value  
having count(1) > 1