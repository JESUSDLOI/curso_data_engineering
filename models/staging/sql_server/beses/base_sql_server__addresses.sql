{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'addresses') }}

),

renamed as (

    select
        trim(address_id) as address_id,
        zipcode,
        trim(country) as country,
        address,
        trim(state) as state,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC', _fivetran_synced) as date_load_UTC

    from source

)

select * from renamed
