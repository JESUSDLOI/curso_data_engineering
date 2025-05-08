use database JESUS_DE_LA_OLIVA;
use schema secretos;

create table prueba
(
    columna_1 varchar
    columna_2 number
    columna_3 timestamp_ntz

);

EXECUTE IMMEDIATE from './rellenar_tabla.sql';


SELECT * from prueba;