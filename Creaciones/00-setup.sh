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

# Generar el script SQL en /tmp (el directorio Creaciones/ puede ser read-only)
TMP_SQL="/tmp/create-user-$$.sql"

cat > "$TMP_SQL" <<EOF
-- Script de inicialización para crear el usuario de solo lectura
-- Este archivo se genera automáticamente al iniciar el contenedor

-- Crear el usuario $USER para conexiones remotas y locales
CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED WITH mysql_native_password BY '$PASS';
CREATE USER IF NOT EXISTS '$USER'@'localhost' IDENTIFIED WITH mysql_native_password BY '$PASS';

EOF

# Agregar permisos para cada schema detectado
if [ -n "$DATABASES" ]; then
    for db in $DATABASES; do
        cat >> "$TMP_SQL" <<EOF
-- Otorgar permisos de solo lectura en el schema: ${db}
GRANT SELECT ON ${db}.* TO '$USER'@'%';
GRANT SELECT ON ${db}.* TO '$USER'@'localhost';

EOF
    done
else
    cat >> "$TMP_SQL" <<EOF
-- No se detectaron schemas automáticamente
-- El usuario se creó sin permisos específicos

EOF
fi

cat >> "$TMP_SQL" <<EOF
-- Aplicar los cambios
FLUSH PRIVILEGES;

-- Confirmar creación
SELECT CONCAT('✅ Usuario $USER creado con permisos de solo lectura') AS Estado;
EOF

echo "   ✅ Script generado: $TMP_SQL"

# También generar una copia de referencia (si tenemos permisos)
cat "$TMP_SQL" > "$SQL_DIR/ZZZ-create-user.sql" 2>/dev/null || true

echo ""

if [ -n "$DATABASES" ]; then
    echo "📊 El usuario '$USER' tendrá acceso SELECT a:"
    for db in $DATABASES; do
        echo "   - $db"
    done
    echo ""
fi

# 🔥 EJECUTAR el archivo SQL generado inmediatamente
echo "🔧 Ejecutando script de creación de usuario..."
if [ -f "$TMP_SQL" ]; then
    # Esperar a que MySQL esté listo (usa socket unix durante init)
    echo "   ⏳ Esperando a que MySQL esté listo..."
    for i in {1..30}; do
        if mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
            echo "   ✅ MySQL está listo"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "   ⚠️  Timeout esperando a MySQL"
            exit 1
        fi
        sleep 1
    done
    
    # Ejecutar el SQL usando socket unix (más confiable durante init)
    echo "   📝 Creando usuario y permisos..."
    if mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" < "$TMP_SQL" 2>&1 | grep -v "Warning.*password"; then
        echo "   ✅ Usuario y permisos configurados correctamente"
    else
        echo "   ⚠️  Hubo un problema al crear el usuario"
        # Mostrar el contenido del archivo para debug
        echo "   📄 Contenido del SQL generado:"
        cat "$TMP_SQL"
    fi
    
    # Limpiar archivo temporal
    rm -f "$TMP_SQL"
fi

echo ""
echo "=========================================="
echo "✅ Configuración completada"
echo "=========================================="
echo ""
echo "Continuando con la inicialización de MySQL..."
echo ""
