{{ config(
    materialized = 'incremental',
    unique_key = 'source_unique_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns',
    tags = ['silver', 'company', 'company_core']
) }}

-- company_core hub: SCD1 merge over every onboarded source (UNION ALL branch per source).

with salesforcecompany_source as (
    select * from {{ ref('salesforcecompany_company_core') }}
    {% if is_incremental() %}
    where greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)
        > (select coalesce(max(greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
),

unioned as (
    -- SALESFORCECOMPANY
    select
        company_core_skey,
        source_unique_id,
        ref_gdp_source_system_skey,
        duns_number,
        company_name,
        alias_name,
        ref_company_type_skey,
        ref_country_of_registration_skey,
        ref_address_skey,
        website_url,
        is_cbre_entity,
        company_status,
        company_core_hkey,
        gdp_is_active,
        gdp_inserted_ts,
        gdp_inserted_by,
        gdp_updated_ts,
        gdp_updated_by
    from salesforcecompany_source where {{ m_is_source_active('salesforcecompany') }}
)

select * from unioned
qualify row_number() over (partition by source_unique_id order by gdp_updated_ts desc) = 1
