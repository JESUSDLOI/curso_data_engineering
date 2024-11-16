{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'products') }}

),

renamed as (

    select
        trim(product_id) as product_id,
        price,
        trim(name) as name,
        inventory,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC', _fivetran_synced) as date_load_UTC

    from source

)

select * from renamed
