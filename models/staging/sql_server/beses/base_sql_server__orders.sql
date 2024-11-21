

{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

    select
        order_id as order_id,
        replace(trim(shipping_service), '', 'service selection') as shipping_service,
        shipping_cost as shipping_cost_usd,
        address_id,
        convert_timezone('UTC', created_at) as created_at_UTC,
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id,
        convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at_UTC,
        order_cost as order_cost_usd,
        user_id,
        order_total as order_total_usd,
        convert_timezone('UTC', delivered_at) as delivered_at_UTC,
        NULLIF(trim(tracking_id), '') as tracking_id,
        status,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC',_fivetran_synced) as date_load_UTC
    from source

)

select * from renamed