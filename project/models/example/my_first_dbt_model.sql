{{ config(materialized='table') }}

with

source_data as (
    select 1 as id
    union all
    select null as id
)

select
    id
    , id as id2
from
    source_data
