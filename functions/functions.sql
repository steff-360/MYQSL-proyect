-- =====================================================================
--  FUNCTIONS.sql Stefani
--  Funciones almacenadas para la Distribuidora de Gaseosas del Valle
--
--  Una FUNCIÓN en MySQL recibe parámetros, hace un cálculo y
--  DEVUELVE un solo valor (a diferencia de un procedimiento, que
--  puede no devolver nada o devolver varias cosas).
-- =====================================================================

USE distribuidora_valle;

-- Cambiamos el delimitador porque el cuerpo de la función usa punto y
-- coma (;) internamente, y no queremos que MySQL corte el bloque ahí.
DELIMITER $$

-- ---------------------------------------------------------------------
-- FUNCIÓN: fn_calcular_total_con_iva
-- Recibe un monto (sin impuesto) y devuelve ese monto con el 12% de
-- IVA (Impuesto al Valor Agregado, tasa usada en Guatemala) incluido.
-- ---------------------------------------------------------------------
CREATE FUNCTION fn_calcular_total_con_iva(monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_con_iva DECIMAL(10,2);

    -- 0.12 = 12% de IVA
    SET total_con_iva = monto * 1.12;

    RETURN total_con_iva;
END $$


-- ---------------------------------------------------------------------
-- FUNCIÓN: fn_validar_stock
-- Recibe el id de un producto y la cantidad que se quiere vender.
-- Devuelve TRUE (1) si hay suficiente stock, FALSE (0) si no.
-- ---------------------------------------------------------------------
CREATE FUNCTION fn_validar_stock(p_id_producto INT, p_cantidad INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE stock_disponible INT DEFAULT 0;

    SELECT stock INTO stock_disponible
    FROM productos
    WHERE id_producto = p_id_producto;

    -- Si el producto no existe, stock_disponible queda en NULL,
    -- así que también devolvemos FALSE en ese caso.
    IF stock_disponible IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN stock_disponible >= p_cantidad;
END $$

-- Regresamos el delimitador a su valor normal.
DELIMITER ;


-- ---------------------------------------------------------------------
-- Ejemplos de uso (puedes borrar estas líneas, son solo para probar)
-- ---------------------------------------------------------------------

-- ¿Cuánto sería 100 quetzales con IVA incluido?
SELECT fn_calcular_total_con_iva(100.00) AS total_con_iva;

-- ¿Hay stock suficiente del producto 1 para vender 5 unidades?
SELECT fn_validar_stock(1, 5) AS hay_stock;

-- ¿Hay stock suficiente del producto 8 para vender 999 unidades? (debería ser 0/FALSE)
SELECT fn_validar_stock(8, 999) AS hay_stock;
