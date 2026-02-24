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
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "❌ Error: Faltan variables en .env"
    echo "   Se requieren: DB_USER, DB_PASSWORD"
    exit 1
fi

echo "   ✅ Usuario: $DB_USER"
echo ""

# Detectar todos los schemas/databases en los archivos SQL
echo "🔍 Detectando schemas en archivos SQL..."

# Buscar CREATE DATABASE y USE statements
DATABASES=$(grep -hioE "(CREATE DATABASE|USE) (IF NOT EXISTS )?[\`]?[a-zA-Z0-9_]+[\`]?" Creaciones/*.sql 2>/dev/null | \
           grep -ioE "[\`]?[a-zA-Z0-9_]+[\`]?$" | \
           tr -d '`' | \
           grep -vE "^(IF|NOT|EXISTS)$" | \
           sort -u)

if [ -z "$DATABASES" ]; then
    echo "   ⚠️  No se detectaron schemas en los archivos SQL"
    echo "   Asegúrate de que tus archivos SQL tengan CREATE DATABASE o USE"
    DATABASES=""
else
    echo "   ✅ Schemas detectados:"
    for db in $DATABASES; do
        echo "      - $db"
    done
fi

echo ""

# Generar el script de creación de usuario
echo "🔨 Generando script de creación de usuario..."

cat > Creaciones/ZZ-create-user.sql <<EOF
-- Script de inicialización para crear el usuario de solo lectura
-- Este archivo se genera automáticamente - NO EDITAR MANUALMENTE
-- Edita el archivo .env y ejecuta ./preparar.sh

-- Crear el usuario ${DB_USER}
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';

EOF

# Agregar permisos para cada schema detectado
if [ -n "$DATABASES" ]; then
    for db in $DATABASES; do
        cat >> Creaciones/ZZ-create-user.sql <<EOF
-- Otorgar permisos de solo lectura en el schema: ${db}
GRANT SELECT ON ${db}.* TO '${DB_USER}'@'%';

EOF
    done
else
    cat >> Creaciones/ZZ-create-user.sql <<EOF
-- No se detectaron schemas automáticamente
-- Si necesitas dar permisos específicos, edita este archivo después de la primera ejecución
-- o agrega GRANT SELECT ON nombre_schema.* TO '${DB_USER}'@'%';

EOF
fi

cat >> Creaciones/ZZ-create-user.sql <<EOF
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
if [ -n "$DATABASES" ]; then
    echo "📊 El usuario '$DB_USER' tendrá acceso SELECT a:"
    for db in $DATABASES; do
        echo "   - $db"
    done
    echo ""
fi
echo "🚀 Para iniciar el servidor, ejecuta:"
echo "   docker compose up -d"
echo ""
echo "📊 Para verificar el estado:"
echo "   docker compose ps"
echo "   docker logs bbdd_alumnos"
echo ""
