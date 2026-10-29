-- ====================================================================
-- property macros, created/extended by dbt-onboard-source.
-- ====================================================================

{% macro m_get_source_system_skey_property(source_system_name) -%}
    select distinct GDP_SOURCE_SYSTEM_SKEY as gdp_source_system_skey
    from {{ source('property_shared_reference', 'ref_gdp_source_system') }}
    where upper(GDP_SOURCE_SYSTEM_NAME) = '{{ source_system_name | upper }}'
{%- endmacro %}

-- HKEY for property_address: pure business columns in DDL order (no *_SKEY, SOURCE_UNIQUE_ID or audit).
{% macro m_property_address_hkey() -%}
{{ generate_sha2_hash_key([
    'ref_address_type_skey',
    'address_line_1',
    'address_line_2',
    'street_name',
    'street_number_1',
    'street_number_2',
    'pre_street_direction_name',
    'street_type',
    'post_street_direction_name',
    'city',
    'state_province',
    'country',
    'county',
    'postal_code',
    'state',
    'postal_code_extension',
    'street_number_3',
    'latitude',
    'longitude',
    'source_address_line_1',
    'source_address_line_2',
    'source_street_name',
    'source_street_number_1',
    'source_street_number_2',
    'source_pre_street_direction_name',
    'source_street_type',
    'source_post_street_direction_name',
    'source_city',
    'source_county',
    'source_state',
    'source_postal_code',
    'source_postal_code_extension',
    'source_country_name',
    'source_street_number_3',
    'source_geocode_output',
    'source_latitude',
    'source_longitude',
    'source_latitude_override',
    'source_longitude_override',
    'source_geocode_override_source',
    'address_match_score',
    'address_match_code',
    'geocode_output',
    'address_precision_code',
    'geocode_provider_name',
    'geometry',
    'source_street_name_pre_type',
    'street_name_pre_type'
]) }}
{%- endmacro %}
