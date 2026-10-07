-- sales by item category and fat content

select
    i.item_type,
    i.item_fat_content,
    count(*)                    as total_records,
    round(sum(f.sales), 2)      as total_sales,
    round(avg(f.sales), 2)      as avg_sale_value,
    round(avg(f.rating), 2)     as avg_rating
from {{ ref('fct_blinkit_sales') }} f
join {{ ref('dim_items') }} i
    on f.item_id = i.item_id
group by i.item_type, i.item_fat_content
