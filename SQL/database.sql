CREATE DATABASE IF NOT EXISTS formulario;
USE formulario;

-- Desactivamos temporalmente las revisiones de llaves foráneas para poder borrar sin problemas
SET FOREIGN_KEY_CHECKS = 0;

-- Borramos las tablas si quedaron mal creadas de intentos anteriores
DROP TABLE IF EXISTS `carrito`, `detalle_ventas`, `devoluciones`, `facturas`, `seguimiento`, `ventas`, `usuarios`, `productos`, `metodos_pago`, `contactanos`;

-- Volvemos a activar las revisiones
SET FOREIGN_KEY_CHECKS = 1;


-- 1. Tabla: usuarios (Aseguramos que se cree limpia con id_usuario)
CREATE TABLE `usuarios` (
  `id_usuario` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(100) NOT NULL,
  `correo` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `rol` VARCHAR(20) DEFAULT 'cliente',
  `fecha_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabla: productos
CREATE TABLE `productos` (
  `id_producto` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre_prod` VARCHAR(100) NOT NULL,
  `descripcion` TEXT DEFAULT NULL,
  `precio` DECIMAL(10,2) NOT NULL,
  `stock` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabla: metodos_pago
CREATE TABLE `metodos_pago` (
  `id_metodo_pago` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre_metodo` VARCHAR(50) NOT NULL,
  `descripcion` VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabla: carrito (Ahora sí encontrará id_usuario e id_producto)
CREATE TABLE `carrito` (
  `id_carrito` INT AUTO_INCREMENT PRIMARY KEY,
  `id_usuario` INT DEFAULT NULL,
  `id_producto` INT DEFAULT NULL,
  `cantidad` INT NOT NULL,
  FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE,
  FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabla: ventas
CREATE TABLE `ventas` (
  `id_venta` INT AUTO_INCREMENT PRIMARY KEY,
  `id_usuario` INT DEFAULT NULL,
  `id_metodo_pago` INT DEFAULT NULL,
  `fecha_venta` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `total` DECIMAL(10,2) NOT NULL,
  `estado_pago` VARCHAR(100) DEFAULT '',
  FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodos_pago` (`id_metodo_pago`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tabla: detalle_ventas
CREATE TABLE `detalle_ventas` (
  `id_detalle` INT AUTO_INCREMENT PRIMARY KEY,
  `id_venta` INT DEFAULT NULL,
  `id_producto` INT DEFAULT NULL,
  `cantidad` INT NOT NULL,
  `precio_unitario` DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE,
  FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Tabla: devoluciones
CREATE TABLE `devoluciones` (
  `id_devolucion` INT AUTO_INCREMENT PRIMARY KEY,
  `id_venta` INT DEFAULT NULL,
  `motivo` TEXT NOT NULL,
  `estado_devolucion` VARCHAR(50) DEFAULT '',
  `fecha_solicitud` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Tabla: facturas
CREATE TABLE `facturas` (
  `id_factura` INT AUTO_INCREMENT PRIMARY KEY,
  `id_venta` INT UNIQUE DEFAULT NULL,
  `numero_factura` VARCHAR(50) UNIQUE DEFAULT NULL,
  `datos_fiscales` TEXT DEFAULT NULL,
  `fecha_emision` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Tabla: seguimiento
CREATE TABLE `seguimiento` (
  `id_seguimiento` INT AUTO_INCREMENT PRIMARY KEY,
  `id_venta` INT DEFAULT NULL,
  `estado_envio` VARCHAR(50) DEFAULT '',
  `numero_guia` VARCHAR(50) DEFAULT NULL,
  `empresa_transporte` VARCHAR(50) DEFAULT NULL,
  `ultima_actualizacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Tabla: contactanos
CREATE TABLE `contactanos` (
  `id_contactanos` INT AUTO_INCREMENT PRIMARY KEY,
  `contacto` VARCHAR(100) NOT NULL,
  `correo_electronico` VARCHAR(100) NOT NULL,
  `asunto` VARCHAR(150) DEFAULT NULL,
  `mensaje` TEXT NOT NULL,
  `fecha_envio` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;