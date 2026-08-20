-- =====================================================================
--  DATA.sql Stefani
--  Datos de prueba (DML) para la Distribuidora de Gaseosas del Valle
--
--  IMPORTANTE: ejecuta primero database/ddl/schema.sql, porque estas
--  instrucciones necesitan que las tablas ya existan.
-- =====================================================================

USE distribuidora_valle;

-- ---------------------------------------------------------------------
-- SEDES
-- ---------------------------------------------------------------------
INSERT INTO sedes (nombre, direccion, telefono) VALUES
('Sede Central',      'Zona 1, Ciudad de Guatemala', '2222-1111'),
('Sede Mixco',        'Zona 4, Mixco',                '2222-2222'),
('Sede Villa Nueva',  'Zona 2, Villa Nueva',           '2222-3333');


-- ---------------------------------------------------------------------
-- USUARIOS
-- Nota: 'contrasena_hash' aquí es un valor de ejemplo, NO una
-- contraseña real ni un hash de verdad. En un sistema real se genera
-- con una función de hash (bcrypt, etc.) desde el backend.
-- ---------------------------------------------------------------------
INSERT INTO usuarios (nombre, usuario, contrasena_hash, rol, id_sede) VALUES
('Ana Pérez',      'ana.perez',      'HASH_EJEMPLO_1', 'administrador', 1),
('Luis Gómez',     'luis.gomez',     'HASH_EJEMPLO_2', 'vendedor',      1),
('Carla Ramírez',  'carla.ramirez',  'HASH_EJEMPLO_3', 'vendedor',      2),
('Diego Morales',  'diego.morales',  'HASH_EJEMPLO_4', 'bodeguero',     3);


-- ---------------------------------------------------------------------
-- CATEGORIAS
-- ---------------------------------------------------------------------
INSERT INTO categorias (nombre) VALUES
('Gaseosas'),
('Aguas'),
('Jugos'),
('Energizantes');


-- ---------------------------------------------------------------------
-- PRODUCTOS
-- ---------------------------------------------------------------------
INSERT INTO productos (nombre, id_categoria, precio, stock, stock_minimo) VALUES
('Gaseosa Cola 600ml',        1, 6.50,  120, 20),
('Gaseosa Naranja 600ml',     1, 6.50,   80, 20),
('Gaseosa Cola 2L',           1, 14.00,  50, 15),
('Agua Pura 600ml',           2, 4.00,  200, 30),
('Agua Mineral 1L',           2, 6.00,   90, 20),
('Jugo de Naranja 1L',        3, 9.50,   40,  10),
('Jugo de Manzana 1L',        3, 9.50,   35,  10),
('Energizante 250ml',         4, 12.00,  25,  10);


-- ---------------------------------------------------------------------
-- CLIENTES
-- ---------------------------------------------------------------------
INSERT INTO clientes (nombre, telefono, email, direccion) VALUES
('Tienda La Esquina',       '5555-0001', 'laesquina@correo.com',   'Zona 1, Guatemala'),
('Minimarket El Ahorro',    '5555-0002', 'elahorro@correo.com',    'Zona 4, Mixco'),
('Restaurante Sabor Chapin','5555-0003', 'saborchapin@correo.com', 'Zona 2, Villa Nueva'),
('Cafetería Central',       '5555-0004', 'cafeteriacentral@correo.com', 'Zona 1, Guatemala');


-- ---------------------------------------------------------------------
-- PEDIDOS + DETALLE_PEDIDO
-- Creamos 3 pedidos de ejemplo, ya completos, con su detalle.
-- El "total" del pedido se recalcula abajo sumando los subtotales.
-- ---------------------------------------------------------------------

-- Pedido 1: Tienda La Esquina compra en la Sede Central, atendido por Luis
INSERT INTO pedidos (id_cliente, id_sede, id_usuario, estado, total)
VALUES (1, 1, 2, 'completado', 0);

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 10, 6.50),   -- 10 gaseosas cola 600ml
(1, 4, 20, 4.00);   -- 20 aguas puras 600ml

-- Pedido 2: Minimarket El Ahorro compra en Sede Mixco, atendido por Carla
INSERT INTO pedidos (id_cliente, id_sede, id_usuario, estado, total)
VALUES (2, 2, 3, 'completado', 0);

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(2, 3, 5, 14.00),   -- 5 gaseosas cola 2L
(2, 6, 8, 9.50);    -- 8 jugos de naranja

-- Pedido 3: Restaurante Sabor Chapin compra en Sede Villa Nueva, pendiente
INSERT INTO pedidos (id_cliente, id_sede, id_usuario, estado, total)
VALUES (3, 3, 4, 'pendiente', 0);

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(3, 2, 15, 6.50),   -- 15 gaseosas naranja 600ml
(3, 5, 10, 6.00);   -- 10 aguas minerales 1L

-- Actualizamos el total de cada pedido sumando los subtotales de su detalle.
-- (subtotal ya se calcula solo, porque es una columna GENERATED en la tabla)
UPDATE pedidos p
SET total = (
    SELECT SUM(d.subtotal)
    FROM detalle_pedido d
    WHERE d.id_pedido = p.id_pedido
);
