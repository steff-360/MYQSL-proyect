# Normalización de Datos

Este documento explica por qué el diseño de `distribuidora_valle`
cumple con la Primera, Segunda y Tercera Forma Normal (1FN, 2FN, 3FN).
La idea de "normalizar" es evitar que un mismo dato se repita en
varios lugares y que, si cambia, tengamos que actualizarlo en más de
un sitio (lo cual tarde o temprano genera inconsistencias).

## Primera Forma Normal (1FN)

**Regla:** cada columna debe guardar un solo valor (atómico), y no
debe haber grupos de columnas repetidas.

**Cómo se cumple aquí:**
- Ninguna columna guarda listas ni valores separados por comas. Por
  ejemplo, un pedido con varios productos **no** se guarda como una
  sola fila con "producto1, producto2, producto3" en una columna de
  `pedidos`. En vez de eso, cada producto de un pedido es una fila
  distinta en la tabla `detalle_pedido`.
- Cada tabla tiene una llave primaria (`PRIMARY KEY`) que identifica
  de forma única cada fila (`id_sede`, `id_producto`, `id_pedido`, etc.).

## Segunda Forma Normal (2FN)

**Regla:** además de cumplir 1FN, cada columna que no es llave debe
depender de **toda** la llave primaria (esto solo importa cuando la
llave primaria está compuesta por más de una columna).

**Cómo se cumple aquí:**
- Todas las tablas de este proyecto usan una llave primaria simple
  (una sola columna, tipo `id_x AUTO_INCREMENT`), así que no existe
  el riesgo de que una columna dependa solo de "una parte" de la
  llave.
- Un caso que vale la pena mirar de cerca es `detalle_pedido`: aunque
  conceptualmente depende de `id_pedido` **y** `id_producto` juntos,
  se le dio su propia llave primaria (`id_detalle`) y esos dos campos
  se manejan como llaves foráneas. El resto de columnas de esa tabla
  (`cantidad`, `precio_unitario`) sí dependen de la combinación
  pedido+producto de esa fila específica, no de una sola parte.

## Tercera Forma Normal (3FN)

**Regla:** además de cumplir 2FN, ninguna columna que no es llave
debe depender de otra columna que tampoco es llave (esto se conoce
como una "dependencia transitiva").

**Cómo se cumple aquí, con ejemplos concretos:**

- **`productos` no repite el nombre de la categoría.** En vez de
  tener una columna `categoria_nombre` dentro de `productos` (que se
  repetiría en cada producto de esa categoría), existe una tabla
  separada `categorias`, y `productos` solo guarda el
  `id_categoria` que apunta a ella. Si el nombre de una categoría
  cambia, se actualiza en un solo lugar.
- **`pedidos` no repite los datos del cliente ni de la sede.** No
  existen columnas como `nombre_cliente` o `direccion_sede` dentro de
  `pedidos`; en cambio, se guardan `id_cliente` e `id_sede`, que
  apuntan a las tablas `clientes` y `sedes`. Así, si un cliente
  cambia de teléfono, se corrige una sola vez en `clientes`.
- **`detalle_pedido` no repite el nombre ni la categoría del
  producto.** Solo guarda `id_producto` (llave foránea) y los datos
  que sí son propios de esa línea de venta: `cantidad` y
  `precio_unitario` (el precio se copia en el momento de la venta a
  propósito, para que si el precio del producto cambia después, no
  se altere el historial de ventas ya realizadas — eso es una
  decisión de diseño, no una violación de 3FN, porque
  `precio_unitario` depende de la venta específica, no del producto
  en general).
- **`auditoria_precios` y `log_stock_bajo` no duplican información
  del producto** (como su nombre o categoría): solo guardan
  `id_producto` y los datos propios de cada evento (el cambio de
  precio, o el stock que tenía en ese momento).

## Resumen

| Tabla              | 1FN | 2FN | 3FN | Nota |
|---------------------|:---:|:---:|:---:|------|
| `sedes`              | ✔ | ✔ | ✔ | Sin dependencias transitivas |
| `usuarios`           | ✔ | ✔ | ✔ | `id_sede` como FK, no se repiten datos de sede |
| `categorias`         | ✔ | ✔ | ✔ | Tabla simple de catálogo |
| `productos`          | ✔ | ✔ | ✔ | `id_categoria` como FK |
| `clientes`           | ✔ | ✔ | ✔ | Sin dependencias transitivas |
| `pedidos`            | ✔ | ✔ | ✔ | `id_cliente`, `id_sede`, `id_usuario` como FK |
| `detalle_pedido`     | ✔ | ✔ | ✔ | `precio_unitario` es un dato histórico de la venta, no del producto |
| `auditoria_precios`  | ✔ | ✔ | ✔ | Solo guarda el cambio, no datos del producto |
| `log_stock_bajo`     | ✔ | ✔ | ✔ | Solo guarda la revisión, no datos del producto |
