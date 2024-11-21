{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'events') }}

),

renamed as (

SELECT
    CAST(event_id AS VARCHAR(255)) AS event_id,                              -- identificador único del evento
    {{ dbt_utils.generate_surrogate_key(['page_url']) }} AS page_url_id,     -- clave subrrogada para page_url
    CAST(page_url AS VARCHAR(2048)) AS page_url,                             -- url con longitud máxima estándar
    {{ dbt_utils.generate_surrogate_key(['event_type']) }} AS event_type_id, -- clave subrrogada para tipo de evento
    CAST(event_type AS  VARCHAR(255)) AS event_type,                         -- tipo de evento como texto limitado
    CAST(user_id AS VARCHAR(255)) AS user_id,                                -- id del usuario como entero largo
    NULLIF(TRIM(CAST(product_id AS  VARCHAR(255))), '') AS product_id,       -- id de producto sin espacios
    CAST(session_id AS VARCHAR(255)) AS session_id,                         -- id de sesión como texto limitado
    CAST(CONVERT_TIMEZONE('UTC', created_at) AS TIMESTAMP) AS created_at_utc, -- fecha de creación en utc
    NULLIF(TRIM(CAST(order_id AS VARCHAR(255))), '') AS order_id,                -- id de orden 
    CAST(_fivetran_deleted AS BOOLEAN) AS valid_data,                          -- indicador lógico (null/valor)
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc -- fecha de carga en utc
FROM
    source


)

select * from renamed
