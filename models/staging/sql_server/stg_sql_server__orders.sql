{{ config(materialized='view') }}

with base_orders as (

    select * from {{ ref('base_sql_server__orders') }}

),


renamed as (

    select

        order_id,
        {{ dbt_utils.generate_surrogate_key(['shipping_service', 'shipping_cost_usd']) }} as shipping_id,
        address_id,
        created_at_UTC,
        promo_id,
        order_cost_usd,
        user_id,
        order_total,
        id_order_status,
        valid_data,
        date_load_UTC

    from base_orders as a 

)
select * from renamed