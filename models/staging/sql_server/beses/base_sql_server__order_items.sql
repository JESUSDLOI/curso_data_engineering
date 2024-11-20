{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'order_items') }}

),

renamed as (

    select
        order_id,
        product_id,
        quantity,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC',_fivetran_synced) as date_load_UTC

    from source

)

select * from renamed
