{{ config(materialized='view') }}

with source as (

    select * from {{ ref('base_sql_server__promos') }}

),

renamed as (

    select
        promo_id,
        promo_name,
        discount_USD,
        promo_status_id,
        valid_data,
        date_load_UTC

    from source
)

select * from renamed