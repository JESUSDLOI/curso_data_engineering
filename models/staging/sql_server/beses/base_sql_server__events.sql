{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'events') }}

),

renamed as (

    select
        event_id,
        page_url,
        event_type,
        user_id,
        NULLIF(trim(product_id), '') as product_id,
        session_id,
        convert_timezone('UTC', created_at) as created_at,
        NULLIF(trim(order_id), '') as order_id,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC', _fivetran_synced) as date_load_UTC

    from source

)

select * from renamed
