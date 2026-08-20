-- =====================================================================
--  EVENTS.sql Stefani
--  Eventos programados para la Distribuidora de Gaseosas del Valle
--
--  Un EVENTO es una tarea que MySQL ejecuta solo, en automático,
--  según un horario que tú defines (como una alarma). No necesitas
--  llamarlo a mano ni tener una aplicación corriendo.
-- =====================================================================

USE distribuidora_valle;

-- El "programador de eventos" de MySQL está apagado por defecto.
-- Esta línea lo activa (necesario para que el evento se ejecute).
SET GLOBAL event_scheduler = ON;

DELIMITER $$

-- ---------------------------------------------------------------------
-- EVENTO: evento_revisar_stock
-- Se ejecuta UNA VEZ AL DÍA. Revisa todos los productos activos y,
-- por cada uno que tenga stock igual o menor a su stock mínimo,
-- guarda un registro en la tabla log_stock_bajo.
-- ---------------------------------------------------------------------
CREATE EVENT IF NOT EXISTS evento_revisar_stock
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO log_stock_bajo (id_producto, stock_actual)
    SELECT id_producto, stock
    FROM productos
    WHERE stock <= stock_minimo
      AND activo = TRUE;
END $$

DELIMITER ;


-- ---------------------------------------------------------------------
-- Cómo probarlo manualmente (sin esperar un día completo):
-- Puedes ejecutar el mismo bloque de código del evento directamente,
-- o forzar su ejecución así:
-- ---------------------------------------------------------------------
-- Ver que el evento quedó creado:
-- SHOW EVENTS FROM distribuidora_valle;

-- Ejecutar la misma lógica manualmente para probarla ya mismo:
-- INSERT INTO log_stock_bajo (id_producto, stock_actual)
-- SELECT id_producto, stock FROM productos WHERE stock <= stock_minimo AND activo = TRUE;

-- Revisar el resultado:
-- SELECT * FROM log_stock_bajo;
