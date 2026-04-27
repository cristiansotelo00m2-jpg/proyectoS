<?php
$host = "sql304.infinityfree.com"; 
$user = "if0_41286976"; 
$pass = "TU_CONTRASEÑA_DE_INFINITYFREE"; // Cámbialo por tu clave real
$db   = "if0_41286976_nombre"; 

$conexion = mysqli_connect($host, $user, $pass, $db);

if (!$conexion) {
    die("Error de conexión: " . mysqli_connect_error());
}
?>