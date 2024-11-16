

{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select
        NULLIF(trim(order_id), '') as order_id,
        NULLIF(trim(shipping_service), '') as shipping_service,
        shipping_cost,
        address_id,
        convert_timezone('UTC', created_at) as created_at,
        NULLIF(trim(promo_id), '') as promo_id,
        convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at,
        order_cost,
        user_id,
        order_total,
        convert_timezone('UTC', delivered_at) as delivered_at,
        NULLIF(trim(tracking_id), '') as tracking_id,
        status,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC',_fivetran_synced) as date_load_UTC
    from source

)

select * from renamed