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
