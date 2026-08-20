-- =====================================================================
--  VIEWS_AND_QUERIES.sql Stefani
--  Vistas (DQL) para la Distribuidora de Gaseosas del Valle
--
--  Una VISTA es como una "consulta guardada": la creas una vez y
--  luego la usas como si fuera una tabla (SELECT * FROM vista...).
-- =====================================================================

USE distribuidora_valle;


-- ---------------------------------------------------------------------
-- VISTA: vista_resumen_pedidos_por_sede
-- Muestra, por cada sede, cuántos pedidos tiene y cuánto ha vendido.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_resumen_pedidos_por_sede AS
SELECT
    s.id_sede,
    s.nombre            AS sede,
    COUNT(p.id_pedido)  AS total_pedidos,
    COALESCE(SUM(CASE WHEN p.estado = 'completado' THEN p.total ELSE 0 END), 0) AS total_vendido
FROM sedes s
LEFT JOIN pedidos p ON p.id_sede = s.id_sede
GROUP BY s.id_sede, s.nombre;


-- ---------------------------------------------------------------------
-- VISTA: vista_productos_bajo_stock
-- Lista los productos cuyo stock actual está en o por debajo de su
-- stock mínimo, es decir, que necesitan reabastecerse pronto.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_productos_bajo_stock AS
SELECT
    pr.id_producto,
    pr.nombre,
    c.nombre    AS categoria,
    pr.stock,
    pr.stock_minimo
FROM productos pr
LEFT JOIN categorias c ON c.id_categoria = pr.id_categoria
WHERE pr.stock <= pr.stock_minimo
  AND pr.activo = TRUE;


-- ---------------------------------------------------------------------
-- VISTA: vista_clientes_activos
-- Segmenta a los clientes según cuánto han comprado (pedidos completados).
-- "Frecuente" si tiene 2 o más pedidos completados, "Ocasional" si tiene
-- 1, y "Sin compras" si no tiene ninguno.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_clientes_activos AS
SELECT
    cl.id_cliente,
    cl.nombre,
    COUNT(p.id_pedido) AS pedidos_completados,
    COALESCE(SUM(p.total), 0) AS total_comprado,
    CASE
        WHEN COUNT(p.id_pedido) >= 2 THEN 'Frecuente'
        WHEN COUNT(p.id_pedido) = 1  THEN 'Ocasional'
        ELSE 'Sin compras'
    END AS segmento
FROM clientes cl
LEFT JOIN pedidos p
    ON p.id_cliente = cl.id_cliente AND p.estado = 'completado'
GROUP BY cl.id_cliente, cl.nombre;


-- ---------------------------------------------------------------------
-- Algunas consultas de ejemplo para probar las vistas
-- ---------------------------------------------------------------------

-- Ver el resumen de ventas por sede
SELECT * FROM vista_resumen_pedidos_por_sede;

-- Ver qué productos hay que reabastecer
SELECT * FROM vista_productos_bajo_stock;

-- Ver cómo están segmentados los clientes
SELECT * FROM vista_clientes_activos;
