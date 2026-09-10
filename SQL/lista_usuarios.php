<?php
include 'conexion.php'; // Usamos la conexión que ya tienes

// 1. La consulta para traer los datos (usando los nombres de tu tabla)
$sql = "SELECT id_usuario, nombre, correo, rol, fecha_registro FROM usuarios";
$resultado = mysqli_query($conexion, $sql);
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel de Administración - EcoGreen</title>
    <link rel="stylesheet" href="gestiondeusuarios.css"> <style>
        /* Un poco de estilo rápido para la tabla */
        table { width: 90%; margin: 20px auto; border-collapse: collapse; background: white; }
        th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #2ecc71; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <header>
        <h1>Usuarios Registrados en EcoGreen</h1>
        <nav>
            <a href="index.html">Volver al Inicio</a>
        </nav>
    </header>

    <main>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Rol</th>
                    <th>Fecha de Registro</th>
                </tr>
            </thead>
            <tbody>
                <?php
                // 2. El bucle "while" que recorre cada fila de la base de datos
                while($fila = mysqli_fetch_array($resultado)) {
                    echo "<tr>";
                    echo "<td>" . $fila['id_usuario'] . "</td>";
                    echo "<td>" . $fila['nombre'] . "</td>";
                    echo "<td>" . $fila['correo'] . "</td>";
                    echo "<td>" . $fila['rol'] . "</td>";
                    echo "<td>" . $fila['fecha_registro'] . "</td>";
                    echo "</tr>";
                }
                ?>
            </tbody>
        </table>
    </main>
</body>
</html>

<?php
mysqli_close($conexion);
?>