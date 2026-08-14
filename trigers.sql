-- ============================================================
-- Gaseosas del Valle S.A. Stefani
-- Script: triggers.sql
-- Descripción: Triggers de integridad y auditoría
-- Requiere haber ejecutado database.sql y functions.sql primero
-- ============================================================

USE gaseosas_del_valle;

-- ------------------------------------------------------------
-- tr_actualizar_stock
-- Al insertar un registro en detalle_pedido, descuenta la
-- cantidad vendida del stock_actual del producto y valida
-- que exista stock suficiente antes de permitir la venta.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_actualizar_stock;

DELIMITER $$

CREATE TRIGGER tr_actualizar_stock
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_stock_disponible INT;

    SELECT stock_actual INTO v_stock_disponible
    FROM productos
    WHERE id_producto = NEW.id_producto;

    IF v_stock_disponible IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El producto especificado no existe.';
    ELSEIF v_stock_disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para completar el pedido.';
    END IF;

    -- Descuenta el stock automáticamente
    UPDATE productos
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- tr_auditar_cambio_precio
-- Al actualizar el campo precio en productos, registra en
-- auditoria_precios la fecha, el precio anterior y el nuevo.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_auditar_cambio_precio;

DELIMITER $$

CREATE TRIGGER tr_auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios (id_producto, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio, NOW());
    END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- tr_actualizar_totales_pedido
-- Mantiene sincronizados total_sin_iva y total_con_iva del
-- pedido cada vez que se inserta, actualiza o elimina un
-- registro de detalle_pedido. Se apoya en la función
-- fn_calcular_total_con_iva (functions.sql) para el cálculo
-- del IVA (19%).
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS tr_actualizar_totales_pedido_ins;
DROP TRIGGER IF EXISTS tr_actualizar_totales_pedido_upd;
DROP TRIGGER IF EXISTS tr_actualizar_totales_pedido_del;

DELIMITER $$

CREATE TRIGGER tr_actualizar_totales_pedido_ins
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET total_sin_iva = (
            SELECT IFNULL(SUM(subtotal), 0)
            FROM detalle_pedido
            WHERE id_pedido = NEW.id_pedido
        ),
        total_con_iva = fn_calcular_total_con_iva(NEW.id_pedido)
    WHERE id_pedido = NEW.id_pedido;
END$$

CREATE TRIGGER tr_actualizar_totales_pedido_upd
AFTER UPDATE ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET total_sin_iva = (
            SELECT IFNULL(SUM(subtotal), 0)
            FROM detalle_pedido
            WHERE id_pedido = NEW.id_pedido
        ),
        total_con_iva = fn_calcular_total_con_iva(NEW.id_pedido)
    WHERE id_pedido = NEW.id_pedido;
END$$

CREATE TRIGGER tr_actualizar_totales_pedido_del
AFTER DELETE ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET total_sin_iva = (
            SELECT IFNULL(SUM(subtotal), 0)
            FROM detalle_pedido
            WHERE id_pedido = OLD.id_pedido
        ),
        total_con_iva = fn_calcular_total_con_iva(OLD.id_pedido)
    WHERE id_pedido = OLD.id_pedido;
END$$

DELIMITER ;

-- ============================================================
-- SINCRONIZACIÓN DE DATOS DE PRUEBA
-- Los pedidos y detalles de prueba se cargaron en database.sql,
-- antes de que existieran estos triggers, así que se recalculan
-- una única vez aquí para dejar los totales consistentes.
-- ============================================================
UPDATE pedidos p
SET total_sin_iva = (
        SELECT IFNULL(SUM(subtotal), 0)
        FROM detalle_pedido d
        WHERE d.id_pedido = p.id_pedido
    ),
    total_con_iva = fn_calcular_total_con_iva(p.id_pedido);

-- ============================================================
-- PRUEBAS DE LOS TRIGGERS
-- ============================================================

-- Prueba tr_actualizar_stock: inserta un detalle y observa el
-- descuento automático en productos.stock_actual
-- INSERT INTO pedidos (id_cliente, id_sede, total_sin_iva, total_con_iva)
--     VALUES (2, 1, 0, 0);
-- INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, subtotal)
--     VALUES (LAST_INSERT_ID(), 1, 5, 5 * 2200.00);
-- SELECT stock_actual FROM productos WHERE id_producto = 1;

-- Prueba de bloqueo por stock insuficiente (debe lanzar error 45000)
-- INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, subtotal)
--     VALUES (1, 6, 9999, 9999 * 2300.00);

-- Prueba tr_auditar_cambio_precio: actualiza un precio y revisa la auditoría
-- UPDATE productos SET precio = 2400.00 WHERE id_producto = 1;
-- SELECT * FROM auditoria_precios WHERE id_producto = 1;