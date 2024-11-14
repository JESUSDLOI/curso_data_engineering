{{
  config(
    materialized='view'
  )
}}

WITH src_addresses AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'addresses') }}
    ),

renamed_casted AS (
    SELECT
          ADDRESS
        , ADDRESS_ID
        , COUNTRY
        , STATE
        , ZIPCODE
        , _FIVETRAN_DELETED AS track_history
        , _fivetran_synced AS date_load
    FROM src_addresses
    )

SELECT * FROM renamed_casted