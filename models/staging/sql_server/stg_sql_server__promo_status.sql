{{ config(materialized='view') }}

with source as (

    select * from {{ ref('base_sql_server__promos') }}

),

renamed as (

    select

        distinct(promo_status_id) as promo_status_id,
        promo_status,
        valid_data,
        date_load_UTC

    from source

    

)

select * from renamed