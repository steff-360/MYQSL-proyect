-- ============================================================
-- Gaseosas del Valle S.A. Stefani
-- Script: database.sql
-- Descripción: Creación de la base de datos, tablas y relaciones
-- ============================================================

DROP DATABASE IF EXISTS gaseosas_del_valle;
CREATE DATABASE gaseosas_del_valle
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gaseosas_del_valle;

-- ------------------------------------------------------------
-- Tabla: sedes
-- ------------------------------------------------------------
CREATE TABLE sedes (
    id_sede INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sede VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(150) NOT NULL,
    capacidad_almacenamiento INT NOT NULL,
    encargado VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabla: productos
-- ------------------------------------------------------------
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    volumen_ml INT NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo INT NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabla: clientes
-- ------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    identificacion VARCHAR(30) NOT NULL UNIQUE,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    correo_electronico VARCHAR(120)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabla: pedidos
-- (1 sede -> N pedidos, 1 cliente -> N pedidos)
-- ------------------------------------------------------------
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INT NOT NULL,
    id_sede INT NOT NULL,
    total_sin_iva DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_con_iva DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pedidos_sede FOREIGN KEY (id_sede)
        REFERENCES sedes(id_sede)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabla intermedia: detalle_pedido
-- (relación N–N entre pedidos y productos)
-- ------------------------------------------------------------
CREATE TABLE detalle_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedidos(id_pedido)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Tabla: auditoria_precios
-- Registra cada cambio de precio en productos
-- ------------------------------------------------------------
CREATE TABLE auditoria_precios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Índices adicionales para búsquedas frecuentes
-- ------------------------------------------------------------
CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_clientes_nombre ON clientes(nombre_completo);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

-- Sedes
INSERT INTO sedes (nombre_sede, ubicacion, capacidad_almacenamiento, encargado) VALUES
('Sede Girón Centro', 'Girón, Santander', 5000, 'Carlos Ramírez'),
('Sede Bucaramanga', 'Bucaramanga, Santander', 8000, 'María Torres'),
('Sede Piedecuesta', 'Piedecuesta, Santander', 3000, 'Andrés Gómez');

-- Productos
INSERT INTO productos (nombre, categoria, precio, volumen_ml, stock_actual, stock_minimo) VALUES
('Cola Clásica 350ml', 'Gaseosa Cola', 2200.00, 350, 500, 100),
('Cola Clásica 1.5L', 'Gaseosa Cola', 5800.00, 1500, 300, 80),
('Naranja Soda 350ml', 'Gaseosa Sabores', 2200.00, 350, 250, 100),
('Limonada Soda 350ml', 'Gaseosa Sabores', 2200.00, 350, 90, 100),
('Agua Tónica 350ml', 'Mixers', 2500.00, 350, 150, 50),
('Cola Zero 350ml', 'Gaseosa Cola', 2300.00, 350, 60, 100),
('Manzana Soda 2L', 'Gaseosa Sabores', 7200.00, 2000, 120, 40),
('Agua Saborizada 500ml', 'Agua Saborizada', 2600.00, 500, 400, 100);

-- Clientes
INSERT INTO clientes (nombre_completo, identificacion, direccion, telefono, correo_electronico) VALUES
('Tienda La Esquina', '900123456-1', 'Cra 10 #5-20, Girón', '3011234567', 'laesquina@correo.com'),
('Supermercado El Ahorro', '900654321-2', 'Calle 45 #12-30, Bucaramanga', '3029876543', 'elahorro@correo.com'),
('Restaurante Sabor Santandereano', '900789456-3', 'Cra 27 #33-10, Bucaramanga', '3037654321', 'saborsantandereano@correo.com'),
('Minimercado Piedecuesta', '900321654-4', 'Calle 8 #9-15, Piedecuesta', '3045551234', 'minipiedecuesta@correo.com'),
('Distribuciones JR', '900147258-5', 'Cra 15 #20-40, Girón', '3056667788', 'distribucionesjr@correo.com');

-- Pedidos (totales se recalcularán mediante la función/triggers)
INSERT INTO pedidos (fecha_pedido, id_cliente, id_sede, total_sin_iva, total_con_iva) VALUES
('2026-06-05 09:15:00', 1, 1, 0, 0),
('2026-06-10 14:30:00', 2, 2, 0, 0),
('2026-06-18 11:00:00', 3, 2, 0, 0),
('2026-07-02 16:45:00', 4, 3, 0, 0),
('2026-07-15 10:20:00', 1, 1, 0, 0);

-- Detalle de pedidos (esto dispara tr_actualizar_stock)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, subtotal) VALUES
(1, 1, 20, 20 * 2200.00),
(1, 3, 10, 10 * 2200.00),
(2, 2, 15, 15 * 5800.00),
(2, 5, 8, 8 * 2500.00),
(3, 7, 5, 5 * 7200.00),
(4, 8, 30, 30 * 2600.00),
(5, 1, 12, 12 * 2200.00),
(5, 6, 6, 6 * 2300.00);

-- Recalcular totales de pedidos existentes con la función de negocio
-- (se ejecuta después de crear functions.sql, ver README)