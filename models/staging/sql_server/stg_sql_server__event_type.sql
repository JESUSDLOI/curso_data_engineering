{{ config(materialized='view') }}

with source as (

    select * from {{ ref('base_sql_server__events') }}

),

renamed as (

SELECT
        distinct(event_type_id), --id del tipo de evento
        event_type,    -- nombre del tipo de evento
        valid_data,    -- validación de datos
        date_load_utc  -- fecha de carga en utc
FROM
    source


)

select * from renamed
