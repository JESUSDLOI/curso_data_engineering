
{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'users') }}

),

renamed as (

    select
        trim(user_id) as user_id,
        convert_timezone('UTC', updated_at) as updated_at,
        trim(address_id) as address_id,
        trim(last_name) as last_name,
        convert_timezone('UTC', created_at) as created_at,
        trim(phone_number) as phone_number,
        total_orders,
        trim(first_name) as first_name,
        email,
        _fivetran_deleted as valid_data,
        convert_timezone('UTC',_fivetran_synced) as date_load_UTC

    from source

)

select * from renamed
