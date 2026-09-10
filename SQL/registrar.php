<?php
include 'conexion.php';

// Capturamos los datos
$nombre   = $_POST['nombre'];
$correo   = $_POST['correo'];
$password = $_POST['password'];
$rol      = "cliente"; // Rol por defecto

// Insertamos en la tabla según tu esquema de la imagen
$sql = "INSERT INTO usuarios (nombre, correo, password, rol) 
        VALUES ('$nombre', '$correo', '$password', '$rol')";

if (mysqli_query($conexion, $sql)) {
    echo '<script>
            alert("¡Usuario registrado con éxito en EcoGreen!");
            window.location = "gestiondeusuarios.html";
          </script>';
} else {
    echo "Error al registrar: " . mysqli_error($conexion);
}

mysqli_close($conexion);
?>