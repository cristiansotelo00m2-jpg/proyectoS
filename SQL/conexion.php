<?php
$host = "localhost"; 
$user = "root"; 
$pass = "mysql"; // Contraseña por defecto de AMPPS
$db   = "formulario"; 

// Crear conexión
$conexion = mysqli_connect($host, $user, $pass, $db);

// Verificar conexión
if (!$conexion) {
    die("Error de conexión: " . mysqli_connect_error());
}

// Establecer codificación de caracteres UTF-8
mysqli_set_charset($conexion, "utf8mb4");
?>
