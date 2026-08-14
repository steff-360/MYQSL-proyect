-- ============================================================
-- Gaseosas del Valle S.A.
-- Script: views_and_queries.sql
-- Descripción: Vistas (CREATE VIEW) y consultas analíticas
-- Requiere haber ejecutado database.sql, functions.sql y
-- triggers.sql primero
-- ============================================================

USE gaseosas_del_valle;

-- ============================================================
-- VISTAS
-- ============================================================

-- ------------------------------------------------------------
-- vista_resumen_pedidos_por_sede
-- Cantidad total de pedidos y ventas (con IVA) por sede
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vista_resumen_pedidos_por_sede;

CREATE VIEW vista_resumen_pedidos_por_sede AS
SELECT
    s.id_sede,
    s.nombre_sede,
    s.ubicacion,
    COUNT(p.id_pedido)          AS total_pedidos,
    IFNULL(SUM(p.total_con_iva), 0) AS ventas_totales_con_iva
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY s.id_sede, s.nombre_sede, s.ubicacion;

-- ------------------------------------------------------------
-- vista_productos_bajo_stock
-- Productos con stock_actual <= stock_minimo
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vista_productos_bajo_stock;

CREATE VIEW vista_productos_bajo_stock AS
SELECT
    id_producto,
    nombre,
    categoria,
    stock_actual,
    stock_minimo,
    (stock_minimo - stock_actual) AS unidades_faltantes
FROM productos
WHERE stock_actual <= stock_minimo;

-- ------------------------------------------------------------
-- vista_clientes_activos
-- Clientes con al menos un pedido registrado
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vista_clientes_activos;

CREATE VIEW vista_clientes_activos AS
SELECT
    c.id_cliente,
    c.nombre_completo,
    c.identificacion,
    c.telefono,
    COUNT(p.id_pedido) AS total_pedidos,
    IFNULL(SUM(p.total_con_iva), 0) AS total_comprado
FROM clientes c
INNER JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo, c.identificacion, c.telefono;

-- ============================================================
-- CONSULTAS SQL REQUERIDAS
-- ============================================================

-- 1) Productos con stock por debajo del mínimo
SELECT id_producto, nombre, categoria, stock_actual, stock_minimo
FROM productos
WHERE stock_actual <= stock_minimo;

-- 2) Pedidos realizados entre dos fechas (BETWEEN)
SELECT id_pedido, fecha_pedido, id_cliente, id_sede, total_con_iva
FROM pedidos
WHERE fecha_pedido BETWEEN '2026-06-01' AND '2026-06-30';

-- 3) Productos más vendidos (JOIN + GROUP BY)
SELECT
    pr.id_producto,
    pr.nombre,
    SUM(dp.cantidad) AS unidades_vendidas
FROM detalle_pedido dp
JOIN productos pr ON pr.id_producto = dp.id_producto
GROUP BY pr.id_producto, pr.nombre
ORDER BY unidades_vendidas DESC;

-- 4) Clientes y cantidad de pedidos realizados
SELECT
    c.id_cliente,
    c.nombre_completo,
    COUNT(p.id_pedido) AS cantidad_pedidos
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo
ORDER BY cantidad_pedidos DESC;

-- 5) Buscar clientes por nombre parcial (LIKE)
SELECT id_cliente, nombre_completo, identificacion, telefono
FROM clientes
WHERE nombre_completo LIKE '%Super%';

-- 6) Productos de ciertas categorías (IN)
SELECT id_producto, nombre, categoria, precio
FROM productos
WHERE categoria IN ('Gaseosa Cola', 'Mixers');

-- 7) Cliente con mayor número de pedidos (subconsulta)
SELECT c.id_cliente, c.nombre_completo, conteo.cantidad_pedidos
FROM clientes c
JOIN (
    SELECT id_cliente, COUNT(*) AS cantidad_pedidos
    FROM pedidos
    GROUP BY id_cliente
) AS conteo ON conteo.id_cliente = c.id_cliente
WHERE conteo.cantidad_pedidos = (
    SELECT MAX(cantidad_pedidos)
    FROM (
        SELECT COUNT(*) AS cantidad_pedidos
        FROM pedidos
        GROUP BY id_cliente
    ) AS sub
);

-- 8) Pedidos y totales agrupados por sede
SELECT
    s.id_sede,
    s.nombre_sede,
    COUNT(p.id_pedido) AS total_pedidos,
    IFNULL(SUM(p.total_con_iva), 0) AS total_ventas_con_iva
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY s.id_sede, s.nombre_sede
ORDER BY total_ventas_con_iva DESC;

-- ============================================================
-- CONSULTAS SOBRE LAS VISTAS (ejemplos de uso)
-- ============================================================

-- SELECT * FROM vista_resumen_pedidos_por_sede;
-- SELECT * FROM vista_productos_bajo_stock;
-- SELECT * FROM vista_clientes_activos ORDER BY total_comprado DESC;