-- Script de inicialización para crear el usuario de solo lectura
-- Este archivo se ejecuta automáticamente al iniciar el contenedor

-- Crear el usuario dam con contraseña dam123
CREATE USER IF NOT EXISTS 'dam'@'%' IDENTIFIED WITH mysql_native_password BY 'dam123';

-- Otorgar permisos de solo lectura (SELECT) en la base de datos tienda_calzado
GRANT SELECT ON tienda_calzado.* TO 'dam'@'%';

-- Aplicar los cambios
FLUSH PRIVILEGES;
