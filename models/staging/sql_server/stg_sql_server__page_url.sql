{{ config(materialized='view') }}

with source as (

    select * from {{ ref('base_sql_server__events') }}

),

renamed as (

    select
        
        distinct(page_url_id),
        page_url,
        valid_data,
        date_load_UTC

    from source

)

select * from renamed