-- keep the latest row per business key
select *
from {{ ref('stg_lightbox__addresses') }}
qualify row_number() over (partition by 1 order by 1 desc) = 1
