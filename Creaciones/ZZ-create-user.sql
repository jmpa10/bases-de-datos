-- Script de inicialización para crear el usuario de solo lectura
-- Este archivo se genera automáticamente - NO EDITAR MANUALMENTE
-- Edita el archivo .env y ejecuta ./preparar.sh

-- Crear el usuario dam
CREATE USER IF NOT EXISTS 'dam'@'%' IDENTIFIED WITH mysql_native_password BY 'dam123';

-- Otorgar permisos de solo lectura en el schema: tienda_calzado
GRANT SELECT ON tienda_calzado.* TO 'dam'@'%';

-- Aplicar los cambios
FLUSH PRIVILEGES;
