{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'addresses') }}

),

renamed as (

SELECT
    CAST(TRIM(address_id) AS VARCHAR(255)) AS address_id, -- ID de dirección (hasta 255 caracteres)
    CAST(TRIM(zipcode) AS VARCHAR(255)) AS zipcode,         -- Código postal (hasta 255 caracteres)
    CAST(TRIM(country) AS VARCHAR(255)) AS country,     -- País como texto (hasta 255 caracteres)
    CAST(TRIM(address) AS VARCHAR(255)) AS address,     -- Dirección completa como texto (hasta 255 caracteres)
    CAST(TRIM(state) AS VARCHAR(255)) AS state,          -- Estado o región como texto (hasta 255 caracteres)
    CAST(_fivetran_deleted AS BOOLEAN) AS valid_data,   -- Indicador lógico (null/valor)
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc -- Fecha y hora en UTC
FROM
    source


)

select * from renamed
