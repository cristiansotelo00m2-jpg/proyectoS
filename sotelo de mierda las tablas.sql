-- ==============================================================================
-- SCRIPT DE MIGRACIÓN COMPLETA PARA AIVEN CLOUD (MySQL)
-- Proyecto: EcoGreen / Formulario
-- Descripción: Creación de tablas con claves primarias, autoincrementables, 
--              claves foráneas e inserción ordenada de datos existentes.
-- Compatible con Aiven Cloud (Sin errores de DEFINER ni conflictos de FK).
-- ==============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 1. LIMPIEZA DE TABLAS Y VISTAS PREVIAS
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vista_reporte_ventas;
DROP VIEW IF EXISTS vista_productos_stock_bajo;
DROP VIEW IF EXISTS vista_usuarios_publico;

DROP TABLE IF EXISTS devoluciones;
DROP TABLE IF EXISTS facturas;
DROP TABLE IF EXISTS contactanos;
DROP TABLE IF EXISTS carrito;
DROP TABLE IF EXISTS seguimiento;
DROP TABLE IF EXISTS detalle_ventas;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS metodos_pago;
DROP TABLE IF EXISTS usuarios;

-- -----------------------------------------------------------------------------
-- 2. CREACIÓN DE TABLAS CON CLAVES (PK / FK / UNIQUE / AUTO_INCREMENT)
-- -----------------------------------------------------------------------------

-- TABLA: usuarios
CREATE TABLE usuarios (
  id_usuario INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  correo VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  rol VARCHAR(20) DEFAULT 'cliente',
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado VARCHAR(20) DEFAULT 'activo',
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuarios_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: metodos_pago
CREATE TABLE metodos_pago (
  id_metodo_pago INT NOT NULL AUTO_INCREMENT,
  nombre_metodo VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_metodo_pago),
  UNIQUE KEY uq_metodos_pago_nombre (nombre_metodo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: productos
CREATE TABLE productos (
  id_producto INT NOT NULL AUTO_INCREMENT,
  nombre_prod VARCHAR(150) NOT NULL,
  descripcion TEXT DEFAULT NULL,
  precio DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0,
  PRIMARY KEY (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: ventas
CREATE TABLE ventas (
  id_venta INT NOT NULL AUTO_INCREMENT,
  id_usuario INT DEFAULT NULL,
  id_metodo_pago INT DEFAULT NULL,
  fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total DECIMAL(10,2) NOT NULL,
  estado_pago VARCHAR(100) DEFAULT 'Pendiente',
  nombre_cliente VARCHAR(150) DEFAULT NULL,
  telefono_contacto VARCHAR(20) DEFAULT NULL,
  direccion_envio VARCHAR(255) DEFAULT NULL,
  ciudad VARCHAR(100) DEFAULT NULL,
  departamento VARCHAR(100) DEFAULT NULL,
  detalles_pago VARCHAR(255) DEFAULT 'Sin detalle',
  PRIMARY KEY (id_venta),
  KEY idx_ventas_id_usuario (id_usuario),
  KEY idx_ventas_id_metodo_pago (id_metodo_pago),
  CONSTRAINT fk_ventas_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL,
  CONSTRAINT fk_ventas_metodo_pago FOREIGN KEY (id_metodo_pago) REFERENCES metodos_pago (id_metodo_pago) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: detalle_ventas
CREATE TABLE detalle_ventas (
  id_detalle INT NOT NULL AUTO_INCREMENT,
  id_venta INT DEFAULT NULL,
  id_producto INT DEFAULT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_detalle),
  KEY idx_detalle_ventas_id_venta (id_venta),
  KEY idx_detalle_ventas_id_producto (id_producto),
  CONSTRAINT fk_detalle_ventas_venta FOREIGN KEY (id_venta) REFERENCES ventas (id_venta) ON DELETE CASCADE,
  CONSTRAINT fk_detalle_ventas_producto FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: seguimiento
CREATE TABLE seguimiento (
  id_seguimiento INT NOT NULL AUTO_INCREMENT,
  id_venta INT DEFAULT NULL,
  estado_envio VARCHAR(100) DEFAULT 'Preparando pedido',
  numero_guia VARCHAR(100) DEFAULT 'N/A',
  empresa_transporte VARCHAR(100) DEFAULT 'Coordinadora',
  ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_seguimiento),
  KEY idx_seguimiento_id_venta (id_venta),
  CONSTRAINT fk_seguimiento_venta FOREIGN KEY (id_venta) REFERENCES ventas (id_venta) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: carrito
CREATE TABLE carrito (
  id_carrito INT NOT NULL AUTO_INCREMENT,
  id_usuario INT DEFAULT NULL,
  id_producto INT DEFAULT NULL,
  cantidad INT NOT NULL,
  PRIMARY KEY (id_carrito),
  KEY idx_carrito_id_usuario (id_usuario),
  KEY idx_carrito_id_producto (id_producto),
  CONSTRAINT fk_carrito_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE,
  CONSTRAINT fk_carrito_producto FOREIGN KEY (id_producto) REFERENCES productos (id_producto) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: contactanos
CREATE TABLE contactanos (
  id_contactanos INT NOT NULL AUTO_INCREMENT,
  contacto VARCHAR(100) NOT NULL,
  correo_electronico VARCHAR(100) NOT NULL,
  asunto VARCHAR(150) DEFAULT NULL,
  mensaje TEXT NOT NULL,
  fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_contactanos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: facturas
CREATE TABLE facturas (
  id_factura INT NOT NULL AUTO_INCREMENT,
  id_venta INT DEFAULT NULL,
  numero_factura VARCHAR(50) DEFAULT NULL,
  datos_fiscales TEXT DEFAULT NULL,
  fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_factura),
  UNIQUE KEY uq_facturas_id_venta (id_venta),
  UNIQUE KEY uq_facturas_numero (numero_factura),
  CONSTRAINT fk_facturas_venta FOREIGN KEY (id_venta) REFERENCES ventas (id_venta) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- TABLA: devoluciones
CREATE TABLE devoluciones (
  id_devolucion INT NOT NULL AUTO_INCREMENT,
  id_venta INT DEFAULT NULL,
  motivo TEXT NOT NULL,
  estado_devolucion VARCHAR(50) DEFAULT '',
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_devolucion),
  KEY idx_devoluciones_id_venta (id_venta),
  CONSTRAINT fk_devoluciones_venta FOREIGN KEY (id_venta) REFERENCES ventas (id_venta) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. INSERCIÓN DE DATOS EXISTENTES
-- -----------------------------------------------------------------------------

-- 3.1 Usuarios
INSERT INTO usuarios (id_usuario, nombre, correo, password, rol, fecha_registro, estado) VALUES
(1, 'Cristian', 'cristiansotelo.0.0m2@gmail.com', 'scrypt:32768:8:1$4D4sjKJxApz4hufH$8d139a2655efb0820f080c706c6a0dd155352616791694b1c4b60a7dae5561a9188281ad9592575a20476c7d96cc025815c048f0b20db2b92f1ecd1b242910b6', 'admin', '2026-07-30 16:10:44', 'activo'),
(2, 'Cris', 'Crisajj@gmail.com', '1234567890', 'cliente', '2026-08-03 15:13:55', 'activo'),
(3, 'Crespo', 'crespo@gmail.com', 'scrypt:32768:8:1$GggPJBHZCJqd0s7X$be7dddf76570664f258ca14b037071bb87d1159f00627586913c17353c5281f95219e740fd1724b4e8748b5f46e7c140e85d5ebaa92ad27292c65643b19b52a0', 'cliente', '2026-08-03 15:21:44', 'activo'),
(4, 'sotelo23', 'hsahagdh@gmail.com', 'scrypt:32768:8:1$OAT8W8BMPMambfyW$9e0e0cad15de36b3708a214d906be6d8b4731ec97bd29fc29e2e523f8fa952b274cc03b4ec4385310fff1e8e1649e34501fd8f3e00d05e813836b90228705b4c', 'cliente', '2026-08-13 13:41:42', 'activo'),
(6, 'abraham,', 'abrahammolina@gmail.com', 'pene2009', 'cliente', '2026-08-13 13:55:12', 'activo'),
(7, 'christopher', 'christopher@gmail.com', '0987654321', 'cliente', '2026-08-13 14:46:47', 'activo'),
(8, 'ajsda', 'kjashasj@gmail.com', '098765456789', 'cliente', '2026-08-13 14:50:19', 'activo'),
(9, 'messi', 'messi343@gmial.com', '987678', 'cliente', '2026-08-13 14:53:26', 'activo'),
(10, 'cresi', 'cresi423@gmail.com', '8765456789', 'cliente', '2026-08-13 14:56:50', 'activo'),
(11, 'messies', 'meesid@gmail.com', '098765467890', 'cliente', '2026-08-13 15:01:47', 'activo'),
(12, 'hsajjswka', 'dashjdhajsd@gmail.com', 'ad1762178932', 'cliente', '2026-08-13 15:09:04', 'activo'),
(13, 'kjhgfghjk', 'kjhghjq@gmail.com', 'wdsada', 'cliente', '2026-08-13 15:13:12', 'activo');

-- 3.2 Métodos de Pago
INSERT INTO metodos_pago (id_metodo_pago, nombre_metodo, descripcion) VALUES
(1, 'nequi', 'Transfiere desde tu cuenta Nequi'),
(2, 'daviplata', 'Transfiere desde tu cuenta Daviplata'),
(3, 'efectivo', 'Pago en efectivo al recibir el pedido'),
(4, 'tarjeta', 'Tarjeta de Crédito o Débito'),
(5, 'Nequi / Transferencia', 'Pago usando Nequi / Transferencia'),
(6, 'Tarjeta de Débito', 'Pago usando Tarjeta de Débito'),
(7, 'Tarjeta de Crédito', 'Pago usando Tarjeta de Crédito'),
(8, 'Tarjeta de Crédito / Débito', 'Pago usando Tarjeta de Crédito / Débito');

-- 3.3 Productos
INSERT INTO productos (id_producto, nombre_prod, descripcion, precio, stock) VALUES
(1, 'Kit Cepillo Bambú', 'Kit ecológico con 4 cepillos de dientes hechos de bambú', 15000.00, 50),
(2, 'Termo Acero Inoxidable', 'Termo de 500ml para agua fría o caliente', 32000.00, 30),
(4, 'Plato Mini', NULL, 45000.00, 89),
(5, 'Plato BowlTapa', NULL, 20000.00, 80),
(6, 'Plato 3 Divisiones', '', 30000.00, 89);

-- 3.4 Ventas
INSERT INTO ventas (id_venta, id_usuario, id_metodo_pago, fecha_venta, total, estado_pago, nombre_cliente, telefono_contacto, direccion_envio, ciudad, departamento, detalles_pago) VALUES
(1, 1, 5, '2026-07-30 16:11:46', 85000.00, 'Aprobado', 'chris', '313234566', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(2, 1, 6, '2026-07-30 16:24:45', 20000.00, 'Aprobado', 'Cristian Sotelo', '123456', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(3, NULL, 6, '2026-08-03 15:08:47', 135000.00, 'Aprobado', 'Cristian', '3255', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(4, NULL, 6, '2026-08-03 15:36:03', 20000.00, 'Aprobado', 'nas', '2134', 'dasda', 'pene', 'dadsa', 'Sin detalle'),
(5, NULL, 5, '2026-08-03 16:31:15', 20000.00, 'Aprobado', 'hygfd', '2134', 'dasda', 'pene', 'dadsa', 'Sin detalle'),
(6, NULL, 5, '2026-08-13 13:47:56', 95000.00, 'Aprobado', 'dasddsad', '3226483911', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(7, 7, 6, '2026-08-13 14:47:12', 65000.00, 'Aprobado', 'christopher', '65432', 'calle 8 sur 8a -24g', 'cundinamarca', 'Bogota dc', 'Sin detalle'),
(8, 8, 7, '2026-08-13 14:51:12', 365000.00, 'Aprobado', 'Cristian Sotelo', '123456', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(9, 9, 7, '2026-08-13 14:53:57', 95000.00, 'Aprobado', 'messi', '3225473081', 'calle', 'bogota', 'Cundinamarca', 'Sin detalle'),
(10, 10, 5, '2026-08-13 14:57:16', 280000.00, 'Aprobado', 'Cristian Sotelo', '12312312', 'calle 8 sur 8a -24g', 'cundinamarca', 'Cundinamarca', 'Sin detalle'),
(11, 11, 6, '2026-08-13 15:02:07', 95000.00, 'Aprobado', 'Cristian Sotelo', '3226483911', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(12, 12, 5, '2026-08-13 15:09:31', 100000.00, 'Aprobado', 'dasddsad', '09876543212', 'calle el amorio #8 s', 'sAS', 'Bogota dc', 'Sin detalle'),
(13, 13, 6, '2026-08-13 15:13:42', 90000.00, 'Aprobado', 'cesar', '09876543212', 'calle 8 sur 8a -24g', 'bogota', 'Cundinamarca', 'Sin detalle'),
(14, 1, 8, '2026-08-20 13:34:15', 115000.00, 'Aprobado', 'Cristian Sotelo', '123456', 'Calle 6h 09', 'cundinamarca', 'Cundinamarca', 'Tarjeta **** **** **** 7654 (JUAN)');

-- 3.5 Detalle Ventas
INSERT INTO detalle_ventas (id_detalle, id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 4, 1, 45000.00),
(2, 1, 5, 2, 20000.00),
(3, 2, 5, 1, 20000.00),
(4, 3, 4, 1, 45000.00),
(5, 3, 5, 3, 20000.00),
(6, 3, 6, 1, 30000.00),
(7, 4, 5, 1, 20000.00),
(8, 5, 5, 1, 20000.00),
(9, 6, 5, 1, 20000.00),
(10, 6, 4, 1, 45000.00),
(11, 6, 6, 1, 30000.00),
(12, 7, 5, 1, 20000.00),
(13, 7, 4, 1, 45000.00),
(14, 8, 6, 1, 300000.00),
(15, 8, 5, 1, 20000.00),
(16, 8, 4, 1, 45000.00),
(17, 9, 6, 1, 30000.00),
(18, 9, 5, 1, 20000.00),
(19, 9, 4, 1, 45000.00),
(20, 10, 5, 2, 20000.00),
(21, 10, 4, 2, 45000.00),
(22, 10, 6, 5, 30000.00),
(23, 11, 6, 1, 30000.00),
(24, 11, 5, 1, 20000.00),
(25, 11, 4, 1, 45000.00),
(26, 12, 5, 5, 20000.00),
(27, 13, 4, 2, 45000.00),
(28, 14, 5, 2, 20000.00),
(29, 14, 4, 1, 45000.00),
(30, 14, 6, 1, 30000.00);

-- 3.6 Seguimiento
INSERT INTO seguimiento (id_seguimiento, id_venta, estado_envio, numero_guia, empresa_transporte, ultima_actualizacion, fecha_actualizacion) VALUES
(1, 1, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-07-30 16:11:46', '2026-08-20 13:41:05'),
(2, 2, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-07-30 16:24:45', '2026-08-20 13:41:05'),
(3, 3, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-03 15:08:47', '2026-08-20 13:41:05'),
(4, 4, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-03 15:36:03', '2026-08-20 13:41:05'),
(5, 5, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-03 16:31:15', '2026-08-20 13:41:05'),
(6, 6, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 13:47:56', '2026-08-20 13:41:05'),
(7, 7, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 14:47:12', '2026-08-20 13:41:05'),
(8, 8, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 14:51:12', '2026-08-20 13:41:05'),
(9, 9, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 14:53:57', '2026-08-20 13:41:05'),
(10, 10, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 14:57:16', '2026-08-20 13:41:05'),
(11, 11, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 15:02:07', '2026-08-20 13:41:05'),
(12, 12, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 15:09:31', '2026-08-20 13:41:05'),
(13, 13, 'Preparando pedido', 'N/A', 'Coordinadora', '2026-08-13 15:13:42', '2026-08-20 13:41:05'),
(14, 14, 'Preparando pedido', 'EG-000014', 'Coordinadora', '2026-08-20 15:46:46', '2026-08-20 15:46:46');

-- -----------------------------------------------------------------------------
-- 4. AJUSTE DE CONTADORES AUTO_INCREMENT
-- -----------------------------------------------------------------------------
ALTER TABLE usuarios AUTO_INCREMENT = 14;
ALTER TABLE metodos_pago AUTO_INCREMENT = 9;
ALTER TABLE productos AUTO_INCREMENT = 8;
ALTER TABLE ventas AUTO_INCREMENT = 15;
ALTER TABLE detalle_ventas AUTO_INCREMENT = 31;
ALTER TABLE seguimiento AUTO_INCREMENT = 15;
ALTER TABLE carrito AUTO_INCREMENT = 1;
ALTER TABLE contactanos AUTO_INCREMENT = 1;
ALTER TABLE facturas AUTO_INCREMENT = 1;
ALTER TABLE devoluciones AUTO_INCREMENT = 1;

-- -----------------------------------------------------------------------------
-- 5. CREACIÓN DE VISTAS (COMPATIBLES CON AIVEN / SIN DEFINER)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_productos_stock_bajo AS
SELECT 
    id_producto, 
    nombre_prod, 
    precio, 
    stock 
FROM productos 
WHERE stock <= 35;

CREATE OR REPLACE VIEW vista_reporte_ventas AS
SELECT 
    v.id_venta, 
    v.fecha_venta, 
    v.nombre_cliente, 
    v.telefono_contacto, 
    v.ciudad, 
    v.total, 
    v.estado_pago, 
    mp.nombre_metodo AS metodo_pago, 
    s.estado_envio, 
    s.numero_guia, 
    s.empresa_transporte 
FROM ventas v
LEFT JOIN metodos_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
LEFT JOIN seguimiento s ON v.id_venta = s.id_venta;

CREATE OR REPLACE VIEW vista_usuarios_publico AS
SELECT 
    id_usuario, 
    nombre, 
    correo, 
    rol, 
    fecha_registro 
FROM usuarios;

-- -----------------------------------------------------------------------------
-- 6. RESTAURAR COMPROBACIÓN DE CLAVES FORÁNEAS
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
