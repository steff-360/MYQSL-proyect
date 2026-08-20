# Requerimientos del Proyecto Stefani

## Distribuidora de Gaseosas del Valle S.A.

### 1. Contexto

La Distribuidora de Gaseosas del Valle S.A. es una empresa que vende
bebidas (gaseosas, aguas, jugos y energizantes) a tiendas, minimarkets
y restaurantes, a través de varias sedes/sucursales.

Este proyecto diseña e implementa, desde cero, la base de datos
necesaria para gestionar sus operaciones básicas.

### 2. Requerimientos funcionales

1. El sistema debe permitir registrar **sedes** de la empresa.
2. El sistema debe permitir registrar **usuarios** internos
   (administradores, vendedores, bodegueros) asociados a una sede.
3. El sistema debe permitir registrar **productos**, organizados por
   **categoría**, con precio y stock actual.
4. El sistema debe permitir registrar **clientes** (tiendas,
   minimarkets, restaurantes).
5. El sistema debe permitir registrar **pedidos** (ventas), cada uno
   con uno o varios productos (**detalle de pedido**).
6. El sistema debe **descontar el stock automáticamente** cuando se
   agrega un producto a un pedido.
7. El sistema debe **auditar los cambios de precio** de los productos:
   guardar cuándo cambió, el precio anterior y el nuevo.
8. El sistema debe poder **calcular el total de un pedido con IVA
   incluido** (12%).
9. El sistema debe poder **validar si hay stock suficiente** antes de
   confirmar una venta.
10. El sistema debe **revisar diariamente**, de forma automática, qué
    productos están en stock bajo (igual o menor a su stock mínimo) y
    dejar un registro de eso.
11. El sistema debe generar reportes de:
    - Resumen de pedidos y ventas por sede.
    - Productos con stock bajo.
    - Segmentación de clientes según su historial de compras.
12. El sistema debe controlar el acceso según el rol del usuario
    (administrador, vendedor, bodeguero, solo lectura para reportes).

### 3. Requerimientos no funcionales

1. La base de datos debe estar **normalizada** (evitar datos
   duplicados o inconsistentes).
2. Las operaciones de venta deben ser **atómicas**: si algo falla a
   la mitad, no debe quedar información a medias (se usa una
   transacción con `ROLLBACK`).
3. Las consultas más frecuentes deben tener **índices** para que sean
   rápidas incluso con muchos datos.
4. El motor de base de datos utilizado es **MySQL**.

### 4. Diccionario de datos (resumen)

| Tabla              | Descripción                                              |
|--------------------|-----------------------------------------------------------|
| `sedes`            | Sucursales de la distribuidora                            |
| `usuarios`         | Personas que usan el sistema, con un rol y una sede        |
| `categorias`       | Clasificación de los productos                             |
| `productos`        | Catálogo de bebidas: nombre, precio, stock                 |
| `clientes`         | Negocios que compran a la distribuidora                    |
| `pedidos`          | Cabecera de cada venta                                     |
| `detalle_pedido`   | Productos y cantidades de cada pedido                      |
| `auditoria_precios`| Historial de cambios de precio (llenado por trigger)       |
| `log_stock_bajo`   | Historial de revisiones de bajo stock (llenado por evento) |

### 5. Reglas de negocio clave

- El IVA aplicado es de **12%**.
- Un producto tiene un **stock mínimo**; si el stock llega a ese
  nivel o menos, se considera "bajo stock".
- Un cliente es **"Frecuente"** si tiene 2 o más pedidos completados,
  **"Ocasional"** si tiene exactamente 1, y **"Sin compras"** si no
  tiene ninguno.
- No se puede vender más cantidad de un producto de la que hay en
  stock.
