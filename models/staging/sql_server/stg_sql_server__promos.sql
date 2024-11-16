{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'promos') }}

),

renamed as (

    select
        md5(trim(promo_id)) as promo_id,
        promo_id as promo_name,
        discount,
        status,
        _fivetran_deleted,
        _fivetran_synced at date_load

    from source

)

select * from renamed