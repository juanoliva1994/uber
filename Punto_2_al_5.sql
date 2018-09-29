------------------------------estos comando se ejecutaron el usuario SYSTEM ------------------------------------------------ 

--------------------------------      PUNTO 2        -----------------------------------------------------------------

-- Ceacion de Data File "Uber" con 2gb
create tablespace uber 
    datafile 'dtfUber' size 2G;
    
-- Creacion del Tablespace de tipo Undo
create undo tablespace Unuber 
    datafile 'dtfUnuber' size 25M;
            
-- Creacion del BigFile
create bigfile tablespace Bguber
    datafile 'dtfBgUber' size 5G;

-- Establecer el undo en el system
alter system set UNDO_TABLESPACE = Unuber;

-------------------------------------------FIN PUNTO 2-------------------------------------------------------------------------

--------------------------------------- PUNTO 3 ----------------------------------------------------------------------------

---- Creacion del usuario DBA
CREATE user OlivaDBA 
    IDENTIFIED by dba123 
        default tablespace uber
            quota unlimited on uber;
            
GRANT DBA TO OlivaDBA;
GRANT CONNECT TO OlivaDBA;

------------------------------------------FIN PUNTO 3---------------------------------------------------------------------------
--------------------------------------- PUNTO 4 -----------------------------------------------------------------------------

-- Creación de perfiles
create profile clerk limit
    PASSWORD_LIFE_TIME 40
    SESSIONS_PER_USER 1
    IDLE_TIME 10
    FAILED_LOGIN_ATTEMPTS 4;

create profile development limit
    PASSWORD_LIFE_TIME 100
    SESSIONS_PER_USER 2
    IDLE_TIME 30
    FAILED_LOGIN_ATTEMPTS UNLIMITED;
-------------------------------------------- FIN PUNTO 4 --------------------------------------------------------------------

--------------------------------------------- PUNTO 5 -----------------------------------------------------------------------    
-- Creación de los usuarios
CREATE user Teacher 
    IDENTIFIED by teacher123 
        default tablespace uber
            quota unlimited on uber;
            
GRANT CONNECT to Teacher;
ALTER USER Teacher PROFILE development;

CREATE user Juanoliva 
    IDENTIFIED by oliva123 
        default tablespace uber
            quota unlimited on uber;
            
GRANT CONNECT to Juanoliva;
ALTER USER Juanoliva PROFILE development;

CREATE user BrandonK 
    IDENTIFIED by brandon123 
        default tablespace uber
            quota unlimited on uber;
            
GRANT CONNECT to BrandonK;
ALTER USER BrandonK PROFILE clerk;


CREATE user FelipeU 
    IDENTIFIED by pipe123 
        default tablespace uber
            quota unlimited on uber;
            
GRANT CONNECT to FelipeU;
ALTER USER FelipeU PROFILE clerk;
ALTER USER FelipeU account lock;

----------------------------------------------- FIN PUNTO 5 ------------------------------------------------------------------
 