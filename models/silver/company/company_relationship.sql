{{ config(
    materialized = 'incremental',
    unique_key = 'source_unique_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns',
    tags = ['silver', 'company', 'company_relationship']
) }}

-- company_relationship hub: SCD1 merge over every onboarded source (UNION ALL branch per source).

with zoominfo_dev_source as (
    select * from {{ ref('zoominfo_dev_company_relationship') }}
    {% if is_incremental() %}
    where greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)
        > (select coalesce(max(greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
),

unioned as (
    -- ZOOMINFO_DEV
    select
        company_relationship_skey,
        source_unique_id,
        ref_gdp_source_system_skey,
        company_core_skey,
        ref_relationship_type_skey,
        account_name,
        account_number,
        account_status,
        source_account_id,
        relationship_start_date,
        relationship_end_date,
        company_relationship_hkey,
        gdp_is_active,
        gdp_inserted_ts,
        gdp_inserted_by,
        gdp_updated_ts,
        gdp_updated_by
    from zoominfo_dev_source where {{ m_is_source_active('zoominfo_dev') }}
)

select * from unioned
qualify row_number() over (partition by source_unique_id order by gdp_updated_ts desc) = 1
