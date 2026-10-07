-- singular test: fails if any sales value is negative
select *
from {{ ref('fct_blinkit_sales') }}
where sales < 0
