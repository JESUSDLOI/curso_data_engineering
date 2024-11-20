
with source as (

    select * from {{ ref('base_sql_server__orders')  }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} as shipping_service_id,
        shipping_service
        
    from source

)

select * from renamed