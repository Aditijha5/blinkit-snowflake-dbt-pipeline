-- fact table: one row per item-outlet sales record, with a generated surrogate key

with orders as (

    select
        *,
        row_number() over (
            partition by item_id, outlet_id
            order by sales, rating
        ) as occurrence_no
    from {{ ref('stg_blinkit_orders') }}

)

select
    md5(concat_ws('|', item_id, outlet_id, occurrence_no::varchar)) as blinkit_sale_key,
    item_id,
    outlet_id,
    sales,
    rating,
    item_visibility
from orders
