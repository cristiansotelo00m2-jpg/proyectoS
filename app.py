from flask import Flask, render_template, request, redirect, url_for
import mysql.connector

app = Flask(__name__)

db_config = {
    'host': 'localhost',         
    'user': 'rooty',             
    'password': 'password',     
    'database': 'formulario'    
}

def insertar_usuario(nombre, correo, password):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO usuarios (nombre, correo, password) VALUES (%s, %s, %s)', 
        (nombre, correo, password)
    )
    conn.commit()
    conn.close()

# 1. RUTA RAÍZ (Abre directamente el index al entrar a la IP)
@app.route('/')
def home():
    return render_template('index.html')

# 2. Ruta de Quiénes Somos
@app.route('/quienes_somos')
def quienes_somos():
    return render_template('quienessomos.html')

# 3. Ruta de Gestión de Usuarios (Formulario)
@app.route('/formulario')
def formulario():
    return render_template('gestiondeusuarios.html')

# 4. Ruta de Gestión de Ventas
@app.route('/ventas')
def ventas():
    return render_template('gestiondeventas.html')

# 5. Ruta de Gestión de Seguimiento
@app.route('/seguimiento')
def seguimiento():
    return render_template('gestiondeseguimiento.html')

# --- Rutas de Procesamiento de Formularios ---
@app.route('/procesar_formulario', methods=['POST'])
def procesar_formulario():
    nombre = request.form['nombre']
    correo = request.form['email']       
    password = request.form['contrasena'] 
    insertar_usuario(nombre, correo, password)
    return redirect(url_for('mostrar_datos'))

@app.route('/procesar_registro', methods=['POST'])
def procesar_registro():
    nombre = request.form['nombre']
    correo = request.form['correo']      
    password = request.form['password']  
    insertar_usuario(nombre, correo, password)
    return redirect(url_for('mostrar_datos'))

@app.route('/mostrar_datos')
def mostrar_datos():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute('SELECT id_usuario, nombre, correo FROM usuarios')
    lista_usuarios = cursor.fetchall()
    conn.close()
    return render_template('gestiondeusuarios.html', usuarios=lista_usuarios)

if __name__ == '__main__':
    app.run(debug=True)