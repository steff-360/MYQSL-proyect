# Resultados de Pruebas Por Stefani

Este archivo describe **cómo** probar cada componente del proyecto.
Para ver los **resultados exactos ya calculados** (tablas, totales,
valores esperados) a partir de los datos reales de `data.sql`,
consulta `evidences/evidencias.md`.

Ejecuta los scripts en este orden:

1. `database/ddl/schema.sql`
2. `database/dml/data.sql`
3. `functions/functions.sql`
4. `triggers/triggers.sql`
5. `transactions/transactions.sql`
6. `events/events.sql`
7. `database/dql/views_and_queries.sql`
8. `indexes/indexes.sql`
9. `users/users.sql` (opcional, requiere permisos de administrador en MySQL)

---

## 1. Funciones

### `fn_calcular_total_con_iva(100.00)`
**Esperado:** `112.00`

### `fn_validar_stock(1, 5)`
Con los datos de prueba, el producto 1 tiene 120 en stock (los
pedidos de `data.sql` no descuentan stock porque se insertan antes
de que exista el trigger; ver `evidences/evidencias.md` para el
detalle completo).
**Esperado:** `1` (TRUE)

### `fn_validar_stock(8, 999)`
El producto 8 tiene solo 25 unidades en stock.
**Esperado:** `0` (FALSE)

---

## 2. Triggers

### `tr_after_actualizar_stock`
Al insertar una fila en `detalle_pedido`, el stock del producto
correspondiente en `productos` **debe bajar** exactamente en la
cantidad vendida.

**Prueba:**
```sql
SELECT stock FROM productos WHERE id_producto = 4; -- antes
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (1, 4, 3, 4.00);
SELECT stock FROM productos WHERE id_producto = 4; -- después: bajó en 3
```

### `tr_after_auditar_cambio_precio`
Al actualizar el precio de un producto, debe aparecer una fila nueva
en `auditoria_precios` con el precio anterior y el nuevo.

**Prueba:**
```sql
UPDATE productos SET precio = 7.00 WHERE id_producto = 1;
SELECT * FROM auditoria_precios WHERE id_producto = 1;
```
**Esperado:** una fila con `precio_anterior = 6.50` y `precio_nuevo = 7.00`.

---

## 3. Procedimiento transaccional (`sp_comprar`)

### Caso exitoso
```sql
CALL sp_comprar(1, 1, 2, 1, 5, @resultado);
SELECT @resultado;
```
**Esperado:** `OK: compra registrada con el número de pedido N.`
El stock del producto 1 baja en 5 y se crea un nuevo pedido completado.

### Caso de error (stock insuficiente)
```sql
CALL sp_comprar(1, 1, 2, 8, 99999, @resultado2);
SELECT @resultado2;
```
**Esperado:** `ERROR: no hay stock suficiente para esa cantidad.`
No se crea ningún pedido nuevo ni se modifica el stock (gracias al
`ROLLBACK`).

---

## 4. Evento (`evento_revisar_stock`)

Como este evento corre una vez al día, para probarlo sin esperar se
puede ejecutar manualmente la misma lógica:
```sql
INSERT INTO log_stock_bajo (id_producto, stock_actual)
SELECT id_producto, stock FROM productos WHERE stock <= stock_minimo AND activo = TRUE;

SELECT * FROM log_stock_bajo;
```
**Esperado:** con el stock inicial de `data.sql`, ningún producto
está todavía en o por debajo de su stock mínimo, así que el resultado
son **0 filas**. Esto cambia en cuanto se vende suficiente de algún
producto (por ejemplo, ejecutando `sp_comprar` varias veces). El
detalle producto por producto está en `evidences/evidencias.md`.

---

## 5. Vistas

### `vista_resumen_pedidos_por_sede`
**Esperado:** 3 filas (una por sede), mostrando cuántos pedidos tiene
cada una y el total vendido en pedidos completados.

### `vista_productos_bajo_stock`
**Esperado:** lista de productos cuyo `stock <= stock_minimo`.

### `vista_clientes_activos`
**Esperado:** 4 filas (una por cliente), con su segmento:
"Frecuente", "Ocasional" o "Sin compras", según cuántos pedidos
completados tenga.

---

## 6. Índices

Para comprobar que un índice se usa, se puede correr `EXPLAIN` antes
de una consulta:
```sql
EXPLAIN SELECT * FROM productos WHERE nombre = 'Agua Pura 600ml';
```
**Esperado:** en la columna `key` del resultado debe aparecer
`idx_productos_nombre` en lugar de `NULL`.

---

## 7. Usuarios

```sql
SHOW GRANTS FOR 'vendedor_valle'@'localhost';
```
**Esperado:** una lista de permisos limitados (SELECT/INSERT/UPDATE
solo sobre las tablas relacionadas a ventas), sin permisos para borrar
tablas ni cambiar la estructura de la base.
