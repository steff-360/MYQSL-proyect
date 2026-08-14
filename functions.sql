-- ============================================================
-- Gaseosas del Valle S.A.
-- Script: functions.sql
-- Descripción: Funciones personalizadas (CREATE FUNCTION)
-- Requiere haber ejecutado database.sql primero
-- ============================================================

USE gaseosas_del_valle;

-- ------------------------------------------------------------
-- fn_calcular_total_con_iva(id_pedido)
-- Calcula y RETORNA el total con IVA (19%) de un pedido,
-- sumando los subtotales registrados en detalle_pedido.
--
-- NOTA DE DISEÑO: la función es de solo lectura (no modifica
-- datos). MySQL no permite que una función actualice una tabla
-- que ya está siendo leída por la sentencia que la invoca
-- (error 1442), por lo que la persistencia de los totales en
-- la tabla "pedidos" se delega al trigger
-- tr_actualizar_totales_pedido (ver triggers.sql), que sí puede
-- invocar esta función de forma segura porque actúa sobre una
-- tabla distinta a la que dispara el evento.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calcular_total_con_iva;

DELIMITER $$

CREATE FUNCTION fn_calcular_total_con_iva(p_id_pedido INT)
RETURNS DECIMAL(12,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_sin_iva DECIMAL(12,2) DEFAULT 0;

    SELECT IFNULL(SUM(subtotal), 0)
    INTO v_total_sin_iva
    FROM detalle_pedido
    WHERE id_pedido = p_id_pedido;

    RETURN ROUND(v_total_sin_iva * 1.19, 2);
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- fn_validar_stock(id_producto, cantidad)
-- Retorna un mensaje indicando si hay stock suficiente para
-- despachar la cantidad solicitada de un producto.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_validar_stock;

DELIMITER $$

CREATE FUNCTION fn_validar_stock(p_id_producto INT, p_cantidad INT)
RETURNS VARCHAR(150)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock_actual INT DEFAULT 0;
    DECLARE v_nombre VARCHAR(100) DEFAULT '';
    DECLARE v_mensaje VARCHAR(150);

    SELECT stock_actual, nombre
    INTO v_stock_actual, v_nombre
    FROM productos
    WHERE id_producto = p_id_producto;

    IF v_nombre IS NULL THEN
        SET v_mensaje = CONCAT('Producto con id ', p_id_producto, ' no existe.');
    ELSEIF v_stock_actual >= p_cantidad THEN
        SET v_mensaje = CONCAT('Stock suficiente para "', v_nombre, '": disponible ', v_stock_actual, ', solicitado ', p_cantidad, '.');
    ELSE
        SET v_mensaje = CONCAT('Stock INSUFICIENTE para "', v_nombre, '": disponible ', v_stock_actual, ', solicitado ', p_cantidad, '.');
    END IF;

    RETURN v_mensaje;
END$$

DELIMITER ;

-- ============================================================
-- EJEMPLOS DE USO
-- ============================================================

-- Ejemplo: calcular (sin persistir) el total con IVA de un pedido puntual
-- SELECT fn_calcular_total_con_iva(1) AS total_con_iva_pedido_1;

-- Ejemplo: validar stock antes de confirmar un pedido
-- SELECT fn_validar_stock(4, 50) AS resultado;   -- Limonada Soda: stock 90, pide 50 -> suficiente
-- SELECT fn_validar_stock(6, 100) AS resultado;  -- Cola Zero: stock 60, pide 100 -> insuficiente

-- La persistencia de total_sin_iva / total_con_iva en la tabla "pedidos"
-- ocurre automáticamente mediante el trigger tr_actualizar_totales_pedido
-- (definido en triggers.sql) cada vez que se inserta, actualiza o elimina
-- un registro de detalle_pedido.