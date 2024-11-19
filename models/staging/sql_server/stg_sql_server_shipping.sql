
with source as (

    select * from {{ ref('base_sql_server__orders')  }}

),

renamed as (

    select
        order_id as order_id,
        trim(shipping_service) as shipping_service,
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
        _fivetran_deleted as valid_data,
        convert_timezone('UTC',_fivetran_synced) as date_load_UTC
    from source

)

select * from renamed