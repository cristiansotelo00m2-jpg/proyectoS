<?php
include 'conexion.php';

$usuario  = $_POST['usuario_login'];
$password = $_POST['password_login'];

// Buscamos coincidencia
$consulta = "SELECT * FROM usuarios WHERE nombre = '$usuario' AND password = '$password'";
$resultado = mysqli_query($conexion, $consulta);

if (mysqli_num_rows($resultado) > 0) {
    // Si es correcto, lo mandamos al inicio
    header("Location: index.html");
} else {
    echo '<script>
            alert("Datos incorrectos, intenta de nuevo");
            window.location = "gestiondeusuarios.html";
          </script>';
}

mysqli_close($conexion);
?>