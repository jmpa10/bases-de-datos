#!/bin/bash

# Script para agregar una nueva base de datos al servidor

set -e

echo "=========================================="
echo "📦 Agregar Nuevo Schema/Base de Datos"
echo "=========================================="
echo ""

# Preguntar por el archivo SQL
echo "📄 Ingresa la ruta al archivo SQL de la base de datos:"
read -r sql_file

# Verificar que el archivo existe
if [ ! -f "$sql_file" ]; then
    echo "❌ Error: El archivo '$sql_file' no existe"
    exit 1
fi

# Obtener el nombre base del archivo
filename=$(basename "$sql_file")

# Copiar el archivo a la carpeta Creaciones
echo ""
echo "📋 Copiando archivo a Creaciones/$filename..."
cp "$sql_file" "Creaciones/$filename"

echo "   ✅ Archivo copiado"
echo ""

# Verificar si el archivo tiene CREATE DATABASE o USE
echo "🔍 Verificando contenido del archivo SQL..."
if grep -qiE "(CREATE DATABASE|USE) " "Creaciones/$filename"; then
    echo "   ✅ El archivo contiene definiciones de schema/database"
    # Mostrar los schemas detectados
    SCHEMAS=$(grep -hioE "(CREATE DATABASE|USE) (IF NOT EXISTS )?[\`]?[a-zA-Z0-9_]+[\`]?" "Creaciones/$filename" | \
             grep -ioE "[\`]?[a-zA-Z0-9_]+[\`]?$" | \
             tr -d '`' | \
             grep -vE "^(IF|NOT|EXISTS)$" | \
             sort -u)
    
    if [ -n "$SCHEMAS" ]; then
        echo "   📊 Schemas detectados en el archivo:"
        for schema in $SCHEMAS; do
            echo "      - $schema"
        done
    fi
else
    echo "   ⚠️  Advertencia: No se detectó CREATE DATABASE ni USE en el archivo"
    echo "   💡 Asegúrate de agregar al inicio de tu archivo SQL:"
    echo ""
    echo "      CREATE DATABASE IF NOT EXISTS nombre_schema;"
    echo "      USE nombre_schema;"
    echo ""
fi

echo ""
echo "=========================================="
echo "✅ Schema agregado"
echo "=========================================="
echo ""
echo "📝 Próximos pasos:"
echo "   1. Ejecuta: ./preparar.sh (para detectar schemas y generar permisos)"
echo "   2. Reinicia el contenedor: docker compose down -v && docker compose up -d"
echo ""
echo "💡 El usuario '$DB_USER' (definido en .env) tendrá acceso SELECT a TODOS los schemas"
echo ""
