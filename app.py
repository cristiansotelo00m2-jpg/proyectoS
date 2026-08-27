import os
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'clave_secreta_ecogreen_2026')

db_config = {
    'host': os.environ.get('DB_HOST', 'mysql-2484a5be-cristiansotelo-6b14.f.aivencloud.com'),
    'user': os.environ.get('DB_USER', 'avnadmin'),
    'port': int(os.environ.get('DB_PORT', 23508)),
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': os.environ.get('DB_NAME', 'defaultdb'),
    'ssl_disabled': False,
}

def get_db_connection():
    """Función auxiliar para obtener la conexión a MySQL."""
    return mysql.connector.connect(**db_config)

def asegurar_columnas_db():
    """Verifica y agrega columnas necesarias en la base de datos MySQL."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # 1. Verificar detalles_pago en ventas
        cursor.execute("""
            SELECT COUNT(*) 
            FROM information_schema.COLUMNS 
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'ventas' AND COLUMN_NAME = 'detalles_pago'
        """, (db_config['database'],))
        if cursor.fetchone()[0] == 0:
            cursor.execute("ALTER TABLE ventas ADD COLUMN detalles_pago VARCHAR(255) DEFAULT 'Sin detalle'")
            conn.commit()

        # 2. Verificar fecha_actualizacion en seguimiento
        cursor.execute("""
            SELECT COUNT(*) 
            FROM information_schema.COLUMNS 
            WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'seguimiento' AND COLUMN_NAME = 'fecha_actualizacion'
        """, (db_config['database'],))
        if cursor.fetchone()[0] == 0:
            cursor.execute("ALTER TABLE seguimiento ADD COLUMN fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
            conn.commit()

        cursor.close()
        conn.close()
    except Exception as e:
        print(f"⚠️ Nota al verificar columnas DB: {e}")

try:
    asegurar_columnas_db()
except Exception:
    pass

def comprobar_duplicados(nombre, correo):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT id_usuario FROM usuarios WHERE nombre = %s OR correo = %s', (nombre.strip(), correo.strip().lower()))
        return cursor.fetchone() is not None
    finally:
        cursor.close()
        conn.close()

def insertar_usuario(nombre, correo, password):
    # Guardamos la contraseña en texto plano según el requerimiento del usuario
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            'INSERT INTO usuarios (nombre, correo, password) VALUES (%s, %s, %s)', 
            (nombre.strip(), correo.strip().lower(), password)
        )
        conn.commit()
    except mysql.connector.Error as err:
        conn.rollback()
        raise err
    finally:
        cursor.close()
        conn.close()

def verificar_usuario(identificador_o_nombre, correo_o_password, password_opcional=None):
    """
    Permite verificar usuario por Correo o Nombre, validando contraseñas en texto plano 
    así como hashes existentes.
    """
    if password_opcional is not None:
        # Se pasaron 3 argumentos: nombre, correo, password
        identifier = correo_o_password.strip() if correo_o_password else identificador_o_nombre.strip()
        pwd = password_opcional
    else:
        identifier = identificador_o_nombre.strip() if identificador_o_nombre else ''
        pwd = correo_o_password

    if not identifier or not pwd:
        return None

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        # Buscamos por correo (minusculas) o por nombre
        cursor.execute('SELECT * FROM usuarios WHERE correo = %s OR nombre = %s', (identifier.lower(), identifier))
        usuarios = cursor.fetchall()
        
        for usuario in usuarios:
            stored_pwd = usuario['password']
            
            # 1. Comparación directa en texto plano
            if stored_pwd == pwd:
                return usuario
            
            # 2. Intentar validar mediante hash Werkzeug si el registro tiene hash
            try:
                if stored_pwd and check_password_hash(stored_pwd, pwd):
                    return usuario
            except (ValueError, TypeError):
                pass
                
        return None
    finally:
        cursor.close()
        conn.close()

def actualizar_nombre_db(correo, nuevo_nombre):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('UPDATE usuarios SET nombre = %s WHERE correo = %s', (nuevo_nombre, correo))
        conn.commit()
    except mysql.connector.Error as err:
        conn.rollback()
        raise err
    finally:
        cursor.close()
        conn.close()

def actualizar_password_db(correo, nueva_password):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('UPDATE usuarios SET password = %s WHERE correo = %s', (nueva_password, correo))
        conn.commit()
    except mysql.connector.Error as err:
        conn.rollback()
        raise err
    finally:
        cursor.close()
        conn.close()


def obtener_productos_tienda():
    """Obtiene los productos dinámicos de la base de datos MySQL con su stock actual e imagen asignada."""
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id_producto, nombre_prod, precio, stock, COALESCE(descripcion, '') AS descripcion FROM productos ORDER BY id_producto DESC")
        prods = cursor.fetchall()
        for p in prods:
            p['precio_num'] = float(p['precio'])
            name_lower = p['nombre_prod'].lower()
            if 'mini' in name_lower:
                p['imagen'] = 'static/imagenes/plato mini.png'
            elif 'bowl' in name_lower:
                p['imagen'] = 'static/imagenes/pla-bowlytapa.webp'
            elif 'division' in name_lower:
                p['imagen'] = 'static/imagenes/pla-3 divisiones.webp'
            elif 'cepillo' in name_lower or 'bamb' in name_lower:
                p['imagen'] = 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=500'
            elif 'termo' in name_lower:
                p['imagen'] = 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500'
            elif 'bolsa' in name_lower:
                p['imagen'] = 'https://images.unsplash.com/photo-1597484661643-2f5fef640dd1?w=500'
            else:
                p['imagen'] = 'static/imagenes/platos.png'
        return prods
    except Exception as e:
        print(f"⚠️ Error cargando productos para tienda: {e}")
        return []
    finally:
        cursor.close()
        conn.close()


# ========================================================
# RUTAS PRINCIPALES
# ========================================================

@app.route('/')
def home():
    productos = obtener_productos_tienda()
    return render_template('index.html', productos=productos)

@app.route('/quienes_somos')
def quienes_somos():
    return render_template('quienessomos.html')

@app.route('/formulario')
def formulario():
    action = request.args.get('action', '')
    return render_template('gestiondeusuarios.html', error_mode='login' if action == 'login' else 'register')

@app.route('/ventas')
def ventas():
    productos = obtener_productos_tienda()
    return render_template('gestiondeventas.html', productos=productos)

@app.route('/seguimiento')
def seguimiento():
    return render_template('gestiondeseguimiento.html')


# ========================================================
# RUTAS DE USUARIO Y SESIÓN
# ========================================================

@app.route('/procesar_formulario', methods=['POST'])
def procesar_formulario():
    # Login: Acepta email/correo o usuario en el primer campo
    correo_o_usuario = request.form.get('email', request.form.get('correo', request.form.get('nombre', ''))).strip()
    password = request.form.get('contrasena', request.form.get('password', '')) 
    
    if not correo_o_usuario or not password:
        return render_template('gestiondeusuarios.html', error_login="Por favor ingresa tu correo/usuario y tu contraseña.", error_mode="login")
    
    try:
        usuario_valido = verificar_usuario(correo_o_usuario, password)
        
        if usuario_valido:
            if usuario_valido.get('estado') == 'baneado':
                return render_template('gestiondeusuarios.html', error_login="❌ Tu cuenta se encuentra suspendida o baneada. Contacta al soporte.", error_mode="login")
                
            session['user_email'] = usuario_valido['correo']
            session['user_name'] = usuario_valido['nombre']
            session['user_role'] = usuario_valido.get('rol', 'cliente')
            flash(f"¡Bienvenido de nuevo, {usuario_valido['nombre']}!", "success")
            return redirect(url_for('cuenta'))
        
        return render_template('gestiondeusuarios.html', error_login="Datos incorrectos. Verifica tu correo/usuario y contraseña.", error_mode="login")
    except mysql.connector.Error as err:
        return render_template('gestiondeusuarios.html', error_login=f"Error al conectar con la base de datos: {err}", error_mode="login")

@app.route('/procesar_registro', methods=['POST'])
def procesar_registro():
    nombre = request.form.get('nombre', '').strip()
    correo = request.form.get('correo', request.form.get('email', '')).strip().lower()      
    password = request.form.get('password', request.form.get('contrasena', ''))  
    
    if not nombre or not correo or not password:
        return render_template('gestiondeusuarios.html', error_registro="Todos los campos son obligatorios.")

    try:
        if comprobar_duplicados(nombre, correo):
            return render_template('gestiondeusuarios.html', error_registro="El nombre de usuario o correo ya se encuentra registrado.")
        
        insertar_usuario(nombre, correo, password)
        session['user_email'] = correo 
        session['user_name'] = nombre
        session['user_role'] = 'cliente'
        
        flash('¡Tu cuenta ha sido creada con éxito! Bienvenido a EcoGreen.', 'success')
        return redirect(url_for('cuenta'))
    except mysql.connector.Error as err:
        return render_template('gestiondeusuarios.html', error_registro=f"Error en la base de datos: {err}")

@app.route('/actualizar_nombre', methods=['POST'])
def actualizar_nombre():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    nuevo_nombre = request.form['nuevo_nombre']
    correo_actual = session['user_email']
    
    actualizar_nombre_db(correo_actual, nuevo_nombre)
    session['user_name'] = nuevo_nombre
    flash('Nombre actualizado correctamente.', 'success')
    return redirect(url_for('cuenta'))

@app.route('/actualizar_password', methods=['POST'])
def actualizar_password():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    nueva_password = request.form['nueva_password']
    correo_actual = session['user_email']
    
    actualizar_password_db(correo_actual, nueva_password)
    flash('Contraseña modificada con éxito.', 'success')
    return redirect(url_for('cuenta'))

import json

@app.route('/cuenta')
def cuenta():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    correo_actual = session['user_email']
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    usuario = None
    compras = []
    
    # Datos específicos del Panel Administrador
    todos_los_usuarios = []
    lista_productos = []
    lista_ventas_globales = []
    
    total_recaudado = 0
    ventas_totales_cant = 0
    total_unidades_vendidas = 0
    nombres_productos = []
    cantidades_productos = []

    try:
        # 1. Información del usuario logueado
        cursor.execute('SELECT id_usuario, nombre, correo, COALESCE(rol, "cliente") AS rol, COALESCE(estado, "activo") AS estado FROM usuarios WHERE correo = %s', (correo_actual,))
        usuario = cursor.fetchone()

        if not usuario or usuario.get('estado') == 'baneado':
            session.clear()
            flash('Tu cuenta no existe o ha sido suspendida.', 'error')
            return redirect(url_for('formulario'))

        session['user_role'] = usuario['rol']

        # 2. Historial de compras personal
        query_compras = """
            SELECT 
                v.id_venta, 
                v.total, 
                v.fecha_venta,
                v.estado_pago,
                COALESCE(v.detalles_pago, 'Sin detalle') AS detalles_pago,
                COALESCE(s.estado_envio, 'Preparando pedido') AS estado_envio,
                COALESCE(s.numero_guia, CONCAT('EG-', LPAD(v.id_venta, 6, '0'))) AS numero_guia,
                COALESCE(s.empresa_transporte, 'Coordinadora') AS empresa_transporte
            FROM ventas v
            LEFT JOIN seguimiento s ON v.id_venta = s.id_venta
            WHERE v.id_usuario = %s
            ORDER BY v.id_venta DESC
        """
        cursor.execute(query_compras, (usuario['id_usuario'],))
        compras = cursor.fetchall()

        # 3. Si es ADMINISTRADOR, cargar datos adicionales para el Panel Admin
        if usuario['rol'] == 'admin':
            # 3.1 Lista de todos los usuarios (con contraseñas visibles)
            cursor.execute('SELECT id_usuario, nombre, correo, password, COALESCE(rol, "cliente") AS rol, COALESCE(estado, "activo") AS estado, fecha_registro FROM usuarios ORDER BY id_usuario DESC')
            todos_los_usuarios = cursor.fetchall()

            # 3.2 Lista de productos con stock e información de ventas
            query_admin_productos = """
                SELECT 
                    p.id_producto, 
                    p.nombre_prod, 
                    p.precio, 
                    p.stock, 
                    COALESCE(p.descripcion, '') AS descripcion,
                    COALESCE(SUM(dv.cantidad), 0) AS total_vendidos,
                    COALESCE(SUM(dv.cantidad * dv.precio_unitario), 0) AS recaudo_producto
                FROM productos p
                LEFT JOIN detalle_ventas dv ON p.id_producto = dv.id_producto
                GROUP BY p.id_producto, p.nombre_prod, p.precio, p.stock, p.descripcion
                ORDER BY p.id_producto DESC
            """
            cursor.execute(query_admin_productos)
            lista_productos = cursor.fetchall()

            # 3.3 Lista global de ventas / facturas y seguimiento
            query_admin_ventas = """
                SELECT 
                    v.id_venta, 
                    v.nombre_cliente, 
                    v.telefono_contacto,
                    v.direccion_envio,
                    v.ciudad,
                    v.departamento,
                    COALESCE(u.correo, 'Cliente Invitado') AS correo_cliente,
                    v.total, 
                    v.fecha_venta,
                    v.estado_pago,
                    COALESCE(v.detalles_pago, 'Sin detalle') AS detalles_pago,
                    COALESCE(m.nombre_metodo, 'Efectivo') AS metodo_pago,
                    COALESCE(s.estado_envio, 'Preparando pedido') AS estado_envio,
                    COALESCE(s.numero_guia, CONCAT('EG-', LPAD(v.id_venta, 6, '0'))) AS numero_guia,
                    COALESCE(s.empresa_transporte, 'Coordinadora') AS empresa_transporte
                FROM ventas v
                LEFT JOIN usuarios u ON v.id_usuario = u.id_usuario
                LEFT JOIN metodos_pago m ON v.id_metodo_pago = m.id_metodo_pago
                LEFT JOIN seguimiento s ON v.id_venta = s.id_venta
                ORDER BY v.id_venta DESC
            """
            cursor.execute(query_admin_ventas)
            lista_ventas_globales = cursor.fetchall()

            # 3.4 Métricas Globales
            cursor.execute("SELECT COALESCE(SUM(total), 0) AS recaudo, COUNT(*) AS total_ventas FROM ventas")
            stats = cursor.fetchone()
            if stats:
                total_recaudado = float(stats['recaudo'])
                ventas_totales_cant = int(stats['total_ventas'])

            # 3.5 Top productos para gráfica
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
        print(f"⚠️ Error al obtener datos de cuenta: {err}")
    finally:
        cursor.close()
        conn.close()

    if usuario:
        return render_template(
            'cuenta.html', 
            usuario=usuario,
            nombre_usuario=usuario['nombre'], 
            correo_usuario=usuario['correo'],
            rol_usuario=usuario['rol'],
            compras=compras,
            todos_los_usuarios=todos_los_usuarios,
            lista_productos=lista_productos,
            lista_ventas_globales=lista_ventas_globales,
            total_recaudado=total_recaudado,
            ventas_totales_cant=ventas_totales_cant,
            total_unidades_vendidas=total_unidades_vendidas,
            nombres_productos=json.dumps(nombres_productos),
            cantidades_productos=json.dumps(cantidades_productos)
        )
    
    session.clear()
    return redirect(url_for('formulario'))

# ========================================================
# RUTAS DE ACCIONES DE ADMINISTRADOR (SOLO ADMIN)
# ========================================================

def es_admin():
    return session.get('user_role') == 'admin'

@app.route('/admin/producto/crear', methods=['POST'])
def admin_crear_producto():
    if not es_admin():
        flash('Acceso denegado. Se requieren permisos de Administrador.', 'danger')
        return redirect(url_for('cuenta'))
    
    nombre_prod = request.form.get('nombre_prod', '').strip()
    precio = request.form.get('precio', 0)
    stock = request.form.get('stock', 0)
    descripcion = request.form.get('descripcion', '').strip()
    
    if not nombre_prod or not precio:
        flash('El nombre del producto y el precio son obligatorios.', 'danger')
        return redirect(url_for('cuenta'))
        
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            'INSERT INTO productos (nombre_prod, precio, stock, descripcion) VALUES (%s, %s, %s, %s)',
            (nombre_prod, precio, stock, descripcion)
        )
        conn.commit()
        flash(f'¡Producto "{nombre_prod}" agregado correctamente!', 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'Error al crear el producto: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('cuenta'))

@app.route('/admin/producto/editar', methods=['POST'])
def admin_editar_producto():
    if not es_admin():
        flash('Acceso denegado.', 'danger')
        return redirect(url_for('cuenta'))
        
    id_producto = request.form.get('id_producto')
    nombre_prod = request.form.get('nombre_prod', '').strip()
    precio = request.form.get('precio', 0)
    stock = request.form.get('stock', 0)
    descripcion = request.form.get('descripcion', '').strip()
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            'UPDATE productos SET nombre_prod = %s, precio = %s, stock = %s, descripcion = %s WHERE id_producto = %s',
            (nombre_prod, precio, stock, descripcion, id_producto)
        )
        conn.commit()
        flash(f'Producto #{id_producto} actualizado correctamente.', 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'Error al actualizar el producto: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('cuenta'))

@app.route('/admin/producto/eliminar', methods=['POST'])
def admin_eliminar_producto():
    if not es_admin():
        flash('Acceso denegado.', 'danger')
        return redirect(url_for('cuenta'))
        
    id_producto = request.form.get('id_producto')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('DELETE FROM productos WHERE id_producto = %s', (id_producto,))
        conn.commit()
        flash('Producto eliminado con éxito.', 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'No se puede eliminar el producto porque tiene ventas registradas: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('cuenta'))

@app.route('/admin/usuario/estado', methods=['POST'])
def admin_cambiar_estado_usuario():
    if not es_admin():
        flash('Acceso denegado.', 'danger')
        return redirect(url_for('cuenta'))
        
    id_usuario = request.form.get('id_usuario')
    nuevo_estado = request.form.get('nuevo_estado')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('UPDATE usuarios SET estado = %s WHERE id_usuario = %s', (nuevo_estado, id_usuario))
        conn.commit()
        mensaje = "🚫 Usuario baneado / suspendido." if nuevo_estado == "baneado" else "✅ Usuario activado correctamente."
        flash(mensaje, 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'Error al modificar el estado del usuario: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('cuenta'))

@app.route('/admin/usuario/rol', methods=['POST'])
def admin_cambiar_rol_usuario():
    if not es_admin():
        flash('Acceso denegado.', 'danger')
        return redirect(url_for('cuenta'))
        
    id_usuario = request.form.get('id_usuario')
    nuevo_rol = request.form.get('nuevo_rol')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute('UPDATE usuarios SET rol = %s WHERE id_usuario = %s', (nuevo_rol, id_usuario))
        conn.commit()
        flash(f'Rol del usuario actualizado a "{nuevo_rol}".', 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'Error al cambiar el rol: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('cuenta'))

@app.route('/admin/seguimiento/actualizar', methods=['POST'])
def admin_actualizar_seguimiento():
    if not es_admin():
        flash('Acceso denegado. Se requieren permisos de Administrador.', 'danger')
        return redirect(url_for('cuenta'))
        
    id_venta = request.form.get('id_venta')
    estado_envio = request.form.get('estado_envio', 'Preparando pedido').strip()
    numero_guia = request.form.get('numero_guia', '').strip()
    empresa_transporte = request.form.get('empresa_transporte', 'Coordinadora').strip()
    
    if not id_venta:
        flash('ID de venta no válido.', 'danger')
        return redirect(url_for('cuenta'))
        
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id_seguimiento FROM seguimiento WHERE id_venta = %s", (id_venta,))
        seg = cursor.fetchone()
        
        if seg:
            cursor.execute("""
                UPDATE seguimiento 
                SET estado_envio = %s, numero_guia = %s, empresa_transporte = %s 
                WHERE id_venta = %s
            """, (estado_envio, numero_guia, empresa_transporte, id_venta))
        else:
            cursor.execute("""
                INSERT INTO seguimiento (id_venta, estado_envio, numero_guia, empresa_transporte)
                VALUES (%s, %s, %s, %s)
            """, (id_venta, estado_envio, numero_guia, empresa_transporte))
            
        conn.commit()
        flash(f'¡Estado del pedido #{id_venta} actualizado a "{estado_envio}" con guía {numero_guia}!', 'success')
    except mysql.connector.Error as err:
        conn.rollback()
        flash(f'Error al actualizar el seguimiento: {err}', 'danger')
    finally:
        cursor.close()
        conn.close()
        
    return redirect(url_for('cuenta'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('home'))


# ========================================================
# RUTAS DE COMPRAS Y PEDIDOS Y RASTREO
# ========================================================

@app.route('/finalizar-compra', methods=['POST'])
def finalizar_compra():
    conn = None
    cursor = None
    try:
        datos = request.get_json() or {}
        
        nombre = datos.get('nombre', '').strip()
        telefono = datos.get('telefono', '').strip()
        direccion = datos.get('direccion', '').strip()
        ciudad = datos.get('ciudad', '').strip()
        departamento = datos.get('departamento', '').strip()
        metodo_pago_nombre = datos.get('metodo_pago', 'Tarjeta de Crédito').strip()
        detalles_pago = datos.get('detalles_pago', '').strip()
        total = datos.get('total', 0)
        carrito = datos.get('carrito', [])

        # Si no se pasó detalles_pago preformateado, construirlo si vienen campos individuales
        if not detalles_pago:
            tarjeta_numero = datos.get('tarjeta_numero', '').replace(' ', '')
            tarjeta_titular = datos.get('tarjeta_titular', '').strip()
            nequi_celular = datos.get('nequi_celular', '').strip()
            nequi_ref = datos.get('nequi_ref', '').strip()

            if 'nequi' in metodo_pago_nombre.lower():
                detalles_pago = f"Nequi: {nequi_celular}" if nequi_celular else "Nequi App"
                if nequi_ref:
                    detalles_pago += f" (Ref: {nequi_ref})"
            elif 'tarjeta' in metodo_pago_nombre.lower():
                ultimos_4 = tarjeta_numero[-4:] if len(tarjeta_numero) >= 4 else "0000"
                detalles_pago = f"Tarjeta **** **** **** {ultimos_4}"
                if tarjeta_titular:
                    detalles_pago += f" ({tarjeta_titular.upper()})"
            else:
                detalles_pago = f"Pago mediante {metodo_pago_nombre}"

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        id_usuario = None
        if 'user_email' in session:
            cursor.execute("SELECT id_usuario FROM usuarios WHERE correo = %s", (session['user_email'],))
            res_usuario = cursor.fetchone()
            if res_usuario:
                id_usuario = res_usuario['id_usuario']

        id_metodo_pago = None
        cursor.execute("SELECT id_metodo_pago FROM metodos_pago WHERE nombre_metodo = %s", (metodo_pago_nombre,))
        res_metodo = cursor.fetchone()
        if res_metodo:
            id_metodo_pago = res_metodo['id_metodo_pago']
        else:
            cursor.execute("INSERT INTO metodos_pago (nombre_metodo, descripcion) VALUES (%s, %s)", (metodo_pago_nombre, f"Pago usando {metodo_pago_nombre}"))
            id_metodo_pago = cursor.lastrowid

        query_venta = """
            INSERT INTO ventas (id_usuario, id_metodo_pago, total, estado_pago, detalles_pago, nombre_cliente, telefono_contacto, direccion_envio, ciudad, departamento)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query_venta, (
            id_usuario, 
            id_metodo_pago, 
            total, 
            'Aprobado' if 'efectivo' not in metodo_pago_nombre.lower() else 'Pendiente por cobrar',
            detalles_pago,
            nombre,
            telefono,
            direccion,
            ciudad,
            departamento
        ))
        id_venta = cursor.lastrowid
        numero_guia_generado = f"EG-{id_venta:06d}"

        for producto in carrito:
            nombre_prod = producto['nombre']
            precio_unitario = producto['precio']
            cantidad = producto['cantidad']

            cursor.execute("SELECT id_producto, stock FROM productos WHERE nombre_prod = %s", (nombre_prod,))
            res_prod = cursor.fetchone()
            
            if res_prod:
                id_producto = res_prod['id_producto']
            else:
                cursor.execute("INSERT INTO productos (nombre_prod, precio, stock) VALUES (%s, %s, 100)", (nombre_prod, precio_unitario))
                id_producto = cursor.lastrowid

            # 1. Insertar en detalle_ventas
            cursor.execute("""
                INSERT INTO detalle_ventas (id_venta, id_producto, cantidad, precio_unitario)
                VALUES (%s, %s, %s, %s)
            """, (id_venta, id_producto, cantidad, precio_unitario))

            # 2. Descontar del Stock del Producto
            cursor.execute("""
                UPDATE productos 
                SET stock = GREATEST(0, stock - %s) 
                WHERE id_producto = %s
            """, (cantidad, id_producto))

        # 3. Crear registro de seguimiento
        cursor.execute("""
            INSERT INTO seguimiento (id_venta, estado_envio, numero_guia, empresa_transporte)
            VALUES (%s, 'Preparando pedido', %s, 'Coordinadora')
        """, (id_venta, numero_guia_generado))

        conn.commit()
        
        return jsonify({
            "status": "success",
            "message": "¡Pedido registrado exitosamente!",
            "id_venta": id_venta,
            "numero_guia": numero_guia_generado
        }), 200

    except mysql.connector.Error as err:
        if conn: conn.rollback()
        return jsonify({"status": "error", "message": f"Error de MySQL: {str(err)}"}), 500
    finally:
        if cursor: cursor.close()
        if conn: conn.close()

COORDENADAS_CIUDADES = {
    'bogota': {'lat': 4.6097, 'lng': -74.0817},
    'bogotá': {'lat': 4.6097, 'lng': -74.0817},
    'medellin': {'lat': 6.2442, 'lng': -75.5812},
    'medellín': {'lat': 6.2442, 'lng': -75.5812},
    'cali': {'lat': 3.4516, 'lng': -76.5320},
    'barranquilla': {'lat': 10.9685, 'lng': -74.7813},
    'cartagena': {'lat': 10.3910, 'lng': -75.4794},
    'bucaramanga': {'lat': 7.1254, 'lng': -73.1198},
    'pereira': {'lat': 4.8133, 'lng': -75.6961},
    'manizales': {'lat': 5.0689, 'lng': -75.5174},
    'cucuta': {'lat': 7.8939, 'lng': -72.5078},
    'cúcuta': {'lat': 7.8939, 'lng': -72.5078},
    'ibague': {'lat': 4.4389, 'lng': -75.2322},
    'ibagué': {'lat': 4.4389, 'lng': -75.2322},
    'pasto': {'lat': 1.2136, 'lng': -77.2811},
    'villavicencio': {'lat': 4.1420, 'lng': -73.6266},
    'santa marta': {'lat': 11.2408, 'lng': -74.1990},
    'valledupar': {'lat': 10.4631, 'lng': -73.2532},
    'monteria': {'lat': 8.7480, 'lng': -75.8814},
    'montería': {'lat': 8.7480, 'lng': -75.8814},
    'armenia': {'lat': 4.5339, 'lng': -75.6811},
    'popayan': {'lat': 2.4448, 'lng': -76.6147},
    'popayán': {'lat': 2.4448, 'lng': -76.6147},
    'neiva': {'lat': 2.9273, 'lng': -75.2819},
    'tunja': {'lat': 5.5353, 'lng': -73.3678}
}

@app.route('/api/rastrear', methods=['GET', 'POST'])
def api_rastrear():
    busqueda = request.args.get('busqueda') or (request.get_json() or {}).get('busqueda', '')
    busqueda = str(busqueda).strip()
    
    if not busqueda:
        return jsonify({"status": "error", "message": "Por favor ingresa un número de pedido o número de guía."}), 400
        
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        query = """
            SELECT 
                v.id_venta,
                v.nombre_cliente,
                v.telefono_contacto,
                v.direccion_envio,
                v.ciudad,
                v.departamento,
                v.fecha_venta,
                v.total,
                v.estado_pago,
                COALESCE(v.detalles_pago, 'Sin detalle') AS detalles_pago,
                COALESCE(m.nombre_metodo, 'Efectivo') AS metodo_pago,
                COALESCE(s.estado_envio, 'Preparando pedido') AS estado_envio,
                COALESCE(s.numero_guia, CONCAT('EG-', LPAD(v.id_venta, 6, '0'))) AS numero_guia,
                COALESCE(s.empresa_transporte, 'Coordinadora') AS empresa_transporte,
                v.fecha_venta AS fecha_actualizacion
            FROM ventas v
            LEFT JOIN metodos_pago m ON v.id_metodo_pago = m.id_metodo_pago
            LEFT JOIN seguimiento s ON v.id_venta = s.id_venta
            WHERE v.id_venta = %s OR s.numero_guia = %s OR CONCAT('EG-', LPAD(v.id_venta, 6, '0')) = %s
        """
        search_id = int(busqueda) if busqueda.isdigit() else -1
        cursor.execute(query, (search_id, busqueda, busqueda))
        venta = cursor.fetchone()
        
        if not venta:
            return jsonify({"status": "error", "message": f"No encontramos ningún pedido registrado con el identificador '{busqueda}'."}), 404
            
        cursor.execute("""
            SELECT d.cantidad, d.precio_unitario, p.nombre_prod, (d.cantidad * d.precio_unitario) AS subtotal
            FROM detalle_ventas d
            JOIN productos p ON d.id_producto = p.id_producto
            WHERE d.id_venta = %s
        """, (venta['id_venta'],))
        productos = cursor.fetchall()
        venta['productos'] = productos
        venta['fecha_venta'] = str(venta['fecha_venta'])
        if venta.get('fecha_actualizacion'):
            venta['fecha_actualizacion'] = str(venta['fecha_actualizacion'])
            
        # Coordenadas Origen: Bodega Central EcoGreen Bogotá (Puente Aranda)
        venta['origen_coords'] = {'lat': 4.6300, 'lng': -74.1000, 'nombre': 'Bodega Central EcoGreen (Bogotá D.C.)'}
        if not venta.get('ciudad'):
            venta['ciudad'] = 'Bogotá D.C.'

        return jsonify({"status": "success", "pedido": venta})
    except mysql.connector.Error as err:
        return jsonify({"status": "error", "message": f"Error de base de datos: {str(err)}"}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/factura/<int:id_venta>')
def ver_factura(id_venta):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        query_venta = """
            SELECT v.*, m.nombre_metodo, u.correo AS correo_usuario,
                   COALESCE(s.estado_envio, 'Preparando pedido') AS estado_envio,
                   COALESCE(s.numero_guia, CONCAT('EG-', LPAD(v.id_venta, 6, '0'))) AS numero_guia,
                   COALESCE(s.empresa_transporte, 'Coordinadora') AS empresa_transporte
            FROM ventas v
            LEFT JOIN metodos_pago m ON v.id_metodo_pago = m.id_metodo_pago
            LEFT JOIN usuarios u ON v.id_usuario = u.id_usuario
            LEFT JOIN seguimiento s ON v.id_venta = s.id_venta
            WHERE v.id_venta = %s
        """
        cursor.execute(query_venta, (id_venta,))
        venta = cursor.fetchone()

        if not venta:
            flash('La factura o venta solicitada no existe.', 'error')
            return redirect(url_for('home'))

        query_detalle = """
            SELECT d.cantidad, d.precio_unitario, p.nombre_prod, 
                   (d.cantidad * d.precio_unitario) AS subtotal_item
            FROM detalle_ventas d
            JOIN productos p ON d.id_producto = p.id_producto
            WHERE d.id_venta = %s
        """
        cursor.execute(query_detalle, (id_venta,))
        detalles = cursor.fetchall()

        return render_template('factura.html', venta=venta, detalles=detalles)

    except mysql.connector.Error as err:
        return "Error al cargar la factura", 500
    finally:
        cursor.close()
        conn.close()


# ========================================================
# CHATBOT / ASISTENTE VIRTUAL
# ========================================================

OPCIONES_CHAT = {
    "inicio": {
        "texto": "¡Hola! Bienvenido. Selecciona una opción para ayudarte:",
        "opciones": [
            {"id": "p1", "texto": "1. ¿Qué productos ofrecen?"},
            {"id": "p2", "texto": "2. ¿Cuáles son los precios?"},
            {"id": "p3", "texto": "3. ¿Dónde están ubicados y cuáles son los horarios?"},
            {"id": "p4", "texto": "4. ¿Cómo puedo hacer un pedido o compra?"},
            {"id": "p5", "texto": "5. ¿Cómo puedo contactar a soporte?"}
        ]
    },
    "p1": {
        "texto": "Ofrecemos productos ecológicos y biodegradables diseñados para el cuidado del medio ambiente.",
        "opciones": [
            {"id": "p2", "texto": "Ver precios"},
            {"id": "inicio", "texto": "⬅️ Volver al menú principal"}
        ]
    },
    "p2": {
        "texto": "Nuestros precios varían según el producto. Van desde $10.000 hasta $80.000 COP.",
        "opciones": [
            {"id": "p4", "texto": "¿Cómo comprar?"},
            {"id": "inicio", "texto": "⬅️ Volver al menú principal"}
        ]
    },
    "p3": {
        "texto": "Atendemos de Lunes a Viernes de 8:00 AM a 6:00 PM de forma 100% online.",
        "opciones": [
            {"id": "inicio", "texto": "⬅️ Volver al menú principal"}
        ]
    },
    "p4": {
        "texto": "Puedes agregar los productos a tu carrito en esta web o realizar tu pedido directamente con un asesor.",
        "opciones": [
            {"id": "p5", "texto": "Contactar asesor"},
            {"id": "inicio", "texto": "⬅️ Volver al menú principal"}
        ]
    },
    "p5": {
        "texto": "Puedes escribirnos directamente a nuestro WhatsApp o al correo de soporte técnico.",
        "opciones": [
            {"id": "inicio", "texto": "⬅️ Volver al menú principal"}
        ]
    }
}

@app.route('/api/chat', methods=['POST'])
def chat():
    datos = request.get_json() or {}
    opcion_id = datos.get('opcion', 'inicio')
    respuesta = OPCIONES_CHAT.get(opcion_id, OPCIONES_CHAT["inicio"])
    return jsonify(respuesta)


if __name__ == '__main__':
    app.run(debug=True, port=5000)
