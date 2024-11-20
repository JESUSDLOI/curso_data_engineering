
with source as (

    select * from {{ ref('base_sql_server__orders')  }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} as shipping_service_id,
        {{ dbt_utils.generate_surrogate_key(['shipping_service', 'shipping_cost']) }} as shipping_id,
        shipping_cost,
        estimated_delivery_at,
        delivered_at,
        tracking_id,
        status
    from source

)

select * from renamed