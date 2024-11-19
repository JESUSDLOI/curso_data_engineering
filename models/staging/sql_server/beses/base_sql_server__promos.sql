{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'promos') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id,
        promo_id as promo_name,
        discount,
        status,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC', _fivetran_synced) as date_load_UTC

    from source

    union all

    SELECT {{ dbt_utils.generate_surrogate_key(["''"]) }},
    'no promo',
    '0',
    'active',
    null,
    '2024-10-25T16:00:37.597Z' 

    

)

select * from renamed