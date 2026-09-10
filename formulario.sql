-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 27-08-2026 a las 14:19:57
-- Versión del servidor: 8.0.46
-- Versión de PHP: 8.2.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `formulario`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito`
--

CREATE TABLE `carrito` (
  `id_carrito` int NOT NULL,
  `id_usuario` int DEFAULT NULL,
  `id_producto` int DEFAULT NULL,
  `cantidad` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contactanos`
--

CREATE TABLE `contactanos` (
  `id_contactanos` int NOT NULL,
  `contacto` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo_electronico` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `asunto` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mensaje` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_envio` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_ventas`
--

CREATE TABLE `detalle_ventas` (
  `id_detalle` int NOT NULL,
  `id_venta` int DEFAULT NULL,
  `id_producto` int DEFAULT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `detalle_ventas`
--

INSERT INTO `detalle_ventas` (`id_detalle`, `id_venta`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `devoluciones`
--

CREATE TABLE `devoluciones` (
  `id_devolucion` int NOT NULL,
  `id_venta` int DEFAULT NULL,
  `motivo` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado_devolucion` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `fecha_solicitud` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `id_factura` int NOT NULL,
  `id_venta` int DEFAULT NULL,
  `numero_factura` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `datos_fiscales` text COLLATE utf8mb4_unicode_ci,
  `fecha_emision` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodos_pago`
--

CREATE TABLE `metodos_pago` (
  `id_metodo_pago` int NOT NULL,
  `nombre_metodo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `metodos_pago`
--

INSERT INTO `metodos_pago` (`id_metodo_pago`, `nombre_metodo`, `descripcion`) VALUES
(1, 'nequi', 'Transfiere desde tu cuenta Nequi'),
(2, 'daviplata', 'Transfiere desde tu cuenta Daviplata'),
(3, 'efectivo', 'Pago en efectivo al recibir el pedido'),
(4, 'tarjeta', 'Tarjeta de Crédito o Débito'),
(5, 'Nequi / Transferencia', 'Pago usando Nequi / Transferencia'),
(6, 'Tarjeta de Débito', 'Pago usando Tarjeta de Débito'),
(7, 'Tarjeta de Crédito', 'Pago usando Tarjeta de Crédito'),
(8, 'Tarjeta de Crédito / Débito', 'Pago usando Tarjeta de Crédito / Débito');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int NOT NULL,
  `nombre_prod` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `precio` decimal(10,2) NOT NULL,
  `stock` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `nombre_prod`, `descripcion`, `precio`, `stock`) VALUES
(1, 'Kit Cepillo Bambú', 'Kit ecológico con 4 cepillos de dientes hechos de bambú', 15000.00, 50),
(2, 'Termo Acero Inoxidable', 'Termo de 500ml para agua fría o caliente', 32000.00, 30),
(4, 'Plato Mini', NULL, 45000.00, 89),
(5, 'Plato BowlTapa', NULL, 20000.00, 80),
(6, 'Plato 3 Divisiones', '', 30000.00, 89);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `seguimiento`
--

CREATE TABLE `seguimiento` (
  `id_seguimiento` int NOT NULL,
  `id_venta` int DEFAULT NULL,
  `estado_envio` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `numero_guia` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_transporte` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ultima_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `seguimiento`
--

INSERT INTO `seguimiento` (`id_seguimiento`, `id_venta`, `estado_envio`, `numero_guia`, `empresa_transporte`, `ultima_actualizacion`, `fecha_actualizacion`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'cliente',
  `fecha_registro` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `correo`, `password`, `rol`, `fecha_registro`, `estado`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `id_venta` int NOT NULL,
  `id_usuario` int DEFAULT NULL,
  `id_metodo_pago` int DEFAULT NULL,
  `fecha_venta` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `total` decimal(10,2) NOT NULL,
  `estado_pago` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  `nombre_cliente` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono_contacto` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion_envio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ciudad` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `departamento` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `detalles_pago` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'Sin detalle'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`id_venta`, `id_usuario`, `id_metodo_pago`, `fecha_venta`, `total`, `estado_pago`, `nombre_cliente`, `telefono_contacto`, `direccion_envio`, `ciudad`, `departamento`, `detalles_pago`) VALUES
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

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_productos_stock_bajo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_productos_stock_bajo` (
`id_producto` int
,`nombre_prod` varchar(100)
,`precio` decimal(10,2)
,`stock` int
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_reporte_ventas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_reporte_ventas` (
`id_venta` int
,`fecha_venta` timestamp
,`nombre_cliente` varchar(100)
,`telefono_contacto` varchar(20)
,`ciudad` varchar(100)
,`total` decimal(10,2)
,`estado_pago` varchar(100)
,`metodo_pago` varchar(50)
,`estado_envio` varchar(50)
,`numero_guia` varchar(50)
,`empresa_transporte` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_usuarios_publico`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_usuarios_publico` (
`id_usuario` int
,`nombre` varchar(100)
,`correo` varchar(100)
,`rol` varchar(20)
,`fecha_registro` timestamp
);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD PRIMARY KEY (`id_carrito`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `contactanos`
--
ALTER TABLE `contactanos`
  ADD PRIMARY KEY (`id_contactanos`);

--
-- Indices de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_venta` (`id_venta`),
  ADD KEY `id_producto` (`id_producto`);

--
-- Indices de la tabla `devoluciones`
--
ALTER TABLE `devoluciones`
  ADD PRIMARY KEY (`id_devolucion`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id_factura`),
  ADD UNIQUE KEY `id_venta` (`id_venta`),
  ADD UNIQUE KEY `numero_factura` (`numero_factura`);

--
-- Indices de la tabla `metodos_pago`
--
ALTER TABLE `metodos_pago`
  ADD PRIMARY KEY (`id_metodo_pago`),
  ADD UNIQUE KEY `nombre_metodo` (`nombre_metodo`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`);

--
-- Indices de la tabla `seguimiento`
--
ALTER TABLE `seguimiento`
  ADD PRIMARY KEY (`id_seguimiento`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_metodo_pago` (`id_metodo_pago`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `carrito`
--
ALTER TABLE `carrito`
  MODIFY `id_carrito` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `contactanos`
--
ALTER TABLE `contactanos`
  MODIFY `id_contactanos` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  MODIFY `id_detalle` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `devoluciones`
--
ALTER TABLE `devoluciones`
  MODIFY `id_devolucion` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `metodos_pago`
--
ALTER TABLE `metodos_pago`
  MODIFY `id_metodo_pago` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `seguimiento`
--
ALTER TABLE `seguimiento`
  MODIFY `id_seguimiento` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `id_venta` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_productos_stock_bajo`
--
DROP TABLE IF EXISTS `vista_productos_stock_bajo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_productos_stock_bajo`  AS SELECT `productos`.`id_producto` AS `id_producto`, `productos`.`nombre_prod` AS `nombre_prod`, `productos`.`precio` AS `precio`, `productos`.`stock` AS `stock` FROM `productos` WHERE (`productos`.`stock` <= 35) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_reporte_ventas`
--
DROP TABLE IF EXISTS `vista_reporte_ventas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_reporte_ventas`  AS SELECT `v`.`id_venta` AS `id_venta`, `v`.`fecha_venta` AS `fecha_venta`, `v`.`nombre_cliente` AS `nombre_cliente`, `v`.`telefono_contacto` AS `telefono_contacto`, `v`.`ciudad` AS `ciudad`, `v`.`total` AS `total`, `v`.`estado_pago` AS `estado_pago`, `mp`.`nombre_metodo` AS `metodo_pago`, `s`.`estado_envio` AS `estado_envio`, `s`.`numero_guia` AS `numero_guia`, `s`.`empresa_transporte` AS `empresa_transporte` FROM ((`ventas` `v` left join `metodos_pago` `mp` on((`v`.`id_metodo_pago` = `mp`.`id_metodo_pago`))) left join `seguimiento` `s` on((`v`.`id_venta` = `s`.`id_venta`))) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_usuarios_publico`
--
DROP TABLE IF EXISTS `vista_usuarios_publico`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_usuarios_publico`  AS SELECT `usuarios`.`id_usuario` AS `id_usuario`, `usuarios`.`nombre` AS `nombre`, `usuarios`.`correo` AS `correo`, `usuarios`.`rol` AS `rol`, `usuarios`.`fecha_registro` AS `fecha_registro` FROM `usuarios` ;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD CONSTRAINT `carrito_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE,
  ADD CONSTRAINT `carrito_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE CASCADE;

--
-- Filtros para la tabla `detalle_ventas`
--
ALTER TABLE `detalle_ventas`
  ADD CONSTRAINT `detalle_ventas_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE,
  ADD CONSTRAINT `detalle_ventas_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

--
-- Filtros para la tabla `devoluciones`
--
ALTER TABLE `devoluciones`
  ADD CONSTRAINT `devoluciones_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `facturas_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `seguimiento`
--
ALTER TABLE `seguimiento`
  ADD CONSTRAINT `seguimiento_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `ventas` (`id_venta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodos_pago` (`id_metodo_pago`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
