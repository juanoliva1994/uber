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
  
  
--5) Crear la funcion llamada VALOR_DISTANCIA.

CREATE OR REPLACE FUNCTION VALOR_DISTANCIA(Distancia float,Ciudad string)
    RETURN FLOAT
    AS
    Valorkm float;
    Total_por_km float;
    BEGIN
    --Se valida que la distancia no sea menor a 0
        IF DISTANCIA < 0
          THEN 
            DBMS_OUTPUT.put_line('ERROR: DISTANCIA MENOR A 0');
            RETURN NULL;
        END IF;
        --Se obtiene el valor por kilometro
        Select Valor_por_km into Valorkm  from Ciudades
            where Nombre = Ciudad;
        --Se calcula el total    
        Total_por_km := Valorkm * Distancia;  
        return Total_por_km;
        --Se valida si el qry no encuentra datos se controla el error con el exeption
        EXCEPTION
          WHEN NO_DATA_FOUND
            THEN DBMS_OUTPUT.put_line('ERROR: NO SE ENCUENTRA CIUDAD');
      
    END;
  
-- 6) Funcion que permite recibir como par�metros de entrada una ciudad y una cantidad de minutos.
-- con �stos 2 datos se calcula un valor que equivale a el valor que cuesta un minuto en la ciudad recibida por
-- la cantidad de minutos que se recibe.
CREATE OR REPLACE FUNCTION VALOR_TIEMPO(MINUTOS float,Ciudad string)
    RETURN FLOAT
    AS
    ValorMIN float;
    Total_por_MIN float;
    BEGIN
    --Se valida que los minutos no sean menor a 0
        IF MINUTOS < 0
          THEN 
            DBMS_OUTPUT.put_line('ERROR: MINUTOS MENOR A 0');
            RETURN NULL;
        END IF;
        --Se consulta el valor por minuto
        Select Valor_por_minuto into ValorMIN  from Ciudades
            where Nombre = Ciudad;
        --Se calcula el total    
        Total_por_MIN := ValorMIN * MINUTOS;  
        return Total_por_MIN;
        --Se controla la exepciones si no encuentra data el qry
        EXCEPTION
          WHEN NO_DATA_FOUND
            THEN DBMS_OUTPUT.put_line('ERROR: NO SE ENCUENTRA CIUDAD');
      
END;


-- 7) Procedimiento que me permite caluclar una tarifa.
-- �sto se realiza con base a el viaje, tomando como base el viaje se busca el tiempo recorrido, la distancia recorrida
-- y la suma de los detalles adicionales del viaje, como peajes, reten etc y se actualiza el total del viaje
CREATE OR REPLACE PROCEDURE CALCULAR_TARIFA (VIAJE IN INTEGER)
IS
ESTADO_VIAJE INTEGER;
VALOR_TARIFA_BASE FLOAT;
VALOR_DIS FLOAT;
VALOR_TIM FLOAT;
TIEMPORECORRIDO FLOAT;
DISTANCI FLOAT;
CIUDAD VARCHAR(64);
VALOR_DETALLE FLOAT;
TARIFA FLOAT;
BEGIN

--SI EL ESTADO ES DIFERENTE DE REALIZADO ENTONCES ACTUALIZAMOS EL VALOR DEL VIAJE
  SELECT ESTADO INTO ESTADO_VIAJE
  FROM VIAJES
  WHERE ID = VIAJE;
  
  IF ESTADO_VIAJE <> 1
    THEN UPDATE VIAJES SET TOTAL = 0 WHERE ID = VIAJE;
  END IF;
  
  
--BUSCAR VALOR DE LA TARIFA BASE, CIUDAD, DISTANCIA, TIEMPO RECORRIDO
  SELECT CIUDADES.TARIFA_BASE, CIUDADES.NOMBRE, VIAJES.DISTANCIA, VIAJES.TIEMPO_RECORRIDO INTO VALOR_TARIFA_BASE, CIUDAD, DISTANCI, TIEMPORECORRIDO
  FROM VIAJES
  INNER JOIN CIUDADES ON CIUDADES.ID = VIAJES.ID_CIUDAD
  WHERE VIAJES.ID = VIAJE;
  
--SE INVOCAN FUNCION PARA OBTENER VALOR POR LA DISTANCIA RECORRIDA
 VALOR_DIS := VALOR_DISTANCIA(DISTANCI, CIUDAD);
 
 --SE INVOCAN FUNCION PARA OBTENER VALOR POR LA TIEMPO RECORRIDA
VALOR_TIM := VALOR_TIEMPO(TIEMPORECORRIDO, CIUDAD);
 
--SE SUMA EL DETALLE DEL VIAJE
 SELECT SUM(TOTAL) INTO VALOR_DETALLE
 FROM DETALLES_VIAJE
 WHERE ID_VIAJE = VIAJE;
 
 IF VALOR_DIS IS NULL OR VALOR_TIM IS NULL THEN
    UPDATE VIAJES SET TOTAL = 0 WHERE ID = VIAJE;
 ELSE
--SE REALIZA LA SUMA DE TODOS LOS VALORES
  TARIFA := VALOR_TARIFA_BASE + VALOR_DIS + VALOR_TIM + VALOR_DETALLE;
  UPDATE VIAJES SET TOTAL = TARIFA, SUBTOTAL = VALOR_DETALLE WHERE ID = VIAJE;
 END IF;

END;

DECLARE
  VALOR FLOAT;
BEGIN
  VALOR := VALOR_TIEMPO(21.84, 'Montpellier');
  --VALOR := VALOR_DISTANCIA(-5, 'MEDELLIN');
  DBMS_OUTPUT.PUT_LINE(VALOR);
  
 VALOR := VALOR_DISTANCIA(55, 'Montpellier');
  --VALOR := VALOR_DISTANCIA(-5, 'MEDELLIN');
DBMS_OUTPUT.PUT_LINE(VALOR);
END;