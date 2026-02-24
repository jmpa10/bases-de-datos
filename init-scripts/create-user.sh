#!/bin/bash
# Script de inicialización para crear el usuario de solo lectura

mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
    -- Crear el usuario dam con contraseña dam123
    CREATE USER IF NOT EXISTS 'dam'@'%' IDENTIFIED BY 'dam123';
    
    -- Otorgar permisos de solo lectura (SELECT) en la base de datos tienda_calzado
    GRANT SELECT ON tienda_calzado.* TO 'dam'@'%';
    
    -- Aplicar los cambios
    FLUSH PRIVILEGES;
    
    -- Confirmar la creación del usuario
    SELECT 'Usuario dam creado correctamente con permisos de solo lectura' AS mensaje;
EOSQL
