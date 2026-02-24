#!/bin/bash

# Script de configuración automática que se ejecuta al iniciar el contenedor MySQL
# Este script detecta schemas y genera el usuario con permisos automáticamente

set -e

echo "=========================================="
echo "🔧 Configuración automática del servidor"
echo "=========================================="
echo ""

# Directorio donde están los scripts SQL
SQL_DIR="/docker-entrypoint-initdb.d"

# Leer variables de entorno (pasadas desde docker-compose)
USER="${DB_USER:-dam}"
PASS="${DB_PASSWORD:-dam123}"

echo "📖 Usuario configurado: $USER"
echo ""

# Detectar todos los schemas/databases en los archivos SQL
echo "🔍 Detectando schemas en archivos SQL..."

# Buscar CREATE DATABASE y USE statements (excluyendo este script y el archivo de usuario)
DATABASES=$(grep -hioE "(CREATE DATABASE|USE) (IF NOT EXISTS )?[\`]?[a-zA-Z0-9_]+[\`]?" "$SQL_DIR"/*.sql 2>/dev/null | \
           grep -ioE "[\`]?[a-zA-Z0-9_]+[\`]?$" | \
           tr -d '`' | \
           grep -vE "^(IF|NOT|EXISTS|mysql|information_schema|performance_schema|sys)$" | \
           sort -u || echo "")

if [ -z "$DATABASES" ]; then
    echo "   ⚠️  No se detectaron schemas en los archivos SQL"
    echo "   Se creará el usuario sin permisos específicos"
    DATABASES=""
else
    echo "   ✅ Schemas detectados:"
    for db in $DATABASES; do
        echo "      - $db"
    done
fi

echo ""
echo "🔨 Generando script de creación de usuario..."

# Generar el script de creación de usuario
cat > "$SQL_DIR/ZZZ-create-user.sql" <<EOF
-- Script de inicialización para crear el usuario de solo lectura
-- Este archivo se genera automáticamente al iniciar el contenedor
-- NO EDITAR - se regenera cada vez que se recrea el contenedor

-- Crear el usuario $USER
CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED WITH mysql_native_password BY '$PASS';

EOF

# Agregar permisos para cada schema detectado
if [ -n "$DATABASES" ]; then
    for db in $DATABASES; do
        cat >> "$SQL_DIR/ZZZ-create-user.sql" <<EOF
-- Otorgar permisos de solo lectura en el schema: ${db}
GRANT SELECT ON ${db}.* TO '$USER'@'%';

EOF
    done
else
    cat >> "$SQL_DIR/ZZZ-create-user.sql" <<EOF
-- No se detectaron schemas automáticamente
-- El usuario se creó sin permisos específicos

EOF
fi

cat >> "$SQL_DIR/ZZZ-create-user.sql" <<EOF
-- Aplicar los cambios
FLUSH PRIVILEGES;

-- Confirmar creación
SELECT CONCAT('✅ Usuario $USER creado con permisos de solo lectura') AS Estado;
EOF

echo "   ✅ Script generado: ZZZ-create-user.sql"
echo ""

if [ -n "$DATABASES" ]; then
    echo "📊 El usuario '$USER' tendrá acceso SELECT a:"
    for db in $DATABASES; do
        echo "   - $db"
    done
    echo ""
fi

echo "=========================================="
echo "✅ Configuración completada"
echo "=========================================="
echo ""
echo "Continuando con la inicialización de MySQL..."
echo ""
