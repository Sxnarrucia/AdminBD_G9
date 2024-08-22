--Proyecto Final - CRUD
--Grupo 9
/****************************************************************************************************************************************************************
***                                                                     Bloques Anonimos                                                                      ***
****************************************************************************************************************************************************************/

SET SERVEROUTPUT ON;

/**************************************************************************|CLIENTE|****************************************************************************/

-- |Bloque anonimo para ejecutar el USP_InsertarCliente|
ACCEPT p_nombrePrompt CHAR PROMPT 'Ingrese el nombre del cliente: ' -- Le solicita los datos al usuario
ACCEPT p_apellidoPrompt CHAR PROMPT 'Ingrese el apellido del cliente: '
ACCEPT p_emailPrompt CHAR PROMPT 'Ingrese el email del cliente: '
ACCEPT p_telefonoPrompt CHAR PROMPT 'Ingrese el teléfono del cliente: '

BEGIN
    USP_InsertarCliente(
        p_nombre        => '&p_nombrePrompt',
        p_apellido      => '&p_apellidoPrompt',
        p_email         => '&p_emailPrompt',
        p_telefono      => '&p_telefonoPrompt',
        p_fechaRegistro => SYSDATE,  -- Asigna la fecha de registro actual automáticamente
        p_activo        => 1         -- Asigna el estado activo automáticamente
    );
    DBMS_OUTPUT.PUT_LINE('Cliente insertado correctamente.'); -- Mensaje de confirmación
END;
/

SELECT * FROM CLIENTE;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- |Bloque anonimo para ejecutar el USP_EliminarCliente|
ACCEPT p_clienteIdPrompt CHAR PROMPT 'Ingrese el ID del cliente a eliminar: '

DECLARE
    v_clienteId NUMBER;
BEGIN
    v_clienteId := TO_NUMBER('&p_clienteIdPrompt'); -- Convierte la entrada del usuario a número y la asigna a la variable

    USP_EliminarCliente(p_clienteId => v_clienteId); -- Llama al procedimiento almacenado para eliminar el cliente
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Cliente eliminado correctamente.'); -- Mensaje de confirmación
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- En caso de error, revierte cualquier cambio
        DBMS_OUTPUT.PUT_LINE('Error al eliminar el cliente: ' || SQLERRM);
END;
/

SELECT * FROM CLIENTE;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- |Bloque anonimo para ejecutar el USP_ActualizarCliente|
ACCEPT p_clienteIdPrompt CHAR PROMPT 'Ingrese el ID del cliente a actualizar: '
ACCEPT p_nombrePrompt CHAR PROMPT 'Ingrese el nuevo nombre del cliente: '
ACCEPT p_apellidoPrompt CHAR PROMPT 'Ingrese el nuevo apellido del cliente: '
ACCEPT p_emailPrompt CHAR PROMPT 'Ingrese el nuevo email del cliente: '
ACCEPT p_telefonoPrompt CHAR PROMPT 'Ingrese el nuevo teléfono del cliente: '
ACCEPT p_activoPrompt CHAR PROMPT 'Ingrese el estado activo del cliente (1 para activo, 0 para inactivo): '

DECLARE
BEGIN
    USP_ActualizarCliente(
        p_clienteId     => TO_NUMBER('&p_clienteIdPrompt'),
        p_nombre        => '&p_nombrePrompt',
        p_apellido      => '&p_apellidoPrompt',
        p_email         => '&p_emailPrompt',
        p_telefono      => '&p_telefonoPrompt',
        p_fechaRegistro => SYSDATE,  -- Asigna la fecha de registro actual automáticamente
        p_activo        => TO_NUMBER('&p_activoPrompt')
    );

    DBMS_OUTPUT.PUT_LINE('Cliente actualizado correctamente.'); -- Mensaje de confirmación

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al actualizar el cliente: ' || SQLERRM);
        ROLLBACK;
END;
/

SELECT * FROM CLIENTE
WHERE CLIENTEID = &p_clienteIdPrompt;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- |Bloque anonimo para ejecutar el USP_ObtenerCliente|
ACCEPT p_clienteIdPrompt CHAR PROMPT 'Por favor, ingrese el ID del cliente: '

DECLARE
    v_cursor SYS_REFCURSOR;
    
    v_clienteId NUMBER;
    v_nombre VARCHAR2(100);
    v_apellido VARCHAR2(100);
    v_email VARCHAR2(100);
    v_telefono VARCHAR2(20);
    v_fechaRegistro DATE;
    v_activo NUMBER;
BEGIN
    USP_ObtenerCliente(p_clienteId => &p_clienteIdPrompt, p_cursor => v_cursor);
    LOOP
        FETCH v_cursor INTO v_clienteId, v_nombre, v_apellido, v_email, v_telefono, v_fechaRegistro, v_activo;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || v_clienteId);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
        DBMS_OUTPUT.PUT_LINE('Apellido: ' || v_apellido);
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
        DBMS_OUTPUT.PUT_LINE('Telefono: ' || v_telefono);
        DBMS_OUTPUT.PUT_LINE('Fecha Registro: ' || TO_CHAR(v_fechaRegistro, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Activo: ' || v_activo);
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
    CLOSE v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
END;
/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

/***************************************************************************|RESERVA|***************************************************************************/

-- |Bloque anonimo para ingresar una Reserva|
ACCEPT p_emailPrompt CHAR PROMPT 'Ingrese el email del cliente: '
ACCEPT p_mesaIdPrompt CHAR PROMPT 'Ingrese el ID de la mesa: '
ACCEPT p_numeroPersonasPrompt CHAR PROMPT 'Ingrese el número de personas para la reserva: '

DECLARE
    v_clienteId NUMBER;
    v_nombreCliente VARCHAR2(100); -- Variable para almacenar el nombre del cliente
    v_apellidoCliente VARCHAR2(100);
    v_restaurante VARCHAR2(100);
    v_capacidad NUMBER;
    v_ubicacion VARCHAR2(100);
    v_fechaReserva DATE := SYSDATE;  -- Fecha de reserva predeterminada como la fecha actual
    v_estado VARCHAR2(50) := 'Pendiente';  -- Estado predeterminado
    v_activo NUMBER(1) := 1;  -- Actividad predeterminada

BEGIN
    -- Busca el CLIENTEID y el nombre basado en el correo electrónico proporcionado
    SELECT CLIENTEID, NOMBRE, APELLIDO INTO v_clienteId, v_nombreCliente, v_apellidoCliente
    FROM CLIENTE WHERE EMAIL = '&p_emailPrompt';
    
    -- Obtiene detalles de la mesa
    SELECT R.NOMBRE, M.CAPACIDAD, M.UBICACION INTO v_restaurante, v_capacidad, v_ubicacion
    FROM MESA M
    JOIN RESTAURANTE R ON M.RESTAURANTEID = R.RESTAURANTEID
    WHERE MESAID = TO_NUMBER('&p_mesaIdPrompt');

    -- Muestra detalles de la mesa al usuario
    DBMS_OUTPUT.PUT_LINE('Detalles de la mesa seleccionada:');
    DBMS_OUTPUT.PUT_LINE('Establecimiento: ' || v_restaurante || ' | Capacidad: ' || v_capacidad || ' | Ubicación: ' || v_ubicacion);

    -- Inserta la nueva reserva con valores predeterminados para fecha, estado y activo
    INSERT INTO RESERVA (CLIENTEID, MESAID, NUMEROPERSONAS, FECHARESERVA, ESTADO, ACTIVO)
    VALUES (v_clienteId, TO_NUMBER('&p_mesaIdPrompt'), TO_NUMBER('&p_numeroPersonasPrompt'), v_fechaReserva, v_estado, v_activo);

    DBMS_OUTPUT.PUT_LINE('Reserva insertada correctamente para el cliente ' || v_nombreCliente || ' ' || v_apellidoCliente || ' con ID ' || v_clienteId);

    COMMIT; -- Confirma la transacción

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró un cliente o mesa con los datos proporcionados.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar la reserva: ' || SQLERRM);
        ROLLBACK; -- Revierte la transacción en caso de error
END;
/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

/************************************************************************|DETALLEPEDIDO|************************************************************************/

-- |Bloque anonimo para ejecutar el USP_ObtenerCliente|
ACCEPT p_detallePedidoIdPrompt CHAR PROMPT 'Por favor, ingrese el ID del detalle de pedido: '

DECLARE
    v_cursor SYS_REFCURSOR;
    
    v_detallePedidoId NUMBER;
    v_pedidoId NUMBER;
    v_menuId NUMBER;
    v_cantidad NUMBER;
    v_precio NUMBER;
BEGIN
    -- Llamar al procedimiento almacenado para obtener el detalle de pedido
    USP_ObtenerDetallePedido(p_detallePedidoId => &p_detallePedidoIdPrompt, p_cursor => v_cursor);
    
    -- Leer y mostrar los detalles del pedido
    LOOP
        FETCH v_cursor INTO v_detallePedidoId, v_pedidoId, v_menuId, v_cantidad, v_precio;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Detalle Pedido ID: ' || v_detallePedidoId);
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedidoId);
        DBMS_OUTPUT.PUT_LINE('Menu ID: ' || v_menuId);
        DBMS_OUTPUT.PUT_LINE('Cantidad: ' || v_cantidad);
        DBMS_OUTPUT.PUT_LINE('Precio: ' || TO_CHAR(v_precio, '999G999G999D99', 'nls_numeric_characters='',.'''));
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
    CLOSE v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
END;
/