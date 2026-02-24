#!/bin/bash

# Script de preparación del servidor de base de datos
# Este script prepara los archivos necesarios antes de levantar el contenedor

set -e  # Salir si hay algún error

echo "=========================================="
echo "🔧 Preparación del Servidor de BBDD"
echo "=========================================="
echo ""

# Verificar que existe el archivo .env
if [ ! -f ".env" ]; then
    echo "❌ Error: No se encontró el archivo .env"
    echo ""
    echo "📝 Crea el archivo .env copiando .env.example:"
    echo "   cp .env.example .env"
    echo ""
    echo "Luego edita .env con tus configuraciones."
    exit 1
fi

# Cargar variables de entorno
echo "📖 Leyendo configuración desde .env..."
source .env

# Validar que las variables existen
if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "❌ Error: Faltan variables en .env"
    echo "   Se requieren: DB_NAME, DB_USER, DB_PASSWORD"
    exit 1
fi

echo "   ✅ Base de datos: $DB_NAME"
echo "   ✅ Usuario: $DB_USER"
echo ""

# Generar el script de creación de usuario
echo "🔨 Generando script de creación de usuario..."

cat > Creaciones/ZZ-create-user.sql <<EOF
-- Script de inicialización para crear el usuario de solo lectura
-- Este archivo se genera automáticamente - NO EDITAR MANUALMENTE
-- Edita el archivo .env y ejecuta ./preparar.sh

-- Crear el usuario ${DB_USER} con contraseña ${DB_PASSWORD}
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';

-- Otorgar permisos de solo lectura (SELECT) en la base de datos ${DB_NAME}
GRANT SELECT ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- Aplicar los cambios
FLUSH PRIVILEGES;
EOF

echo "   ✅ Script generado: Creaciones/ZZ-create-user.sql"
echo ""

# Listar archivos SQL que se ejecutarán
echo "📂 Archivos SQL a ejecutar (en orden):"
for sql_file in Creaciones/*.sql; do
    if [ -f "$sql_file" ]; then
        echo "   - $(basename "$sql_file")"
    fi
done
echo ""

echo "=========================================="
echo "✅ Preparación completada"
echo "=========================================="
echo ""
echo "🚀 Para iniciar el servidor, ejecuta:"
echo "   docker compose up -d"
echo ""
echo "📊 Para verificar el estado:"
echo "   docker compose ps"
echo "   docker logs bbdd_alumnos"
echo ""
