import os
import sys
import ssl

def main():
    print("Iniciando importación a la base de datos de Aiven...")
    
    # Credenciales de conexión
    host = os.environ.get('DB_HOST', 'mysql-2484a5be-cristiansotelo-6b14.f.aivencloud.com')
    port = int(os.environ.get('DB_PORT', 23508))
    user = os.environ.get('DB_USER', 'avnadmin')
    # Nota: la contraseña de Aiven contiene la letra 'O' mayúscula (AVNS_ODHeoLTFT_oJbSwVKam)
    password = os.environ.get('DB_PASSWORD', 'AVNS_ODHeoLTFT_oJbSwVKam')
    database = os.environ.get('DB_NAME', 'EcoGreen')
    
    sql_file_path = os.path.join(os.path.dirname(__file__), 'SQL', 'database.sql')
    if not os.path.exists(sql_file_path):
        print(f"Error: No se encontró el archivo {sql_file_path}")
        sys.exit(1)
        
    with open(sql_file_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()
        
    print(f"Archivo SQL cargado: {len(sql_content)} bytes")
    
    conn = None
    try:
        # Intentamos con mysql.connector primero
        import mysql.connector
        print(f"Conectando con mysql.connector a {host}:{port}/{database} (SSL activo)...")
        conn = mysql.connector.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database,
            ssl_disabled=False
        )
        cursor = conn.cursor()
        print("Ejecutando sentencias SQL desde SQL/database.sql...")
        for result in cursor.execute(sql_content, multi=True):
            pass
        conn.commit()
        print("¡Sentencias ejecutadas con éxito con mysql.connector!")
    except Exception as e1:
        print(f"Aviso con mysql.connector ({e1}), intentando con pymysql...")
        try:
            import pymysql
            import pymysql.constants.CLIENT
            ssl_ctx = ssl.create_default_context()
            ssl_ctx.check_hostname = False
            ssl_ctx.verify_mode = ssl.CERT_NONE
            
            conn = pymysql.connect(
                host=host,
                port=port,
                user=user,
                password=password,
                database=database,
                ssl=ssl_ctx,
                client_flag=pymysql.constants.CLIENT.MULTI_STATEMENTS
            )
            with conn.cursor() as cur:
                cur.execute(sql_content)
            conn.commit()
            print("¡Sentencias ejecutadas con éxito con pymysql!")
        except Exception as e2:
            print(f"Error fatal al ejecutar con pymysql: {e2}")
            sys.exit(1)
            
    # Verificación de tablas importadas
    try:
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES;")
        tables = [row[0] if isinstance(row, (tuple, list)) else list(row.values())[0] for row in cursor.fetchall()]
        print(f"\nTablas encontradas en '{database}':")
        for t in tables:
            cursor.execute(f"SELECT COUNT(*) FROM `{t}`;")
            count = cursor.fetchone()
            c_val = count[0] if isinstance(count, (tuple, list)) else list(count.values())[0]
            print(f"  - {t}: {c_val} registros")
        cursor.close()
        conn.close()
        print("\n¡Importación completada y verificada exitosamente!")
    except Exception as e:
        print(f"Error verificando tablas: {e}")

if __name__ == '__main__':
    main()
