#!/bin/bash

# Script para agregar una nueva base de datos al servidor

set -e

echo "=========================================="
echo "📦 Agregar Nueva Base de Datos"
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

# Preguntar por el nombre de la base de datos
echo ""
echo "🏷️  Ingresa el nombre de la base de datos (ej: mi_base_datos):"
read -r db_name

if [ -z "$db_name" ]; then
    echo "❌ Error: El nombre de la base de datos no puede estar vacío"
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

# Preguntar si quiere actualizar el .env
echo "¿Deseas actualizar el archivo .env para usar esta base de datos? (s/n)"
read -r update_env

if [ "$update_env" = "s" ] || [ "$update_env" = "S" ]; then
    # Actualizar DB_NAME en .env
    if [ -f ".env" ]; then
        sed -i.bak "s/^DB_NAME=.*/DB_NAME=$db_name/" .env
        echo "   ✅ Archivo .env actualizado"
        echo "   📝 DB_NAME=$db_name"
    else
        echo "   ⚠️  No se encontró el archivo .env"
        echo "   📝 Crea uno con: cp .env.example .env"
    fi
fi

echo ""
echo "=========================================="
echo "✅ Base de datos agregada"
echo "=========================================="
echo ""
echo "📝 Próximos pasos:"
echo "   1. Edita el archivo Creaciones/$filename si es necesario"
echo "   2. Asegúrate de que el archivo use CREATE DATABASE o USE $db_name"
echo "   3. Ejecuta: ./preparar.sh"
echo "   4. Reinicia el contenedor: docker compose down -v && docker compose up -d"
echo ""
