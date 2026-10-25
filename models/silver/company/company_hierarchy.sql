{{ config(
    materialized = 'incremental',
    unique_key = 'source_unique_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns',
    tags = ['silver', 'company', 'company_hierarchy']
) }}

-- company_hierarchy hub: SCD1 merge over every onboarded source (UNION ALL branch per source).

with zoominfo_dev_source as (
    select * from {{ ref('zoominfo_dev_company_hierarchy') }}
    {% if is_incremental() %}
    where greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)
        > (select coalesce(max(greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
),

unioned as (
    -- ZOOMINFO_DEV
    select
        company_hierarchy_skey,
        source_unique_id,
        ref_gdp_source_system_skey,
        company_core_skey,
        company_name,
        ref_company_type_skey,
        domestic_parent_skey,
        global_parent_skey,
        hierarchy_level,
        hierarchy_path,
        valid_from,
        valid_to,
        ref_hierarchy_type_skey,
        company_hierarchy_hkey,
        gdp_is_active,
        gdp_inserted_ts,
        gdp_inserted_by,
        gdp_updated_ts,
        gdp_updated_by,
        immediate_parent_skey
    from zoominfo_dev_source where {{ m_is_source_active('zoominfo_dev') }}
)

select * from unioned
qualify row_number() over (partition by source_unique_id order by gdp_updated_ts desc) = 1
