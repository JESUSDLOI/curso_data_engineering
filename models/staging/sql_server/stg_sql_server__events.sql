{{ config(materialized='view') }}

with source as (

    select * from {{ ref('base_sql_server__events') }}

),

renamed as (

    select
        event_id
        page_url_id,
        event_type_id,
        user_id,
        product_id,
        session_id,
        created_at_utc,
        valid_data,
        date_load_UTC

    from source

)

select * from renamed