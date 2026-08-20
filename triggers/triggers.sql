-- =====================================================================
--  TRIGGERS.sql Stefani
--  Triggers para la Distribuidora de Gaseosas del Valle
--
--  Un TRIGGER es un bloque de código que se ejecuta AUTOMÁTICAMENTE
--  cuando ocurre un evento en una tabla (INSERT, UPDATE o DELETE).
--  Nunca se llama a mano; MySQL lo dispara solo.
-- =====================================================================

USE distribuidora_valle;

DELIMITER $$

-- ---------------------------------------------------------------------
-- TRIGGER: tr_after_actualizar_stock
-- Se dispara DESPUÉS de insertar una fila en detalle_pedido (es decir,
-- cada vez que se agrega un producto a una venta) y descuenta
-- automáticamente esa cantidad del stock del producto.
-- ---------------------------------------------------------------------
CREATE TRIGGER tr_after_actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END $$


-- ---------------------------------------------------------------------
-- TRIGGER: tr_after_auditar_cambio_precio
-- Se dispara DESPUÉS de actualizar un producto. Si el precio cambió,
-- guarda el precio anterior y el nuevo en la tabla auditoria_precios.
-- ---------------------------------------------------------------------
CREATE TRIGGER tr_after_auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- OLD.precio = el precio que tenía ANTES del UPDATE
    -- NEW.precio = el precio que quedó DESPUÉS del UPDATE
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precios (id_producto, precio_anterior, precio_nuevo)
        VALUES (NEW.id_producto, OLD.precio, NEW.precio);
    END IF;
END $$

DELIMITER ;


-- ---------------------------------------------------------------------
-- Ejemplo de prueba para tr_after_actualizar_stock
-- (descomenta para probar; recuerda que necesita un pedido existente)
-- ---------------------------------------------------------------------
-- INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
-- VALUES (1, 4, 3, 4.00);
-- SELECT stock FROM productos WHERE id_producto = 4; -- debería bajar en 3

-- ---------------------------------------------------------------------
-- Ejemplo de prueba para tr_after_auditar_cambio_precio
-- ---------------------------------------------------------------------
-- UPDATE productos SET precio = 7.00 WHERE id_producto = 1;
-- SELECT * FROM auditoria_precios; -- debería mostrar el cambio de 6.50 a 7.00
