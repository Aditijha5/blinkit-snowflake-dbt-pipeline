-- outlet-level performance summary for bi

select
    md5(o.outlet_id)                                     as outlet_sales_key,
    o.outlet_id,
    o.outlet_type,
    o.outlet_location_type,
    o.outlet_size,
    date_part('year', current_date) - o.outlet_establishment_year   as outlet_age_years,
    count(*)                                                        as total_records,
    round(sum(f.sales), 2)                                          as total_sales,
    round(avg(f.sales), 2)                                          as avg_sale_value,
    round(avg(f.rating), 2)                                         as avg_rating,
    round(avg(f.item_visibility), 4)                                as avg_item_visibility
from {{ ref('fct_blinkit_sales') }} f
join {{ ref('dim_outlets') }} o
    on f.outlet_id = o.outlet_id
group by
    o.outlet_id, o.outlet_type, o.outlet_location_type,
    o.outlet_size, o.outlet_establishment_year
