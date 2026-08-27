import json
import mysql.connector
from flask import Flask, render_template, request, redirect, url_for, session, flash

app = Flask(__name__)
app.secret_key = 'tu_clave_secreta_ecogreen'

def get_db_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='',        # Tu contraseña de MySQL si la tienes
        database='formulario' # Base de datos definida en tu script SQL
    )

@app.route('/cuenta')
def cuenta():
    if 'user_email' not in session:
        flash('Debes iniciar sesión para acceder a tu cuenta.', 'warning')
        return redirect(url_for('formulario'))
    
    correo_actual = session['user_email']
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    usuario = None
    compras = []
    
    total_recaudado = 0
    ventas_totales_cant = 0
    total_unidades_vendidas = 0
    nombres_productos = []
    cantidades_productos = []

    try:
        # 1. Datos del usuario
        cursor.execute('SELECT id_usuario, nombre, correo FROM usuarios WHERE correo = %s', (correo_actual,))
        usuario = cursor.fetchone()

        if usuario and usuario.get('id_usuario'):
            # 2. Historial de compras del usuario
            query_compras = """
                SELECT 
                    v.id_venta, 
                    v.total, 
                    v.estado_pago,
                    COALESCE(s.estado_envio, 'Preparando pedido') AS estado_envio,
                    COALESCE(s.numero_guia, 'N/A') AS numero_guia
                FROM ventas v
                LEFT JOIN seguimiento s ON v.id_venta = s.id_venta
                WHERE v.id_usuario = %s
                ORDER BY v.id_venta DESC
            """
            cursor.execute(query_compras, (usuario['id_usuario'],))
            compras = cursor.fetchall()

    except mysql.connector.Error as err:
        print(f"⚠️ Error usuario/compras: {err}")

    # 3. Métricas Globales (Recaudo y Total Ventas)
    try:
        cursor.execute("SELECT COALESCE(SUM(total), 0) AS recaudo, COUNT(*) AS total_ventas FROM ventas")
        stats = cursor.fetchone()
        if stats:
            total_recaudado = float(stats['recaudo'])
            ventas_totales_cant = int(stats['total_ventas'])
    except mysql.connector.Error as err:
        print(f"⚠️ Error métricas: {err}")

    # 4. Top productos vendidos (Usando nombre_prod de tu tabla productos)
    try:
        query_top_productos = """
            SELECT p.nombre_prod AS nombre, COALESCE(SUM(dv.cantidad), 0) AS total_cant
            FROM detalle_ventas dv
            JOIN productos p ON dv.id_producto = p.id_producto
            GROUP BY p.id_producto, p.nombre_prod
            ORDER BY total_cant DESC
            LIMIT 5
        """
        cursor.execute(query_top_productos)
        top_productos = cursor.fetchall()

        for item in top_productos:
            cant = int(item['total_cant'])
            if cant > 0:
                nombres_productos.append(item['nombre'])
                cantidades_productos.append(cant)
                total_unidades_vendidas += cant

    except mysql.connector.Error as err:
        print(f"⚠️ Error top productos: {err}")
    finally:
        cursor.close()
        conn.close()

    if usuario:
        return render_template(
            'cuenta.html', 
            nombre_usuario=usuario['nombre'], 
            correo_usuario=usuario['correo'],
            compras=compras,
            total_recaudado=total_recaudado,
            ventas_totales_cant=ventas_totales_cant,
            total_unidades_vendidas=total_unidades_vendidas,
            nombres_productos=json.dumps(nombres_productos),
            cantidades_productos=json.dumps(cantidades_productos)
        )
    
    session.clear()
    return redirect(url_for('formulario'))

# Cambio del nombre de columna 'password' en MySQL
@app.route('/actualizar_password', methods=['POST'])
def actualizar_password():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    nueva_password = request.form.get('nueva_password')
    if nueva_password:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('UPDATE usuarios SET password = %s WHERE correo = %s', (nueva_password, session['user_email']))
        conn.commit()
        cursor.close()
        conn.close()
        flash('Contraseña actualizada correctamente.', 'success')
    return redirect(url_for('cuenta'))