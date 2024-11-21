
with source as (

    select * from {{ ref('base_sql_server__orders')  }}

),

renamed as (

    select
        
        distinct({{ dbt_utils.generate_surrogate_key(['shipping_service', 'shipping_cost']) }}) as shipping_id,
        shipping_cost_USD,
        shipping_service_id,
        valid_data,
        date_load_UTC

    from source

)

select * from renamed