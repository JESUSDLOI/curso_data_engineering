{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'products') }}

),

renamed as (

    select
        product_id,
        price_USD,
        name,
        inventory,
        valid_data,
        date_load_UTC

    from source

)

select * from renamed
