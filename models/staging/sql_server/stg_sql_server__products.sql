{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'products') }}

),

renamed as (

SELECT
    -- Casteo del identificador del producto como VARCHAR(255)
    CAST(product_id AS VARCHAR(255)) AS product_id, 
    
    -- Casteo del precio a un tipo numérico adecuado (FLOAT) para la columna price_usd
    CAST(price AS FLOAT) AS price_usd, 
    
    -- Casteo del nombre del producto como VARCHAR(255)
    CAST(name AS VARCHAR(255)) AS name, 
    
    -- Casteo del inventario como INTEGER
    CAST(inventory AS INTEGER) AS inventory, 
    
    -- Casteo del campo de validación a BOOLEAN para asegurar que sea verdadero o falso
    CAST(_FIVETRAN_DELETED AS BOOLEAN) AS valid_data, 
    
    -- Casteo de la fecha de carga a TIMESTAMP_TZ para asegurar que el formato de fecha y hora sea consistente con zonas horarias
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP_TZ) AS date_load_utc 
    
FROM 
    source

)

select * from renamed
