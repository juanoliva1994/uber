-- 1) Creacion de vista para obtener los medios de pago de los clientes 
CREATE OR REPLACE VIEW MEDIOS_PAGO_CLIENTES AS
SELECT Clientes.ID as CLIENTE_ID,
       Clientes.Nombre as NOMBRE_CLIENTE,
       Medios_de_pago.ID as MEDIO_PAGO_ID,
       Medios_de_pago.Nombre as TIPO,
       Medios_de_pago.Detalle as DETALLES_MEDIO_PAGO,
       CASE 
        WHEN (Medios_de_pago.ID_Compania IS NULL) 
          THEN 'FALSE' 
        ELSE 'TRUE'
      END AS EMPRESARIAL,
       CASE 
        WHEN (Medios_de_pago.ID_Compania IS NULL) 
          THEN NULL 
        ELSE Companias.nombre
      END AS NOMBRE_EMPRESA
    FROM Clientes 
    INNER JOIN MEDIOS_DE_PAGO ON CLIENTES.ID = MEDIOS_DE_PAGO.ID_CLIENTE 
    INNER JOIN COMPANIAS ON COMPANIAS.ID = CLIENTES.ID_COMPANIA;
    
-- 2) Creacion de vista para obtener todos los viajes de los clientes ordenados cronologicamente
CREATE OR REPLACE VIEW VIAJES_CLIENTES AS
  SELECT 
        VIAJES.HORA_SALIDA AS FECHA_VIAJE, 
        CONDUCTORES.NOMBRE AS NOMBRE_CONDUCTOR, 
        VEHICULOS.PLACA    AS PLACA_VEHICULO,
        CLIENTES.NOMBRE    AS NOMBRE_CLIENTE,
        VIAJES.TOTAL       AS VALOR_TOTAL,
        CASE
          WHEN VIAJES.TARIFA_DINAMICA = 1
            THEN 'TRUE'
          ELSE 'FALSE'
        END                AS TARIFA_DINAMICA,
        SERVICIOS.NOMBRE   AS TIPO_SERVICIO
  FROM VIAJES
  INNER JOIN CONDUCTORES  ON CONDUCTORES.ID         = VIAJES.ID_CONDUCTOR
  INNER JOIN SERVICIOS    ON SERVICIOS.ID           = VIAJES.ID_SERVICIO
  INNER JOIN VEHICULOS    ON VEHICULOS.ID_SERVICIO  = VIAJES.ID_SERVICIO
  INNER JOIN CLIENTES     ON CLIENTES.ID            = VIAJES.ID_CLIENTE
  ORDER BY VIAJES.HORA_SALIDA DESC;
  
