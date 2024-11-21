{{
  config(
    materialized='view'
  )
}}

WITH src_budget AS (
    SELECT * 
    FROM {{ source('google_sheets', 'budget') }}
    ),

renamed_casted AS (
SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id', 'quantity', convert_timezone('UTC', month)]) }} AS budget_id, -- clave surrogate para presupuesto
    CAST(product_id AS VARCHAR(255)) AS product_id,                                                             -- id del producto como texto limitado
    CAST(quantity AS INT) AS quantity,                                                                          -- cantidad producto como entero
    CAST(CONVERT_TIMEZONE('UTC', month) AS DATE) AS month,                                                      -- mes en formato fecha, con conversión a UTC
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc                               -- fecha de carga en UTC
FROM
    src_budget;

    )

SELECT * FROM renamed_casted