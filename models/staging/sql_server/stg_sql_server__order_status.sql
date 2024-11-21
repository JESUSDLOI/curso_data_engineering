{{ config(materialized='view') }}

with base_orders as (

    select * from {{ ref('base_sql_server__orders') }}

),


renamed as (

    select

        id_order_status,
        order_status,
        valid_data,
        date_load_UTC

    from base_orders as a 

)
select * from renamed