
{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'users') }}

),

renamed as (

SELECT
    CAST(TRIM(user_id) AS VARCHAR(255)) AS user_id,                          -- id del usuario como texto limitado
    CAST(CONVERT_TIMEZONE('UTC', updated_at) AS TIMESTAMP) AS updated_at_utc, -- fecha de actualización en UTC
    CAST(TRIM(address_id) AS VARCHAR(255)) AS address_id,                    -- id de la dirección como texto limitado
    CAST(TRIM(last_name) AS VARCHAR(255)) AS last_name,                     -- apellido como texto limitado
    CAST(CONVERT_TIMEZONE('UTC', created_at) AS TIMESTAMP) AS created_at_utc,   -- fecha de creación en UTC
    CAST(TRIM(phone_number) AS VARCHAR(255)) AS phone_number,                -- número de teléfono como texto limitado
    CAST(TRIM(first_name) AS VARCHAR(255)) AS first_name,                   -- primer nombre como texto limitado
    CAST(email AS VARCHAR(255)) AS email,                                   -- correo electrónico como texto largo
    CAST(_fivetran_deleted AS BOOLEAN) AS valid_data,                       -- indicador lógico (null/valor)
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc -- fecha de carga en UTC
FROM
    source


)

select * from renamed
