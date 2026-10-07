-- one row per item

select
    item_id,
    max(item_type)                  as item_type,
    max(item_fat_content)           as item_fat_content,
    avg(item_weight)                as avg_item_weight
from {{ ref('stg_blinkit_orders') }}
group by item_id
