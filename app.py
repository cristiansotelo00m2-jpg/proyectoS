from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = 'clave_secreta_ecogreen_2026'

db_config = {
    'host': 'localhost',         
    'user': 'rooty',             
    'password': 'password',     
    'database': 'formulario'    
}

# --- FUNCIONES DE BASE DE DATOS ---

def comprobar_duplicados(nombre, correo):
    conn = None
    cursor = None
    existe = False
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute('SELECT id_usuario FROM usuarios WHERE nombre = %s OR correo = %s', (nombre, correo))
        if cursor.fetchone():
            existe = True
    except mysql.connector.Error as err:
        print(f"Error al comprobar duplicados: {err}")
    finally:
        if cursor: cursor.close()
        if conn: conn.close()
    return existe

def insertar_usuario(nombre, correo, password):
    conn = None
    cursor = None
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO usuarios (nombre, correo, password) VALUES (%s, %s, %s)', 
            (nombre, correo, password)
        )
        conn.commit()
    except mysql.connector.Error as err:
        print(f"Error al insertar usuario: {err}")
        if conn: conn.rollback()
    finally:
        if cursor: cursor.close()
        if conn: conn.close()

def verificar_usuario(nombre, correo, password):
    conn = None
    cursor = None
    usuario = None
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            'SELECT * FROM usuarios WHERE nombre = %s AND correo = %s AND password = %s', 
            (nombre, correo, password)
        )
        usuario = cursor.fetchone()
    except mysql.connector.Error as err:
        print(f"Error al verificar usuario: {err}")
    finally:
        if cursor: cursor.close()
        if conn: conn.close()
    return usuario

def actualizar_nombre_db(correo, nuevo_nombre):
    conn = None
    cursor = None
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute('UPDATE usuarios SET nombre = %s WHERE correo = %s', (nuevo_nombre, correo))
        conn.commit()
    except mysql.connector.Error as err:
        print(f"Error al actualizar nombre: {err}")
        if conn: conn.rollback()
    finally:
        if cursor: cursor.close()
        if conn: conn.close()

def actualizar_password_db(correo, nueva_password):
    conn = None
    cursor = None
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute('UPDATE usuarios SET password = %s WHERE correo = %s', (nueva_password, correo))
        conn.commit()
    except mysql.connector.Error as err:
        print(f"Error al actualizar contraseña: {err}")
        if conn: conn.rollback()
    finally:
        if cursor: cursor.close()
        if conn: conn.close()


# --- RUTAS DE NAVEGACIÓN ---

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/quienes_somos')
def quienes_somos():
    return render_template('quienessomos.html')

@app.route('/formulario')
def formulario():
    return render_template('gestiondeusuarios.html')

@app.route('/ventas')
def ventas():
    return render_template('gestiondeventas.html')

@app.route('/seguimiento')
def seguimiento():
    return render_template('gestiondeseguimiento.html')


# --- PROCESAMIENTO DE DATOS ---

@app.route('/procesar_formulario', methods=['POST'])
def procesar_formulario():
    nombre = request.form['nombre']
    correo = request.form['email']       
    password = request.form['contrasena'] 
    
    usuario_valido = verificar_usuario(nombre, correo, password)
    
    if usuario_valido:
        session['user_email'] = usuario_valido['correo']
        return redirect(url_for('cuenta'))
    
    return render_template('gestiondeusuarios.html', error_login="Datos incorrectos. Verifica tu usuario, correo y contraseña.")

@app.route('/procesar_registro', methods=['POST'])
def procesar_registro():
    nombre = request.form['nombre']
    correo = request.form['correo']      
    password = request.form['password']  
    
    if comprobar_duplicados(nombre, correo):
        return render_template('gestiondeusuarios.html', error_registro="El nombre de usuario o correo ya se encuentra registrado.")
    
    insertar_usuario(nombre, correo, password)
    session['user_email'] = correo 
    
    # 🌟 MENSAJE FLASH DE ÉXITO AL CREAR LA CUENTA
    flash('¡Tu cuenta ha sido creada con éxito! Bienvenido a EcoGreen.', 'success')
    
    return redirect(url_for('cuenta'))


@app.route('/actualizar_nombre', methods=['POST'])
def actualizar_nombre():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    nuevo_nombre = request.form['nuevo_nombre']
    correo_actual = session['user_email']
    
    actualizar_nombre_db(correo_actual, nuevo_nombre)
    return redirect(url_for('cuenta'))

@app.route('/actualizar_password', methods=['POST'])
def actualizar_password():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    nueva_password = request.form['nueva_password']
    correo_actual = session['user_email']
    
    actualizar_password_db(correo_actual, nueva_password)
    return redirect(url_for('cuenta'))


@app.route('/mostrar_datos')
def mostrar_datos():
    conn = None
    cursor = None
    lista_usuarios = []
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        cursor.execute('SELECT id_usuario, nombre, correo FROM usuarios')
        lista_usuarios = cursor.fetchall()
    except mysql.connector.Error as err:
        print(f"Error al mostrar datos: {err}")
    finally:
        if cursor: cursor.close()
        if conn: conn.close()
    return render_template('gestiondeusuarios.html', usuarios=lista_usuarios)

@app.route('/cuenta')
def cuenta():
    if 'user_email' not in session:
        return redirect(url_for('formulario'))
    
    correo_actual = session['user_email']
    conn = None
    cursor = None
    usuario = None

    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True) 
        cursor.execute('SELECT nombre, correo FROM usuarios WHERE correo = %s', (correo_actual,))
        usuario = cursor.fetchone()
    except mysql.connector.Error as err:
        print(f"Error al obtener la cuenta: {err}")
    finally:
        if cursor: cursor.close()
        if conn: conn.close()

    if usuario:
        return render_template('cuenta.html', nombre_usuario=usuario['nombre'], correo_usuario=usuario['correo'])
    
    session.clear()
    return redirect(url_for('formulario'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)