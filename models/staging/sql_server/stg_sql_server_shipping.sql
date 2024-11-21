
with source as (

    select * from {{ ref('base_sql_server__orders')  }}

),

renamed as (

    select
        
        distinct({{ dbt_utils.generate_surrogate_key(['shipping_service', 'shipping_cost_usd']) }}) as shipping_id,
        shipping_cost_usd,
        shipping_service,
        valid_data,
        date_load_UTC

    from source

)

select * from renamed