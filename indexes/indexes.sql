-- =====================================================================
--  INDEXES.sql
--  Índices para la Distribuidora de Gaseosas del Valle
--
--  Un ÍNDICE es como el índice de un libro: le ayuda a MySQL a
--  encontrar filas más rápido sin tener que revisar la tabla entera.
--  Son especialmente útiles en columnas que usas mucho en WHERE,
--  JOIN o ORDER BY. No los pongas en todas las columnas: cada índice
--  también hace un poco más lentas las escrituras (INSERT/UPDATE).
-- =====================================================================

USE distribuidora_valle;

-- 1) Buscar rápido productos por nombre (por ejemplo, en un buscador)
CREATE INDEX idx_productos_nombre ON productos(nombre);

-- 2) Filtrar rápido productos por categoría
CREATE INDEX idx_productos_categoria ON productos(id_categoria);

-- 3) Encontrar rápido los pedidos de un cliente específico
CREATE INDEX idx_pedidos_cliente ON pedidos(id_cliente);

-- 4) Encontrar rápido los pedidos de una sede específica
CREATE INDEX idx_pedidos_sede ON pedidos(id_sede);

-- 5) Filtrar pedidos por estado (pendiente/completado/cancelado)
CREATE INDEX idx_pedidos_estado ON pedidos(estado);

-- 6) Encontrar rápido el detalle de un pedido específico
CREATE INDEX idx_detalle_pedido ON detalle_pedido(id_pedido);

-- 7) Encontrar rápido en qué pedidos aparece un producto
CREATE INDEX idx_detalle_producto ON detalle_pedido(id_producto);

-- 8) Buscar rápido clientes por nombre
CREATE INDEX idx_clientes_nombre ON clientes(nombre);

-- 9) Revisar rápido el historial de cambios de precio de un producto
CREATE INDEX idx_auditoria_producto ON auditoria_precios(id_producto);

-- 10) Revisar rápido el historial de bajo stock de un producto
CREATE INDEX idx_log_stock_producto ON log_stock_bajo(id_producto);


-- ---------------------------------------------------------------------
-- Cómo comprobar que un índice se está usando:
-- Usa EXPLAIN antes de una consulta para ver si MySQL eligió el índice.
-- ---------------------------------------------------------------------
-- EXPLAIN SELECT * FROM productos WHERE nombre = 'Agua Pura 600ml';
-- EXPLAIN SELECT * FROM pedidos WHERE id_cliente = 1;
