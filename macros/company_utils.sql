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

{% macro m_get_source_system_skey_company(source_system_name) -%}
    select distinct GDP_SOURCE_SYSTEM_SKEY as gdp_source_system_skey
    from {{ source('company_shared_reference', 'ref_gdp_source_system') }}
    where upper(GDP_SOURCE_SYSTEM_NAME) = '{{ source_system_name | upper }}'
{%- endmacro %}

-- HKEY for company_core: pure business columns in DDL order (no *_SKEY, SOURCE_UNIQUE_ID or audit).
{% macro m_company_core_hkey() -%}
{{ generate_sha2_hash_key([
    'duns_number',
    'company_name',
    'alias_name',
    'website_url',
    'is_cbre_entity',
    'company_status'
]) }}
{%- endmacro %}
