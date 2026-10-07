{% snapshot dim_customers_snapshot %}
{{ config(
    target_schema = target.schema,
    unique_key = 'source_unique_id',
    strategy = 'check',
    check_cols = 'all',
    invalidate_hard_deletes = true
) }}

-- Full history of dim_customers (SCD2): one row per version, dbt_valid_from/dbt_valid_to bound each.
select * from {{ ref('raw_dim_customers') }}

{% endsnapshot %}
