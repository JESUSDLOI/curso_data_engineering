

{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'orders') }}

),

renamed as (

SELECT
    CAST(order_id AS VARCHAR(255)) AS order_id,                                                  -- id de la orden como texto limitado
    REPLACE(TRIM(shipping_service), '', 'selecting service') AS shipping_service,               -- servicio de envío ajustado
    CAST(shipping_cost_USD AS NUMERIC(10, 2)) AS shipping_cost_usd,                             -- costo de envío en formato decimal
    CAST(address_id AS VARCHAR(255)) AS address_id,                                              -- id de la dirección como texto
    CAST(CONVERT_TIMEZONE('UTC', created_at) AS TIMESTAMP) AS created_at_utc,                       -- fecha de creación en UTC
    {{ dbt_utils.generate_surrogate_key(['promo_id']) }} AS promo_id                           -- llave surrogate para promo_id  
    CAST(CONVERT_TIMEZONE('UTC', estimated_delivery_at) AS TIMESTAMP) AS estimated_delivery_at_utc, -- entrega estimada en UTC
    CAST(order_cost_USD AS NUMERIC(10, 2)) AS order_cost_usd,                                   -- costo de la orden en formato decimal
    CAST(user_id AS VARCHAR(255)) AS user_id,                                                         -- id del usuario como entero largo
    CAST(order_total_USD AS NUMERIC(10, 2)) AS order_total_usd,                                 -- total de la orden en formato decimal
    CAST(CONVERT_TIMEZONE('UTC', delivered_at) AS TIMESTAMP) AS delivered_at_utc,                   -- fecha de entrega en UTC
    NULLIF(TRIM(CAST(tracking_id AS VARCHAR(255))), '') AS tracking_id,                         -- id de seguimiento sin espacios ni valores vacíos
    CAST({{ dbt_utils.generate_surrogate_key(['status']) }} AS VARCHAR(255)) AS id_order_status,  -- id del estado de la orden como texto limitado
    CAST(status AS VARCHAR(255)) AS order_status,                                                     -- estado de la orden como texto limitado
    CAST(_fivetran_deleted AS BOOLEAN) AS valid_data,                                           -- indicador lógico (null/valor)
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc               -- fecha de carga en UTC
FROM
    source;


)

select * from renamed