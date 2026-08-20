# Examen SQL - Gaseosas del Valle S.A.

## Descripción

Este proyecto contiene la solución del examen correspondiente al módulo de **Clientes y Pedidos** de la empresa **Gaseosas del Valle S.A.**

El objetivo es crear consultas y elementos de MySQL que permitan analizar la actividad de los clientes y los pedidos realizados, además de registrar automáticamente los nuevos pedidos para mantener un control de auditoría.

## Base de datos utilizada

El ejercicio utiliza las tablas:

* `clientes`
* `pedidos`

También se crea la tabla:

* `auditoria_pedidos`

La tabla `auditoria_pedidos` se utiliza para guardar automáticamente la información de los nuevos pedidos registrados.

---

## Ejercicios realizados

### 1. Función `total_pedidos_cliente_periodo`

La función recibe tres parámetros:

* ID del cliente.
* Fecha de inicio.
* Fecha final.

Su función es buscar los pedidos realizados por el cliente dentro del período indicado y sumar el valor total de esos pedidos.

Si el cliente no tiene pedidos durante el período, la función devuelve `0`.

Ejemplo de uso:

```sql
SELECT total_pedidos_cliente_periodo(
    1,
    '2026-01-01',
    '2026-12-31'
) AS total_comprado;
```

---

### 2. Vista `vista_clientes_activos`

La vista muestra los clientes que han realizado al menos un pedido durante los últimos 90 días.

La información mostrada es:

* Nombre del cliente.
* Número total de pedidos.
* Valor total comprado.

Para obtener esta información se utiliza un `INNER JOIN` entre las tablas `clientes` y `pedidos`.

También se utilizan las funciones:

* `COUNT()` para contar los pedidos.
* `SUM()` para calcular el valor total comprado.

Ejemplo de consulta:

```sql
SELECT *
FROM vista_clientes_activos;
```

---

### 3. Cinco clientes con mayor valor de pedidos

Se realizó una consulta para obtener los cinco clientes que han realizado pedidos por el mayor valor durante el año actual.

La consulta muestra:

* Nombre del cliente.
* Cantidad de pedidos.
* Total comprado.

Se utiliza:

```sql
ORDER BY total_comprado DESC
```

para ordenar los resultados de mayor a menor.

También se utiliza:

```sql
LIMIT 5
```

para mostrar únicamente los cinco primeros clientes.

---

### 4. Trigger `registrar_nuevo_pedido_trigger`

Se creó la tabla `auditoria_pedidos` para almacenar información de los nuevos pedidos.

La tabla contiene:

* `id_pedido`
* `id_cliente`
* `fecha_registro`
* `total_pedido`
* `usuario_responsable`

El trigger:

```text
registrar_nuevo_pedido_trigger
```

se ejecuta automáticamente después de insertar un nuevo pedido en la tabla `pedidos`.

De esta manera, cada nuevo pedido queda registrado automáticamente en la tabla de auditoría.

Para consultar los registros:

```sql
SELECT *
FROM auditoria_pedidos;
```

---

## Estructura del repositorio

```text
├── examen.sql
└── examen.md
```

### `examen.sql`

Contiene todos los ejercicios solicitados en el examen:

1. Función `total_pedidos_cliente_periodo`.
2. Vista `vista_clientes_activos`.
3. Consulta de los cinco mejores clientes del año.
4. Tabla `auditoria_pedidos`.
5. Trigger `registrar_nuevo_pedido_trigger`.

### `examen.md`

Contiene una descripción del proyecto, explicación de cada ejercicio, ejemplos para realizar las pruebas y la consulta agregada como punto extra.

---

## Consulta adicional

Como punto adicional se agregó una consulta para conocer el promedio de compra de cada cliente.

Esta consulta utiliza las mismas tablas del ejercicio y permite obtener información adicional sobre el comportamiento de compra de los clientes.

Muestra:

* Nombre del cliente.
* Cantidad de pedidos.
* Promedio de compra.

Consulta:

```sql
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
```

Este punto es adicional a los cuatro ejercicios solicitados y se mantiene relacionado directamente con el módulo de clientes y pedidos.

---

## Cómo ejecutar el proyecto

### Paso 1. Tener la base de datos creada

Antes de ejecutar el examen, debe existir la base de datos utilizada por el proyecto y las tablas `clientes` y `pedidos`.

### Paso 2. Abrir MySQL Workbench

Abrir el archivo:

```text
examen.sql
```

### Paso 3. Seleccionar la base de datos

El script utiliza:

```sql
USE distribuidora_de_gaseosas_del_valle;
```

### Paso 4. Ejecutar el script

Ejecutar el contenido de `examen.sql` en MySQL Workbench.

El script creará la función, la vista, la tabla de auditoría y el trigger, además de ejecutar la consulta solicitada.

---

## Pruebas

### Probar la función

```sql
SELECT total_pedidos_cliente_periodo(
    1,
    '2026-01-01',
    '2026-12-31'
) AS total_comprado;
```

### Probar la vista

```sql
SELECT *
FROM vista_clientes_activos;
```

### Probar la auditoría

Después de insertar un nuevo pedido:

```sql
SELECT *
FROM auditoria_pedidos
ORDER BY id_auditoria DESC;
```

Si el trigger funciona correctamente, el nuevo pedido aparecerá registrado en la tabla de auditoría.

### Consulta adicional

La consulta del promedio de compra se encuentra al final del archivo `examen.sql`.

Al ejecutarla se obtiene una lista de clientes ordenada de mayor a menor según su promedio de compra.

---


## Resultado esperado

Al finalizar, el proyecto debe permitir:

* Consultar el total comprado por un cliente dentro de un período.
* Identificar clientes activos durante los últimos 90 días.
* Obtener los cinco clientes con mayor valor de pedidos durante el año actual.
* Registrar automáticamente cada nuevo pedido en una tabla de auditoría.
* Consultar el promedio de compra de los clientes como punto adicional.

Con esto se cumplen los requerimientos establecidos para el ejercicio de **Reporte de Clientes y Pedidos** y se agrega una consulta adicional como punto extra.
