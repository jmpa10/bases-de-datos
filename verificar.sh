#!/bin/bash

echo "=========================================="
echo "Verificación del Servidor de Base de Datos"
echo "=========================================="
echo ""

# Verificar que el contenedor está corriendo
echo "1. Verificando estado del contenedor..."
if docker ps | grep -q bbdd_alumnos; then
    echo "✅ Contenedor bbdd_alumnos está corriendo"
else
    echo "❌ El contenedor no está corriendo. Ejecuta: docker compose up -d"
    exit 1
fi

echo ""
echo "2. Verificando conexión a la base de datos..."
# Verificar que MySQL está respondiendo
if docker exec bbdd_alumnos mysqladmin ping -h localhost -uroot -prootpassword123 &> /dev/null; then
    echo "✅ MySQL está respondiendo"
else
    echo "❌ MySQL no responde"
    exit 1
fi

echo ""
echo "3. Verificando que la base de datos existe..."
DB_EXISTS=$(docker exec bbdd_alumnos mysql -uroot -prootpassword123 -e "SHOW DATABASES LIKE 'tienda_calzado';" | grep tienda_calzado)
if [ -n "$DB_EXISTS" ]; then
    echo "✅ Base de datos 'tienda_calzado' existe"
else
    echo "❌ Base de datos 'tienda_calzado' no encontrada"
    exit 1
fi

echo ""
echo "4. Verificando usuario 'dam'..."
USER_EXISTS=$(docker exec bbdd_alumnos mysql -uroot -prootpassword123 -e "SELECT User FROM mysql.user WHERE User='dam';" | grep dam)
if [ -n "$USER_EXISTS" ]; then
    echo "✅ Usuario 'dam' existe"
else
    echo "❌ Usuario 'dam' no encontrado"
    exit 1
fi

echo ""
echo "5. Probando conexión con usuario 'dam'..."
if docker exec bbdd_alumnos mysql -udam -pdam123 -e "USE tienda_calzado; SELECT COUNT(*) FROM TIENDAS;" &> /dev/null; then
    echo "✅ Usuario 'dam' puede conectarse y consultar"
else
    echo "❌ Usuario 'dam' no puede conectarse"
    exit 1
fi

echo ""
echo "6. Verificando que el usuario tiene solo permisos de lectura..."
if docker exec bbdd_alumnos mysql -udam -pdam123 -e "USE tienda_calzado; INSERT INTO POBLACIONES VALUES ('00000', 'Test', 'Test');" 2>&1 | grep -q "denied"; then
    echo "✅ Usuario 'dam' NO puede insertar datos (correcto)"
else
    echo "⚠️  Advertencia: El usuario 'dam' podría tener más permisos de los esperados"
fi

echo ""
echo "7. Información del servidor:"
MYSQL_VERSION=$(docker exec bbdd_alumnos mysql -V)
echo "   MySQL: $MYSQL_VERSION"

echo ""
echo "=========================================="
echo "✨ Verificación completada con éxito"
echo "=========================================="
echo ""
echo "Datos de conexión para los alumnos:"
echo "-----------------------------------"
echo "Host: $(hostname -I | awk '{print $1}') (o la IP pública del servidor)"
echo "Puerto: 3306"
echo "Base de datos: tienda_calzado"
echo "Usuario: dam"
echo "Contraseña: dam123"
echo ""
echo "Ejemplo de conexión:"
echo "mysql -h $(hostname -I | awk '{print $1}') -P 3306 -u dam -pdam123 tienda_calzado"
echo ""
