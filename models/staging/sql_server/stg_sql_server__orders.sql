{{ config(materialized='view') }}

with base_orders as (

    select * from {{ ref('base_sql_server__orders') }}

),


renamed as (

    select

        order_id,
        {{ dbt_utils.generate_surrogate_key(['shipping_service', 'shipping_cost']) }} as shipping_id,
        address_id,
        convert_timezone('UTC', created_at) as created_at,
        NULLIF(trim(promo_id), '') as promo_id,
        order_cost,
        user_id,
        order_total,
        valid_data,
        date_load_UTC

    from base_orders as a 

)
select * from renamed