-- one row per outlet

select
    outlet_id,
    max(outlet_establishment_year)  as outlet_establishment_year,
    max(outlet_location_type)       as outlet_location_type,
    max(outlet_size)                as outlet_size,
    max(outlet_type)                as outlet_type
from {{ ref('stg_blinkit_orders') }}
group by outlet_id
