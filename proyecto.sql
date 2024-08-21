--Proyecto Final - Base de Datos
--Grupo 9
/****************************************************************************************************************************************************************
***                                                                        TABLESPACE                                                                         ***
****************************************************************************************************************************************************************/
--Creacion de Tablespace
CREATE TABLESPACE ReservasTS
DATAFILE 'reservas_ts.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 50M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE PedidosTS
DATAFILE 'pedidos_ts.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 50M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;


/****************************************************************************************************************************************************************
***                                                                    USUARIOS Y ROLES                                                                       ***
****************************************************************************************************************************************************************/
-- Creacion de Usuarios y Roles
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

CREATE USER reservadb_user IDENTIFIED BY 12345
DEFAULT TABLESPACE ReservasTS
QUOTA UNLIMITED ON ReservasTS;

CREATE ROLE reservas_role;

GRANT CONNECT, RESOURCE TO reservas_role;

GRANT reservas_role TO reservadb_user;


/****************************************************************************************************************************************************************
***                                                                          TABLAS                                                                           ***
****************************************************************************************************************************************************************/

-- Creacion de la tabla: Cliente
CREATE TABLE CLIENTE (
    CLIENTEID       NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    NOMBRE          VARCHAR2(100) NOT NULL,
    APELLIDO        VARCHAR2(100) NOT NULL,
    EMAIL           VARCHAR2(100) NOT NULL UNIQUE,
    TELEFONO        VARCHAR2(20) NOT NULL,
    FECHAREGISTRO   DATE NOT NULL,
    ACTIVO          NUMBER(1) DEFAULT 1 NOT NULL
)
TABLESPACE ReservasTS;


-- Creacion de la tabla: Empleado
CREATE TABLE EMPLEADO (
    EMPLEADOID          NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    NOMBRE              VARCHAR2(100) NOT NULL,
    APELLIDO            VARCHAR2(100) NOT NULL,
    CARGO               VARCHAR2(100),
    FECHACONTRATACION   DATE NOT NULL,
    ACTIVO              NUMBER(1) DEFAULT 1 NOT NULL
)
TABLESPACE ReservasTS;


-- Creacion de la tabla: Restaurante
CREATE TABLE RESTAURANTE (
    RESTAURANTEID   NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    EMPLEADOID      NUMBER NOT NULL,
    NOMBRE          VARCHAR2(100) NOT NULL,
    DIRECCION       VARCHAR2(255),
    TELEFONO        VARCHAR2(20),
    EMAIL           VARCHAR2(100) UNIQUE,
    ACTIVO          NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT FK_Restaurante_Empleado FOREIGN KEY (EMPLEADOID) REFERENCES EMPLEADO(EMPLEADOID)
)
TABLESPACE ReservasTS;


-- Creacion de la tabla: Mesa
CREATE TABLE MESA (
    MESAID          NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    RESTAURANTEID   NUMBER,
    NUMEROMESA      NUMBER NOT NULL,
    CAPACIDAD       NUMBER NOT NULL,
    UBICACION       VARCHAR2(100),
    ACTIVO          NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT FK_Mesa_Restaurante FOREIGN KEY (RESTAURANTEID) REFERENCES RESTAURANTE(RESTAURANTEID)
)
TABLESPACE ReservasTS;


-- Creacion de la tabla: Reserva
CREATE TABLE RESERVA (
    RESERVAID       NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    CLIENTEID       NUMBER NOT NULL,
    MESAID          NUMBER NOT NULL,
    NUMEROPERSONAS  NUMBER NOT NULL,
    FECHARESERVA    DATE NOT NULL,
    ESTADO          VARCHAR2(50) DEFAULT 'Pendiente' NOT NULL,
    ACTIVO          NUMBER(1) DEFAULT 1 NOT NULL,
    CONSTRAINT FK_Reserva_Cliente FOREIGN KEY (CLIENTEID) REFERENCES CLIENTE(CLIENTEID),
    CONSTRAINT FK_Reserva_Mesa FOREIGN KEY (MESAID) REFERENCES MESA(MESAID)
)
TABLESPACE ReservasTS;


-- Creacion de la tabla: Menu
CREATE TABLE MENU (
    MENUID          NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    NOMBRE          VARCHAR2(100) NOT NULL,
    DESCRIPCION     VARCHAR2(255),
    PRECIO          NUMBER(10, 2) NOT NULL,
    DISPONIBLE      NUMBER(1) DEFAULT 1
)
TABLESPACE PedidosTS;


-- Creacion de la tabla: Pedido
CREATE TABLE PEDIDO (
    PEDIDOID        NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    RESERVAID       NUMBER NOT NULL,
    FECHAPEDIDO     DATE NOT NULL,
    TOTAL           NUMBER(10, 2) NOT NULL,
    CONSTRAINT FK_Pedido_Reserva FOREIGN KEY (RESERVAID) REFERENCES RESERVA(RESERVAID)
)
TABLESPACE PedidosTS;


-- Creacion de la tabla: DetallePedido
CREATE TABLE DETALLEPEDIDO (
    DETALLEPEDIDOID     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY NOT NULL,
    PEDIDOID            NUMBER NOT NULL,
    MENUID              NUMBER NOT NULL,
    CANTIDAD            NUMBER NOT NULL,
    PRECIO              NUMBER(10, 2) NOT NULL,
    CONSTRAINT FK_DetallePedido_Pedido FOREIGN KEY (PEDIDOID) REFERENCES PEDIDO(PEDIDOID),
    CONSTRAINT FK_DetallePedido_Menu FOREIGN KEY (MENUID) REFERENCES MENU(MENUID)
)
TABLESPACE PedidosTS;


-- Drop tablas y tablespaces para hacer modificaciones
/*
DROP TABLE DETALLEPEDIDO;
DROP TABLE EMPLEADO;
DROP TABLE RESTAURANTE;
DROP TABLE CLIENTE;
DROP TABLE MESA;
DROP TABLE RESERVA;
DROP TABLE MENU;
DROP TABLE PEDIDO;
DROP TABLESPACE PedidosTS INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE ReservasTS INCLUDING CONTENTS AND DATAFILES;
DROP USER RESERVADB_USER;
DROP ROLE RESERVAS_ROLE;
*/

/****************************************************************************************************************************************************************
***                                                                          INDICES                                                                          ***
****************************************************************************************************************************************************************/

-- Indice en Pedidos basado en ReservaID
CREATE INDEX IDX_Pedidos_ReservaID
ON Pedido (Reservaid)
TABLESPACE PedidosTS;


-- Indice en DetallePedidos basado en PedidoID y MenuID
CREATE INDEX IDX_DetallePedidos_PedidoID_MenuID
ON DetallePedido (PedidoID, MenuID)
TABLESPACE PedidosTS;


-- Indice en Clientes basado en FechaRegistro
CREATE INDEX IDX_Clientes_FechaRegistro
ON Cliente (FechaRegistro)
TABLESPACE ReservasTS;


-- Auditoria de Consultas
AUDIT SELECT ON Cliente;


-- Politica de Contraseñas
ALTER PROFILE DEFAULT LIMIT
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LIFE_TIME 90
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_TIME 365
    PASSWORD_REUSE_MAX 5
    PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION_11G;


/****************************************************************************************************************************************************************
***                                                                         INSERTS                                                                           ***
****************************************************************************************************************************************************************/
INSERT INTO CLIENTE (NOMBRE, APELLIDO, EMAIL, TELEFONO)
VALUES ('Juan', 'Perez', 'juan.perez@example.com', '1234567890');

INSERT INTO CLIENTE (NOMBRE, APELLIDO, EMAIL, TELEFONO)
VALUES ('Maria', 'Gomez', 'maria.gomez@example.com', '0987654321');

INSERT INTO CLIENTE (NOMBRE, APELLIDO, EMAIL, TELEFONO)
VALUES ('Carlos', 'Rodriguez', 'carlos.rodriguez@example.com', '1122334455');


INSERT INTO MESA (NUMEROMESA, CAPACIDAD, UBICACION)
VALUES (1, 4, 'Planta Baja');

INSERT INTO MESA (NUMEROMESA, CAPACIDAD, UBICACION)
VALUES (2, 6, 'Terraza');

INSERT INTO MESA (NUMEROMESA, CAPACIDAD, UBICACION)
VALUES (3, 2, 'VIP');


INSERT INTO RESERVA (CLIENTEID, MESAID, FECHARESERVA, NUMEROPERSONAS)
VALUES (1, 1, TO_TIMESTAMP('2024-08-18 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4);

INSERT INTO RESERVA (CLIENTEID, MESAID, FECHARESERVA, NUMEROPERSONAS)
VALUES (2, 2, TO_TIMESTAMP('2024-08-19 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6);


INSERT INTO MENU (NOMBRE, DESCRIPCION, PRECIO)
VALUES ('Pizza Margherita', 'Pizza clasica italiana con tomate, mozzarella y albahaca', 12.50);

INSERT INTO MENU (NOMBRE, DESCRIPCION, PRECIO)
VALUES ('Ensalada Cesar', 'Ensalada con pollo, lechuga romana, crutones y aderezo Cesar', 8.90);

INSERT INTO MENU (NOMBRE, DESCRIPCION, PRECIO)
VALUES ('Tiramisu', 'Postre italiano hecho con cafe, queso mascarpone y cacao', 6.50);


INSERT INTO PEDIDO (RESERVAID, TOTAL)
VALUES (1, 37.90);

INSERT INTO PEDIDO (RESERVAID, TOTAL)
VALUES (2, 25.40);


INSERT INTO DETALLEPEDIDO (PEDIDOID, MENUID, CANTIDAD, PRECIO)
VALUES (1, 1, 2, 12.50);

INSERT INTO DETALLEPEDIDO (PEDIDOID, MENUID, CANTIDAD, PRECIO)
VALUES (1, 2, 1, 8.90);

INSERT INTO DETALLEPEDIDO (PEDIDOID, MENUID, CANTIDAD, PRECIO)
VALUES (2, 3, 2, 6.50);


INSERT INTO EMPLEADO (NOMBRE, APELLIDO, CARGO)
VALUES ('Luis', 'Ramirez', 'Mesero');

INSERT INTO EMPLEADO (NOMBRE, APELLIDO, CARGO)
VALUES ('Ana', 'Fernandez', 'Cocinera');

INSERT INTO EMPLEADO (NOMBRE, APELLIDO, CARGO)
VALUES ('Pedro', 'Lopez', 'Gerente');


INSERT INTO RESTAURANTE (NOMBRE, DIRECCION, TELEFONO, EMAIL)
VALUES ('Restaurante El Sabor', 'Calle Falsa 123, Ciudad X', '22223333', 'contacto@sabor.com');

INSERT INTO RESTAURANTE (NOMBRE, DIRECCION, TELEFONO, EMAIL)
VALUES ('Restaurante Gourmet', 'Avenida Principal 456, Ciudad Y', '33334444', 'info@gourmet.com');


/****************************************************************************************************************************************************************
***                                                                Procedimientos Almacenados                                                                 ***
****************************************************************************************************************************************************************/

