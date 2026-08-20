-- ============================================================
-- Gaseosas del Valle S.A. Stafani
-- Examen: Reporte de Clientes y Pedidos
-- ============================================================

USE distribuidora_de_gaseosas_del_valle;


-- ============================================================
-- 1. FUNCIÓN
-- total_pedidos_cliente_periodo
-- ============================================================
-- Recibe:
--   ID del cliente
--   Fecha de inicio
--   Fecha final
--
-- Retorna el total de los pedidos realizados por el cliente
-- dentro del rango de fechas.
--
-- Si no tiene pedidos, retorna 0.
-- ============================================================

DROP FUNCTION IF EXISTS total_pedido_cliente_periodo;

DELIMITER //

CREATE FUNCTION total_pedidos_cliente_periodo(
    p_id_cliente INT,
    p_fecha_inicio DATE,
    p_fecha_final DATE
)
RETURNS DECIMAL(12,2)
BEGIN

    DECLARE total DECIMAL(12,2);

    SELECT IFNULL(SUM(total_con_iva), 0)
    INTO total
    FROM pedidos
    WHERE id_cliente = p_id_cliente
      AND fecha BETWEEN p_fecha_inicio AND p_fecha_final;

    RETURN total;

END//

DELIMITER ;


-- ============================================================
-- 2. VISTA
-- vista_clientes_activos
-- ============================================================
-- Muestra los clientes que han realizado al menos un pedido
-- durante los últimos 90 días.
--
-- Muestra:
--   Nombre del cliente
--   Número total de pedidos
--   Valor total comprado
-- ============================================================

DROP VIEW IF EXISTS vista_clientes_activos;

CREATE VIEW vista_clientes_activos AS
SELECT
    c.nombre_completo AS nombre_cliente,
    COUNT(p.id) AS total_pedidos,
    SUM(p.total_con_iva) AS total_comprado
FROM clientes c
INNER JOIN pedidos p
    ON c.id = p.id_cliente
WHERE p.fecha >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY
    c.id,
    c.nombre_completo;


-- ============================================================
-- 3. CONSULTA ANALÍTICA
-- TOP 5 CLIENTES DEL AÑO ACTUAL
-- ============================================================
-- Muestra:
--   Nombre del cliente
--   Cantidad de pedidos
--   Total comprado
--
-- Los resultados se ordenan de mayor a menor.
-- LIMIT 5 muestra solamente los cinco primeros.
-- ============================================================

SELECT
    c.nombre_completo AS nombre_cliente,
    COUNT(p.id) AS cantidad_pedidos,
    SUM(p.total_con_iva) AS total_comprado
FROM clientes c
INNER JOIN pedidos p
    ON c.id = p.id_cliente
WHERE YEAR(p.fecha) = YEAR(CURDATE())
GROUP BY
    c.id,
    c.nombre_completo
ORDER BY
    total_comprado DESC
LIMIT 5;

--====================================================================================
-- CONSULTA EL PROMEDIO
--====================================================================================
Esta consulta puede servir para comparar cuánto compra en promedio
cada cliente y así tener otra forma de analizar las ventas.
SELECT
    c.nombre_completo AS nombre_cliente,
    COUNT(p.id) AS cantidad_pedidos,
    AVG(p.total_con_iva) AS promedio_compra
FROM clientes c
INNER JOIN pedidos p
    ON c.id = p.id_cliente
GROUP BY
    c.id,
    c.nombre_completo
ORDER BY
    promedio_compra DESC;

-- ============================================================
-- 4. TABLA DE AUDITORÍA
-- ============================================================
-- Esta tabla almacenará los pedidos nuevos registrados
-- por medio del trigger.
-- ============================================================

CREATE TABLE IF NOT EXISTS auditoria_pedidos (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_pedido DECIMAL(12,2),
    usuario_responsable VARCHAR(50) DEFAULT 'sistema'
);


-- ============================================================
-- 5. TRIGGER
-- registrar_nuevo_pedido_trigger
-- ============================================================
-- Se ejecuta después de insertar un pedido.
--
-- Guarda automáticamente:
--   id_pedido
--   id_cliente
--   fecha_registro
--   total_pedido
--   usuario_responsable
-- ============================================================

DROP TRIGGER IF EXISTS registrar_nuevo_pedido_trigger;

DELIMITER //

CREATE TRIGGER registrar_nuevo_pedido_trigger
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN

    INSERT INTO auditoria_pedidos
    (
        id_pedido,
        id_cliente,
        fecha_registro,
        total_pedido,
        usuario_responsable
    )
    VALUES
    (
        NEW.id,
        NEW.id_cliente,
        NOW(),
        NEW.total_con_iva,
        'sistema'
    );

END//

DELIMITER ;


-- ============================================================
-- ============================================================

























































































































