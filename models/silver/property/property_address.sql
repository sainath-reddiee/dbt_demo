{{ config(
    materialized = 'incremental',
    unique_key = 'source_unique_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns',
    tags = ['silver', 'property', 'property_address']
) }}

-- property_address hub: SCD1 merge over every onboarded source (UNION ALL branch per source).

with lightbox_source as (
    select * from {{ ref('lightbox_property_address') }}
    {% if is_incremental() %}
    where greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)
        > (select coalesce(max(greatest(coalesce(gdp_inserted_ts, '1900-01-01'::timestamp_ntz), coalesce(gdp_updated_ts, '1900-01-01'::timestamp_ntz), '1900-01-01'::timestamp_ntz)), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
),

unioned as (
    -- LIGHTBOX
    select
        property_address_skey,
        source_unique_id,
        ref_gdp_source_system_skey,
        property_core_skey,
        ref_address_type_skey,
        address_line_1,
        address_line_2,
        street_name,
        street_number_1,
        street_number_2,
        pre_street_direction_name,
        street_type,
        post_street_direction_name,
        city,
        state_province,
        country,
        county,
        postal_code,
        state,
        postal_code_extension,
        street_number_3,
        latitude,
        longitude,
        source_address_line_1,
        source_address_line_2,
        source_street_name,
        source_street_number_1,
        source_street_number_2,
        source_pre_street_direction_name,
        source_street_type,
        source_post_street_direction_name,
        source_city,
        source_county,
        source_state,
        source_postal_code,
        source_postal_code_extension,
        source_country_name,
        source_street_number_3,
        source_geocode_output,
        source_latitude,
        source_longitude,
        source_latitude_override,
        source_longitude_override,
        source_geocode_override_source,
        address_match_score,
        address_match_code,
        geocode_output,
        address_precision_code,
        geocode_provider_name,
        geometry,
        property_address_hkey,
        gdp_is_active,
        gdp_inserted_ts,
        gdp_inserted_by,
        gdp_updated_ts,
        gdp_updated_by,
        source_street_name_pre_type,
        street_name_pre_type,
        country_iso2_code,
        country_iso3_code,
        state_iso_code
    from lightbox_source where {{ m_is_source_active('lightbox') }}
)

select * from unioned
qualify row_number() over (partition by source_unique_id order by gdp_updated_ts desc) = 1
