-- staging: rename, trim, standardise categories and cast types. no business logic here.

with source as (

    select * from {{ source('blinkit_raw', 'blinkit_orders_raw') }}

),

cleaned as (

    select
        trim(item_identifier)                       as item_id,
        trim(item_type)                             as item_type,

        -- raw data has 5 spellings for 2 categories
        case lower(trim(item_fat_content))
            when 'low fat' then 'Low Fat'
            when 'lf'      then 'Low Fat'
            when 'regular' then 'Regular'
            when 'reg'     then 'Regular'
            else 'Unknown'
        end                                         as item_fat_content,

        trim(outlet_identifier)                     as outlet_id,
        outlet_establishment_year::int              as outlet_establishment_year,
        trim(outlet_location_type)                  as outlet_location_type,
        coalesce(trim(outlet_size), 'Unknown')      as outlet_size,
        trim(outlet_type)                           as outlet_type,

        item_visibility::float                      as item_visibility,
        item_weight::float                          as item_weight,
        sales::float                                as sales,
        rating::float                               as rating

    from source
    where item_identifier is not null
      and outlet_identifier is not null

)

select * from cleaned
