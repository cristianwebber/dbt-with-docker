-- Use the `ref` function to select from other models

select
    id
    , id2
    , now() as signup_date
from
    {{ ref('my_first_dbt_model') }}
where id = 1
