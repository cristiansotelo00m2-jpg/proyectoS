CREATE DATABASE IF NOT EXISTS rigistration_db;
USR registration_db;
CREATE TABLE users {
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
};

CREATE TABLE products {
    id INT AUTO_INCREMENT PRIMARY KEY,
    products_name VARCHAR(50) NOT NULL,
    praducts_stock VARCHAR(50) NOT NULL,
    price_products VARCHAR(100) NOT NULL,
    categoria_products VARCHAR(50) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
};

CREATE TABLE envio {
    id INT AUTO_INCREMENT PRIMARY KEY,
    direccion VARCHAR(50) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
};


CREATE USER IF NOR EXISTS "rooty"@"localhost" IDENTIFIED BY "password";

GRANT ALL PRIVILEGES ON registration_db.* TO "rooty"@<"localhost";

FLUSH PRIVILEGES;