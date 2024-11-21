{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'order_items') }}

),

renamed as (

SELECT
    CAST(order_id AS VARCHAR(255)) AS order_id,                              -- id de la orden como texto limitado
    CAST(product_id AS VARCHAR(255)) AS product_id,                          -- id del producto como texto limitado
    CAST(quantity AS INT) AS quantity,                                      -- cantidad como entero
    CAST(_fivetran_deleted AS BOOLEAN) AS valid_data,                       -- indicador lógico (null/valor)
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc -- fecha de carga en utc
FROM
    source


)

select * from renamed
