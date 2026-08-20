-- =====================================================================
--  USERS.sql
--  Usuarios de MySQL (a nivel de servidor) para la Distribuidora
--
--  OJO: esto es distinto a la tabla "usuarios" que creamos en el
--  schema. Aquí estamos creando cuentas del propio motor MySQL, con
--  permisos distintos según el rol, para que no todo el mundo pueda
--  hacer lo mismo dentro de la base de datos.
--
--  Cambia las contraseñas de ejemplo antes de usar esto en un entorno
--  real; aquí son solo ilustrativas para fines de práctica.
-- =====================================================================

-- ---------------------------------------------------------------------
-- USUARIO 1: admin_valle
-- Rol: administrador. Puede hacer prácticamente todo dentro de la base.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'admin_valle'@'localhost' IDENTIFIED BY 'Admin_2024!';
GRANT ALL PRIVILEGES ON distribuidora_valle.* TO 'admin_valle'@'localhost';


-- ---------------------------------------------------------------------
-- USUARIO 2: vendedor_valle
-- Rol: vendedor. Puede leer casi todo y registrar pedidos/detalle,
-- pero no puede borrar tablas ni cambiar la estructura de la base.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'vendedor_valle'@'localhost' IDENTIFIED BY 'Vende_2024!';
GRANT SELECT, INSERT, UPDATE ON distribuidora_valle.pedidos TO 'vendedor_valle'@'localhost';
GRANT SELECT, INSERT ON distribuidora_valle.detalle_pedido TO 'vendedor_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.productos TO 'vendedor_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.clientes TO 'vendedor_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.vista_resumen_pedidos_por_sede TO 'vendedor_valle'@'localhost';
GRANT EXECUTE ON PROCEDURE distribuidora_valle.sp_comprar TO 'vendedor_valle'@'localhost';
GRANT EXECUTE ON FUNCTION distribuidora_valle.fn_validar_stock TO 'vendedor_valle'@'localhost';
GRANT EXECUTE ON FUNCTION distribuidora_valle.fn_calcular_total_con_iva TO 'vendedor_valle'@'localhost';


-- ---------------------------------------------------------------------
-- USUARIO 3: bodeguero_valle
-- Rol: bodeguero. Se encarga del inventario: puede ver y actualizar
-- stock de productos, y consultar productos con bajo stock.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'bodeguero_valle'@'localhost' IDENTIFIED BY 'Bodega_2024!';
GRANT SELECT, UPDATE (stock) ON distribuidora_valle.productos TO 'bodeguero_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.vista_productos_bajo_stock TO 'bodeguero_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.log_stock_bajo TO 'bodeguero_valle'@'localhost';


-- ---------------------------------------------------------------------
-- USUARIO 4: reportes_valle
-- Rol: solo lectura, pensado para alguien que solo genera reportes
-- (por ejemplo, gerencia) y no debe poder modificar nada.
-- ---------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'reportes_valle'@'localhost' IDENTIFIED BY 'Reporte_2024!';
GRANT SELECT ON distribuidora_valle.vista_resumen_pedidos_por_sede TO 'reportes_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.vista_productos_bajo_stock TO 'reportes_valle'@'localhost';
GRANT SELECT ON distribuidora_valle.vista_clientes_activos TO 'reportes_valle'@'localhost';


-- Aplicamos los cambios de permisos inmediatamente.
FLUSH PRIVILEGES;


-- ---------------------------------------------------------------------
-- Para comprobar los permisos de un usuario:
-- ---------------------------------------------------------------------
-- SHOW GRANTS FOR 'vendedor_valle'@'localhost';
