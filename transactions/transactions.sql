-- =====================================================================
--  TRANSACTIONS.sql Stefani
--  Procedimiento almacenado transaccional para la Distribuidora
--
--  Una TRANSACCIÓN agrupa varios pasos como si fueran uno solo:
--  o se ejecutan TODOS, o no se ejecuta NINGUNO (si algo falla, se
--  hace ROLLBACK y todo vuelve a como estaba antes).
--  Esto evita, por ejemplo, que se registre una venta pero no se
--  descuente el stock, o viceversa.
-- =====================================================================

USE distribuidora_valle;

DELIMITER //

-- ---------------------------------------------------------------------
-- PROCEDIMIENTO: sp_comprar
-- Encapsula el proceso completo de una compra/venta:
--   1) Valida que haya stock suficiente (usa fn_validar_stock)
--   2) Crea el pedido (cabecera)
--   3) Inserta el detalle del pedido
--   4) Actualiza el total del pedido
-- Si cualquier paso falla, deshace todo (ROLLBACK).
-- ---------------------------------------------------------------------
CREATE PROCEDURE sp_comprar (
    IN p_id_cliente  INT,
    IN p_id_sede     INT,
    IN p_id_usuario  INT,
    IN p_id_producto INT,
    IN p_cantidad    INT,
    OUT p_resultado  VARCHAR(200)
)
BEGIN
    DECLARE v_precio_actual DECIMAL(10,2);
    DECLARE v_id_pedido INT;
    DECLARE v_hay_stock BOOLEAN;

    -- Si ocurre cualquier error de SQL durante la transacción,
    -- este "handler" hace ROLLBACK automáticamente.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_resultado = 'ERROR: ocurrió un problema, la compra fue cancelada.';
    END;

    START TRANSACTION;

    -- Paso 1: validar stock usando la función que ya creamos
    SET v_hay_stock = fn_validar_stock(p_id_producto, p_cantidad);

    IF NOT v_hay_stock THEN
        SET p_resultado = 'ERROR: no hay stock suficiente para esa cantidad.';
        ROLLBACK;
    ELSE
        -- Paso 2: obtener el precio actual del producto
        SELECT precio INTO v_precio_actual
        FROM productos
        WHERE id_producto = p_id_producto;

        -- Paso 3: crear la cabecera del pedido (total en 0 por ahora)
        INSERT INTO pedidos (id_cliente, id_sede, id_usuario, estado, total)
        VALUES (p_id_cliente, p_id_sede, p_id_usuario, 'completado', 0);

        SET v_id_pedido = LAST_INSERT_ID();

        -- Paso 4: insertar el detalle (esto dispara tr_after_actualizar_stock
        -- automáticamente y descuenta el stock)
        INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
        VALUES (v_id_pedido, p_id_producto, p_cantidad, v_precio_actual);

        -- Paso 5: recalcular el total del pedido
        UPDATE pedidos
        SET total = (
            SELECT SUM(subtotal) FROM detalle_pedido WHERE id_pedido = v_id_pedido
        )
        WHERE id_pedido = v_id_pedido;

        COMMIT;
        SET p_resultado = CONCAT('OK: compra registrada con el número de pedido ', v_id_pedido, '.');
    END IF;
END //

DELIMITER ;


-- ---------------------------------------------------------------------
-- Ejemplo de uso de sp_comprar
-- (queda comentado a propósito: si lo ejecutas, crea un pedido nuevo
-- de verdad y cambia el stock. Descomenta solo cuando quieras probarlo,
-- así los datos de data.sql se mantienen predecibles para results.md)
-- ---------------------------------------------------------------------
-- CALL sp_comprar(1, 1, 2, 1, 5, @resultado);
-- SELECT @resultado AS resultado;

-- Ejemplo donde debería fallar por falta de stock (ajusta la cantidad
-- si tu stock de prueba es distinto)
-- CALL sp_comprar(1, 1, 2, 8, 99999, @resultado2);
-- SELECT @resultado2 AS resultado;
