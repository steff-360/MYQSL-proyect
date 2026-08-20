-- =====================================================================
--  SCHEMA.sql ST
--  Base de Datos: Distribuidora de Gaseosas del Valle S.A.
--
--  Este archivo crea la base de datos y todas sus tablas.
--  Está comentado paso a paso porque este proyecto está pensado para
--  alguien que apenas está aprendiendo MySQL.
-- =====================================================================

-- Si ya existe una base de datos con este nombre, la eliminamos para
-- poder empezar limpio (útil mientras estás practicando).
DROP DATABASE IF EXISTS distribuidora_valle;

-- Creamos la base de datos y le decimos que use UTF-8 para poder
-- guardar tildes y ñ sin problemas.
CREATE DATABASE distribuidora_valle
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

-- A partir de aquí, todo lo que hagamos será dentro de esta base.
USE distribuidora_valle;


-- ---------------------------------------------------------------------
-- TABLA: sedes
-- Representa las sucursales/bodegas de la distribuidora.
-- ---------------------------------------------------------------------
CREATE TABLE sedes (
    id_sede      INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100)  NOT NULL,
    direccion    VARCHAR(200)  NOT NULL,
    telefono     VARCHAR(20),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ---------------------------------------------------------------------
-- TABLA: usuarios
-- Personas que usan el sistema (vendedores, administradores, etc.).
-- La contraseña NUNCA se guarda en texto plano en un sistema real;
-- aquí guardamos un "hash" simulado solo para fines de práctica.
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    usuario      VARCHAR(50)  NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol          ENUM('administrador', 'vendedor', 'bodeguero') NOT NULL DEFAULT 'vendedor',
    id_sede      INT,
    activo       BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_sede
        FOREIGN KEY (id_sede) REFERENCES sedes(id_sede)
        ON DELETE SET NULL
);


-- ---------------------------------------------------------------------
-- TABLA: categorias
-- Para clasificar los productos (gaseosas, aguas, jugos, etc.).
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(60) NOT NULL UNIQUE
);


-- ---------------------------------------------------------------------
-- TABLA: productos
-- Catálogo de productos que vende la distribuidora.
-- ---------------------------------------------------------------------
CREATE TABLE productos (
    id_producto  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(120) NOT NULL,
    id_categoria INT,
    precio       DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    stock        INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INT NOT NULL DEFAULT 10,
    activo       BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
        ON DELETE SET NULL
);


-- ---------------------------------------------------------------------
-- TABLA: clientes
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente   INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    telefono     VARCHAR(20),
    email        VARCHAR(120),
    direccion    VARCHAR(200),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ---------------------------------------------------------------------
-- TABLA: pedidos
-- La "cabecera" de una venta: quién compró, en qué sede, cuándo.
-- ---------------------------------------------------------------------
CREATE TABLE pedidos (
    id_pedido    INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente   INT NOT NULL,
    id_sede      INT NOT NULL,
    id_usuario   INT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado       ENUM('pendiente', 'completado', 'cancelado') NOT NULL DEFAULT 'pendiente',
    total        DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_pedidos_sede
        FOREIGN KEY (id_sede) REFERENCES sedes(id_sede),
    CONSTRAINT fk_pedidos_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);


-- ---------------------------------------------------------------------
-- TABLA: detalle_pedido
-- El "detalle" de cada venta: qué productos y cuántos.
-- Una tabla de pedidos puede tener muchas filas en detalle_pedido.
-- ---------------------------------------------------------------------
CREATE TABLE detalle_pedido (
    id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido        INT NOT NULL,
    id_producto      INT NOT NULL,
    cantidad         INT NOT NULL CHECK (cantidad > 0),
    precio_unitario  DECIMAL(10,2) NOT NULL,
    subtotal         DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


-- ---------------------------------------------------------------------
-- TABLA: auditoria_precios
-- Guarda un registro histórico cada vez que cambia el precio de un
-- producto. La llena automáticamente un TRIGGER (ver triggers/triggers.sql).
-- ---------------------------------------------------------------------
CREATE TABLE auditoria_precios (
    id_auditoria   INT AUTO_INCREMENT PRIMARY KEY,
    id_producto    INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    fecha_cambio    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


-- ---------------------------------------------------------------------
-- TABLA: log_stock_bajo
-- La llena automáticamente el EVENTO programado (ver events/events.sql)
-- cada vez que revisa qué productos tienen poco stock.
-- ---------------------------------------------------------------------
CREATE TABLE log_stock_bajo (
    id_log       INT AUTO_INCREMENT PRIMARY KEY,
    id_producto  INT NOT NULL,
    stock_actual INT NOT NULL,
    fecha_revision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
