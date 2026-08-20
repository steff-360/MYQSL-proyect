# Base de Datos - Distribuidora de Gaseosas del Valle S.A.

## Introducción

Este proyecto contiene la implementación de una base de datos en
MySQL para gestionar las operaciones de una empresa distribuidora de
bebidas. El diseño abarca desde la gestión de inventario y ventas
hasta la automatización de procesos de negocio mediante funciones,
triggers y eventos.

Está construido y comentado pensando en alguien que **apenas está
aprendiendo bases de datos**: cada archivo explica, en comentarios,
qué hace cada bloque y por qué.

## Estructura del proyecto

```
├── database/
│   ├── ddl/
│   │   └── schema.sql              # (DDL) Estructura de tablas y relaciones
│   ├── dml/
│   │   └── data.sql                # (DML) Inserción de datos de prueba
│   └── dql/
│       └── views_and_queries.sql   # (DQL) Vistas y consultas
├── docs/
│   ├── requirements.md             # Documentación de requerimientos
│   ├── normalizacion.md            # Justificación de 1FN, 2FN y 3FN
│   └── erd.svg                     # Diagrama Entidad-Relación (ábrelo en el navegador)
├── evidences/
│   └── evidencias.md               # Resultados reales ya calculados de cada prueba
├── events/
│   └── events.sql                  # Evento programado (revisión de stock)
├── functions/
│   └── functions.sql               # Funciones almacenadas
├── indexes/
│   └── indexes.sql                 # Creación de índices
├── transactions/
│   └── transactions.sql            # Procedimiento transaccional (compra)
├── triggers/
│   └── triggers.sql                # Triggers de stock y auditoría
├── users/
│   └── users.sql                   # Usuarios de MySQL y sus permisos
├── results.md                      # Cómo probar cada componente (pasos)
└── README.md                       # Este archivo
```

## Orden de ejecución recomendado

1. `database/ddl/schema.sql` — crea la base de datos y las tablas
2. `database/dml/data.sql` — llena las tablas con datos de ejemplo
3. `functions/functions.sql` — crea las funciones
4. `triggers/triggers.sql` — crea los triggers
5. `transactions/transactions.sql` — crea el procedimiento `sp_comprar`
6. `events/events.sql` — crea el evento programado
7. `database/dql/views_and_queries.sql` — crea las vistas
8. `indexes/indexes.sql` — crea los índices
9. `users/users.sql` — crea usuarios de MySQL con permisos (opcional)

## Componentes implementados

### Funciones
- **`fn_calcular_total_con_iva`**: calcula el total de un pedido
  incluyendo el 12% de IVA.
- **`fn_validar_stock`**: verifica si hay suficiente stock de un
  producto antes de una venta.

### Triggers
- **`tr_after_actualizar_stock`**: descuenta el stock de un producto
  automáticamente después de agregarlo a una venta.
- **`tr_after_auditar_cambio_precio`**: registra cualquier
  modificación en el precio de un producto en una tabla de auditoría.

### Transacciones (procedimientos almacenados)
- **`sp_comprar`**: encapsula todo el proceso de compra (validar
  stock, crear pedido, insertar detalle, actualizar total) en una
  transacción atómica, con `ROLLBACK` automático si algo falla.

### Vistas
- **`vista_resumen_pedidos_por_sede`**: resumen de ventas y pedidos
  por cada sede.
- **`vista_productos_bajo_stock`**: productos que necesitan
  reabastecimiento urgente.
- **`vista_clientes_activos`**: segmentación de clientes según su
  historial de compras.

### Eventos
- **`evento_revisar_stock`**: tarea programada diaria que registra
  productos con bajo inventario en `log_stock_bajo`.

### Índices
10 índices sobre las columnas más consultadas (búsquedas por nombre,
filtros por sede/cliente/estado, y llaves foráneas usadas en JOINs).

### Usuarios
4 roles de MySQL con permisos distintos: `admin_valle`,
`vendedor_valle`, `bodeguero_valle` y `reportes_valle` (solo lectura).

## Diagrama y normalización

- **Diagrama Entidad-Relación:** `docs/erd.svg` (ábrelo con doble
  clic o arrastrándolo a un navegador; se ve igual de bien en GitHub,
  que renderiza archivos `.svg` automáticamente).
- **Normalización:** `docs/normalizacion.md` explica, tabla por
  tabla, por qué el diseño cumple 1FN, 2FN y 3FN.

## Requerimientos y resultados

- Para ver el detalle de los requerimientos funcionales y no
  funcionales, consulta `docs/requirements.md`.
- Para ver **cómo** probar cada componente, consulta `results.md`.
- Para ver los **resultados exactos ya calculados** (qué debería
  mostrar cada consulta, con números reales), consulta
  `evidences/evidencias.md`.

**Autora Stefani Sánchez**