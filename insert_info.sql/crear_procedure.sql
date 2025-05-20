CREATE OR REPLACE PROCEDURE INTEGRACION_GIT( 
    env VARCHAR,
    refresh VARCHAR DEFAULT NULL,
    stream VARCHAR DEFAULT NULL,
    retry VARCHAR DEFAULT NULL
    )
RETURNS TABLE (
    "Filas insertadas" NUMBER,
    "Filas actualizadas" NUMBER,
    "Filas eliminadas" NUMBER
)
LANGUAGE SQL
EXECUTE AS CALLER
AS
DECLARE
    -- Variables
    timestamp_delta STRING;
    update_clause STRING;
    insert_clause STRING;
    values_clause STRING;
    merge_sql STRING;
    merge_query_id STRING;
    result RESULTSET;

    -- Excepciones
    entorno_invalido EXCEPTION (-20001, 'El parámetro de entorno introducido es inválido. Debe ser ''JESUS''.');
    full_refresh_invalido EXCEPTION (-20002, 'El parámetro de full-refresh introducido es inválido. Debe ser ''FULL-REFRESH''.');
    error_merge EXCEPTION (-20003, 'Error al hacer MERGE en el full-refresh. No se está detectando ningún delta.');
BEGIN

    -- Establece contexto de roles para poder operar en las distintas BBDD
    EXECUTE IMMEDIATE 'USE SECONDARY ROLES ALL';

    -- Setea el timezone a UTC para mantener alineación con el sistema operacional (el conector de ServiceNow ingesta en UTC)
    EXECUTE IMMEDIATE 'ALTER SESSION SET TIMEZONE = ''UTC''';

    -- Valida el parámetro de entorno introducido
    IF (env NOT IN ('JESUS')) THEN
        RAISE entorno_invalido;
    END IF;

        -- Valida el parámetro de full-refresh introducido
    IF (refresh != 'FULL-REFRESH') THEN
        RAISE full_refresh_invalido;
    END IF;

    -- Si se ejecuta en modo full-refresh, el delta tiene que captar la totalidad de filas del modelo padre.
    -- Esto es necesario debido a que el TRUNCATE se ejecuta más abajo (después de captar el delta para el estado actual del modelo).

    -- De no hacer esto, se estaría insertando el delta pre-TRUNCATE a una tabla recién truncada.
    -- Nota: el TRUNCATE se realiza después de captar el delta (y no después), ya que al existir DDL (creación de tablas temporales), Snowflake autocommitea la transacción de borrado.
    IF (refresh = 'FULL-REFRESH') THEN
        timestamp_delta := 'SELECT 0::TIMESTAMP';

    ELSEIF (refresh IS NULL) THEN 		
        timestamp_delta := '
            SELECT IFNULL(MAX(COLUMNA_3), 0::TIMESTAMP) 
            FROM ' || env || '_DE_LA_OLIVA.SECRETOS.PRUEBA
        '
        ;
    END IF;
    
    -- Captura el contenido del stream (delta) en una tabla TRANSIENT, para así mantener el dato en caso de error.
    -- Si el procedimiento finaliza con éxito, automáticamente elimina dicha tabla.
        
        -- Si no se especifica un stream ni se ordena 'retry' -> determina el delta manualmente
        IF (stream IS NULL AND retry IS NULL) THEN
            EXECUTE IMMEDIATE '
                CREATE OR REPLACE TRANSIENT TABLE temp_delta_user_fct_' || env || ' AS
                    SELECT * 
                    FROM ' || env || '_DE_LA_OLIVA.SECRETOS.PRUEBA_PROCEDURE AS a
                    WHERE 
                        a.COLUMNA_3 > (
                        ' || timestamp_delta || '
                        )
            ';

        -- Si se especifica un stream y no se ordena 'retry' ->  consume el stream
        -- Filtra por metadata$action = ''INSERT'' para ignorar: 1) los DELETE asociados a un UPDATE; 2) los DELETE asociados a un TRUNCATE (full refresh) 
        ELSEIF (stream IS NOT NULL AND retry IS NULL) THEN
            EXECUTE IMMEDIATE '
                CREATE OR REPLACE TRANSIENT TABLE temp_delta_user_fct_' || env || ' AS 
                    SELECT * 
                    FROM ' || stream || '
                    WHERE metadata$action = ''INSERT''
            ';

        -- Si se ordena 'retry', y al margen de si se especifica stream o no -> reprocesa la tabla delta preexistente
        ELSEIF (retry = 'retry') THEN
            NULL;

        END IF;

    -- Lógica de transformación de silver a gold
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE TEMPORARY TABLE temp_transformacion_user_fct_' || env || ' AS (
        
            WITH user_fact AS (                      
            SELECT
                *
            FROM temp_delta_user_fct_' || env || ' a
 
        )
        ';

    -- Construye las cláusulas para el MERGE
    -- Para evitar tener que llamar SHOW COLUMNS cada vez que asigna valores a las cláusulas, primero crea una tabla intermedia
    EXECUTE IMMEDIATE 'SHOW COLUMNS IN TABLE temp_transformacion_USER_fct_' || env || '';
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TEMPORARY TABLE temp_columns_USER_fct_' || env || ' AS SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))';

        -- Cláusula para el UPDATE
        EXECUTE IMMEDIATE '
            SELECT LISTAGG(''gold.'' || "column_name" || '' = silver.'' || "column_name", '', '') 
            WITHIN GROUP (ORDER BY "column_name")       -- Las columnas deben aparecer en el mismo orden
            FROM temp_columns_USER_fct_' || env || '
        ';
        SELECT *
        INTO :update_clause
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

        -- Cláusula para el INSERT
        EXECUTE IMMEDIATE '
            SELECT LISTAGG("column_name", '', '') 
            WITHIN GROUP (ORDER BY "column_name")       -- Las columnas deben aparecer en el mismo orden
            FROM temp_columns_USER_fct_' || env || '
        ';
        SELECT *
        INTO :insert_clause
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

        -- Cláusula para el VALUES
        EXECUTE IMMEDIATE '
            SELECT LISTAGG(''silver.'' || "column_name", '', '') 
            WITHIN GROUP (ORDER BY "column_name")       -- Las columnas deben aparecer en el mismo orden 
            FROM temp_columns_USER_fct_' || env || ' 
        ';
        SELECT *
        INTO :values_clause
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

    -- Realiza el MERGE
    merge_sql := '
        MERGE INTO ' || env || '_DE_LA_OLIVA.SECRETOS.PRUEBA AS gold
        USING temp_transformacion_USER_fct_' || env || ' AS silver
        ON silver.COLUMNA_1 = gold.COLUMNA_1
        
        WHEN MATCHED THEN 
            UPDATE SET ' || update_clause || '

        WHEN NOT MATCHED THEN
            INSERT (' || insert_clause || ')
            VALUES (' || values_clause || ')
    ';
    
    -- Si se ejecuta en modo full-refresh, se abre una transacción explícita que trunca la tabla y solo commitea si el MERGE tuvo éxito.
    -- De este modo, se asegura la continuación de operaciones mientras se refresca el modelo.
    IF (refresh = 'FULL-REFRESH') THEN
        BEGIN TRANSACTION;
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || env || '_DE_LA_OLIVA.SECRETOS.PRUEBA';
        EXECUTE IMMEDIATE :merge_sql;
        merge_query_id := (SELECT LAST_QUERY_ID()); 
        LET res NUMBER := (SELECT "number of rows inserted" FROM TABLE(RESULT_SCAN(:merge_query_id)));
        IF (res > 0) THEN
            COMMIT;
        ELSE
            ROLLBACK;
            RAISE error_merge;
        END IF;
    
    ELSEIF (refresh IS NULL) THEN
        EXECUTE IMMEDIATE :merge_sql;
        merge_query_id := (SELECT LAST_QUERY_ID());
    END IF;


    LET delete_query_id STRING := (SELECT LAST_QUERY_ID());
    
    -- Una vez la transformación se realiza con éxito, elimina la tabla TRANSIENT que contiene el delta
    EXECUTE IMMEDIATE 'DROP TABLE temp_delta_USER_fct_' || env || '';

    -- Guarda el total de filas insertadas, actualizadas y eliminadas como output
    result := (
        SELECT 
            a."number of rows inserted" AS "Filas insertadas",
            a."number of rows updated" AS "Filas actualizadas",
            b."number of rows deleted" AS "Filas eliminadas"                
        FROM TABLE(RESULT_SCAN(:merge_query_id)) a
        FULL OUTER JOIN TABLE(RESULT_SCAN(:delete_query_id)) b
        ON 1 = 1
    );
        
    -- Devuelve el resultado
    RETURN TABLE(result);

EXCEPTION
    WHEN OTHER THEN
        RAISE;
END;
