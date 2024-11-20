{{ config(materialized='view') }}

with source as (

    select * from {{ ref('base_sql_server__promos') }}

),

renamed as (

    select

        {{ dbt_utils.generate_surrogate_key(['status']) }} as status_id,
        status,
        valid_data,
        date_load_UTC

    from source

    

)

select * from renamed