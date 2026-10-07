{{ config(
    materialized = 'view',
    tags = ['model', 'company', 'dim_customers']
) }}

-- dim_customers: the current version of each record; history lives in snapshot dim_customers_snapshot.

select
    source_unique_id,
    raw_data,
    source_file,
    load_timestamp,
    record_metadata,
    event_data,
    event_type,
    received_at,
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount,
    shipping_address,
    payment_method,
    source_system,
    order_item_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,
    product_name,
    category,
    sub_category,
    supplier_id,
    is_active,
    created_date,
    metadata_filename,
    metadata_row_number,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref('dim_customers_snapshot') }}
where dbt_valid_to is null
