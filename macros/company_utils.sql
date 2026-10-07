-- ====================================================================
-- company macros, created/extended by dbt-onboard-source.
-- ====================================================================

-- SHA2-256 over the business columns; NULLs become '' so the key is stable.
{% macro generate_sha2_hash_key(columns) -%}
    sha2(concat_ws('||'{% for c in columns %}, coalesce(cast({{ c }} as varchar), ''){% endfor %}), 256)
{%- endmacro %}

-- True when this source branch should load: --vars '{active_source: <key>}' or 'all' (default).
{% macro m_is_source_active(source_key) -%}
    {{ var('active_source', 'all') in ['all', source_key] }}
{%- endmacro %}

-- HKEY for dim_customers: pure business columns in DDL order (no *_SKEY, SOURCE_UNIQUE_ID or audit).
{% macro m_dim_customers_hkey() -%}
{{ generate_sha2_hash_key([
    'order_id',
    'customer_id',
    'order_date',
    'order_status',
    'total_amount',
    'shipping_address',
    'payment_method',
    'source_system',
    'order_item_id',
    'product_id',
    'quantity',
    'unit_price',
    'discount_pct',
    'product_name',
    'category',
    'sub_category',
    'supplier_id',
    'created_date',
    'metadata_filename',
    'metadata_row_number'
]) }}
{%- endmacro %}
