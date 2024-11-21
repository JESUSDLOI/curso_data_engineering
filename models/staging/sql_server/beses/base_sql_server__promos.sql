{{ config(materialized='view') }}

with source as (

    select * from {{ source('sql_server_dbo', 'promos') }}

),

renamed as (

SELECT
    {{ dbt_utils.generate_surrogate_key(['promo_id']) }} AS promo_id, -- llave surrogate única para promo_id
    CAST(promo_id AS VARCHAR(255)) AS promo_name,                       -- nombre de la promoción como texto limitado
    CAST(discount AS NUMERIC(10, 2)) AS discount_usd,               -- descuento en formato decimal
    {{ dbt_utils.generate_surrogate_key(['status']) }} AS promo_status_id, -- llave surrogate única para el estado de la promoción
    CAST(status AS VARCHAR(255)) AS promo_status,                        -- estado de la promoción 
    CAST(_fivetran_deleted AS BOOLEAN) AS valid_data,                   -- indicador lógico (null/valor)
    CAST(CONVERT_TIMEZONE('UTC', _fivetran_synced) AS TIMESTAMP) AS date_load_utc -- fecha de carga en UTC
FROM
    source

    union all

    SELECT {{ dbt_utils.generate_surrogate_key(["''"]) }},
    'no promo',
    '0',
    {{ dbt_utils.generate_surrogate_key(["'active'"]) }},
    'active',
    null,
    '2024-10-25T16:00:37.597Z' 

    

)

select * from renamed