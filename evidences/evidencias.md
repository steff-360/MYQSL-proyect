# Evidencias de Ejecución

Estos son los resultados **exactos** que deberías obtener al ejecutar
los scripts en el orden indicado en el `README.md`, calculados a mano
a partir de los datos reales de `database/dml/data.sql` (no son
valores inventados: cualquiera puede recalcularlos sumando las
cantidades y precios de ese archivo).

> Nota: los ejemplos de `CALL sp_comprar(...)` dentro de
> `transactions/transactions.sql` quedaron **comentados** a propósito,
> para que el estado de la base de datos después de ejecutar todos los
> scripts sea siempre el mismo y estas evidencias sean reproducibles.
> Si los descomentas y los ejecutas, los números de abajo cambiarán
> (se crearía un pedido nuevo y bajaría el stock del producto 1).

---

## 1. Estado de `pedidos` después de `data.sql`

| id_pedido | cliente | sede | estado | total |
|---|---|---|---|---|
| 1 | Tienda La Esquina | Sede Central | completado | **145.00** |
| 2 | Minimarket El Ahorro | Sede Mixco | completado | **146.00** |
| 3 | Restaurante Sabor Chapin | Sede Villa Nueva | pendiente | **157.50** |

Cálculo:
- Pedido 1: 10 × 6.50 (gaseosa cola) + 20 × 4.00 (agua pura) = 65.00 + 80.00 = **145.00**
- Pedido 2: 5 × 14.00 (gaseosa cola 2L) + 8 × 9.50 (jugo naranja) = 70.00 + 76.00 = **146.00**
- Pedido 3: 15 × 6.50 (gaseosa naranja) + 10 × 6.00 (agua mineral) = 97.50 + 60.00 = **157.50**

---

## 2. `vista_resumen_pedidos_por_sede`

| sede | total_pedidos | total_vendido |
|---|---|---|
| Sede Central | 1 | 145.00 |
| Sede Mixco | 1 | 146.00 |
| Sede Villa Nueva | 1 | **0.00** |

La Sede Villa Nueva muestra `0.00` en vendido porque su único pedido
(#3) está en estado `pendiente`, y la vista solo suma pedidos
`completado`.

---

## 3. `vista_productos_bajo_stock`

**Resultado: 0 filas.**

Con el stock inicial de `data.sql` (antes de vender nada a través de
`sp_comprar`), ningún producto está en o por debajo de su
`stock_minimo`:

| producto | stock | stock_minimo | ¿bajo stock? |
|---|---|---|---|
| Gaseosa Cola 600ml | 120 | 20 | No |
| Gaseosa Naranja 600ml | 80 | 20 | No |
| Gaseosa Cola 2L | 50 | 15 | No |
| Agua Pura 600ml | 200 | 30 | No |
| Agua Mineral 1L | 90 | 20 | No |
| Jugo de Naranja 1L | 40 | 10 | No |
| Jugo de Manzana 1L | 35 | 10 | No |
| Energizante 250ml | 25 | 10 | No |

Esta vista deja de estar vacía en cuanto se vende suficiente de algún
producto (por ejemplo, si descomentas y corres los ejemplos de
`sp_comprar`, o insertas más pedidos).

---

## 4. `vista_clientes_activos`

| cliente | pedidos_completados | total_comprado | segmento |
|---|---|---|---|
| Tienda La Esquina | 1 | 145.00 | Ocasional |
| Minimarket El Ahorro | 1 | 146.00 | Ocasional |
| Restaurante Sabor Chapin | 0 | 0.00 | Sin compras |
| Cafetería Central | 0 | 0.00 | Sin compras |

"Restaurante Sabor Chapin" aparece con 0 pedidos completados porque
su único pedido (#3) sigue `pendiente`. "Cafetería Central" no tiene
ningún pedido registrado en `data.sql`.

---

## 5. Funciones

| Llamada | Resultado |
|---|---|
| `fn_calcular_total_con_iva(100.00)` | **112.00** |
| `fn_validar_stock(1, 5)` (producto 1 tiene 120 en stock) | **1** (TRUE) |
| `fn_validar_stock(8, 999)` (producto 8 tiene 25 en stock) | **0** (FALSE) |

---

## 6. Triggers (prueba manual)

Insertar una fila en `detalle_pedido` para el producto 4 (Agua Pura
600ml, stock inicial 200):

```sql
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (1, 4, 3, 4.00);
SELECT stock FROM productos WHERE id_producto = 4;
```
**Resultado esperado:** `197` (200 − 3).

Cambiar el precio del producto 1 (Gaseosa Cola 600ml, precio inicial 6.50):

```sql
UPDATE productos SET precio = 7.00 WHERE id_producto = 1;
SELECT precio_anterior, precio_nuevo FROM auditoria_precios WHERE id_producto = 1;
```
**Resultado esperado:** una fila con `precio_anterior = 6.50` y `precio_nuevo = 7.00`.

---

## 7. `sp_comprar` (prueba manual)

Descomentando el primer ejemplo en `transactions/transactions.sql`:
```sql
CALL sp_comprar(1, 1, 2, 1, 5, @resultado);
SELECT @resultado;
```
**Resultado esperado:** `OK: compra registrada con el número de pedido 4.`
(será el pedido número 4 porque ya existen 3 en `data.sql`).
El stock del producto 1 baja de 120 a 115.

Segundo ejemplo (cantidad mayor al stock disponible):
```sql
CALL sp_comprar(1, 1, 2, 8, 99999, @resultado2);
SELECT @resultado2;
```
**Resultado esperado:** `ERROR: no hay stock suficiente para esa cantidad.`
No se crea pedido ni se modifica ningún stock (gracias al `ROLLBACK`).
