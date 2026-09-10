import mysql.connector

# Usamos exactamente tus mismas credenciales de EcoGreen
db_config = {
    'host': 'localhost',         
    'user': 'rooty',             
    'password': 'password',     
    'database': 'formulario'    
}

sql_commands = """
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS seguimiento;
DROP TABLE IF EXISTS detalle_ventas;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS metodos_pago;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE metodos_pago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_prod VARCHAR(150) NOT NULL UNIQUE,
    precio INT NOT NULL,
    stock INT DEFAULT 100
);

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_metodo_pago INT,
    total INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_pago VARCHAR(50) DEFAULT 'Pendiente',
    detalles_pago VARCHAR(255) DEFAULT 'Sin detalle',
    nombre_cliente VARCHAR(150) NOT NULL,
    telefono_contacto VARCHAR(20) NOT NULL,
    direccion_envio VARCHAR(255) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    FOREIGN KEY (id_metodo_pago) REFERENCES metodos_pago(id_metodo_pago)
);

CREATE TABLE detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario INT NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE seguimiento (
    id_seguimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    estado_envio VARCHAR(100) DEFAULT 'Preparando pedido',
    numero_guia VARCHAR(100) DEFAULT 'N/A',
    empresa_transporte VARCHAR(100) DEFAULT 'Coordinadora',
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta) ON DELETE CASCADE
);
"""

try:
    print("Conectando a la base de datos...")
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    
    # Ejecutamos todo el bloque SQL de un solo golpe
    print("Creando las tablas para el carrito...")
    resultados = cursor.execute(sql_commands, multi=True)
    for res in resultados:
        pass  # Consumimos los resultados para asegurar la ejecución
        
    conn.commit()
    print("¡Éxito! Las tablas se han creado correctamente en la base de datos 'formulario'.")
except mysql.connector.Error as err:
    print(f"Hubo un error al crear las tablas: {err}")
finally:
    if 'cursor' in locals(): cursor.close()
    if 'conn' in locals(): conn.close()