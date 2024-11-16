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
        _fivetran_deleted as valid_data,
        convert_timezone('UTC', _fivetran_synced) as date_load_UTC

    from source

)

select * from renamed