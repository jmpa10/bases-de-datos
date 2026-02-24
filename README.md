# Servidor de Base de Datos para Alumnos

Este proyecto despliega una base de datos MySQL con Docker Compose para que los alumnos puedan conectarse y realizar consultas.

**✨ Sistema flexible**: Puedes desplegar cualquier base de datos simplemente agregando el archivo SQL a la carpeta `Creaciones/` y configurando el archivo `.env`

## Configuración Inicial

### 1. Crear archivo de configuración
```bash
cp .env.example .env
```

### 2. Editar la configuración
Abre el archivo `.env` y configura:
- `DB_NAME`: Nombre de la base de datos a crear
- `DB_USER`: Usuario de solo lectura para los alumnos
- `DB_PASSWORD`: Contraseña del usuario
- `MYSQL_PORT`: Puerto a exponer (por defecto 3306)

### 3. Preparar los archivos
```bash
chmod +x preparar.sh
./preparar.sh
```

Este script generará automáticamente el archivo de creación de usuario basándose en tu configuración.

## Datos de Conexión para los Alumnos

- **Host**: 192.168.5.21
- **Puerto**: `3306`
- **Base de datos**: `tienda_calzado`
- **Usuario**: `dam`
- **Contraseña**: `dam123`

## Instrucciones de Despliegue

### 1. Iniciar el servidor
En el directorio del proyecto, ejecuta:
```bash
docker compose up -d
```

### 2. Verificar que el contenedor está funcionando
```bash
docker compose ps
```

### 3. Ver los logs (opcional)
```bash
docker compose logs -f
```

### 4. Detener el servidor
```bash
docker compose down
```

### 5. Detener y eliminar todos los datos
```bash
docker compose down -v
```

## Conexión desde MySQL Workbench o línea de comandos

### MySQL Workbench
1. Crear una nueva conexión
2. Hostname: `192.168.5.21`
3. Port: `3306`
4. Username: `dam`
5. Password: `dam123` (Store in Keychain)
6. Default Schema: `tienda_calzado`

### Línea de comandos
```bash
mysql -h 192.168.5.21 -P 3306 -u dam -pdam123 tienda_calzado
```

## Permisos del Usuario

El usuario `dam` **SOLO** tiene permisos de lectura (`SELECT`). Los alumnos podrán:
- ✅ Consultar datos (SELECT)
- ❌ No podrán insertar datos (INSERT)
- ❌ No podrán modificar datos (UPDATE)
- ❌ No podrán eliminar datos (DELETE)
- ❌ No podrán crear/modificar tablas (CREATE/ALTER/DROP)

## Base de Datos

La base de datos contiene información sobre una cadena de tiendas de calzado con las siguientes tablas:
- `POBLACIONES`: Códigos postales y localidades
- `TIENDAS`: Tiendas de la cadena
- `PROVEEDORES`: Proveedores de calzado
- `ZAPATOS`: Catálogo de zapatos
- `VENTAS`: Registro de ventas
- `LINEASVENTA`: Detalle de productos vendidos
- `FACTURAS`: Facturas de proveedores
- `LINEASFACTURA`: Detalle de facturas
- `PAGOS`: Pagos realizados a proveedores

## Notas Importantes

- El contenedor se reiniciará automáticamente si el servidor se reinicia
- Los datos persisten entre reinicios del contenedor
- Para resetear los datos, detén el contenedor y elimina el volumen con `docker compose down -v`
- Asegúrate de que el puerto 3306 esté abierto en el firewall del servidor

## Agregar una Nueva Base de Datos

### Opción 1: Script Asistido (Recomendado)
```bash
chmod +x agregar-bd.sh
./agregar-bd.sh
```

El script te guiará paso a paso.

### Opción 2: Manual

1. **Copia tu archivo SQL a la carpeta Creaciones/**
   ```bash
   cp /ruta/a/tu/archivo.sql Creaciones/
   ```

2. **Asegúrate de que el archivo SQL use el nombre correcto de la base de datos**
   
   El archivo debe incluir:
   ```sql
   -- Al inicio del archivo
   USE nombre_base_datos;
   
   -- O crear la base de datos si no existe
   CREATE DATABASE IF NOT EXISTS nombre_base_datos;
   USE nombre_base_datos;
   ```

3. **Actualiza el archivo .env**
   ```bash
   DB_NAME=nombre_base_datos
   ```

4. **Prepara los archivos**
   ```bash
   ./preparar.sh
   ```

5. **Reinicia el contenedor**
   ```bash
   docker compose down -v
   docker compose up -d
   ```

### Convenciones de Nombres

Los archivos SQL en `Creaciones/` se ejecutan en **orden alfabético**:
- `01-crear-tablas.sql` se ejecuta primero
- `02-insertar-datos.sql` se ejecuta después
- `ZZ-create-user.sql` se ejecuta al final (generado automáticamente)

**💡 Tip**: Usa prefijos numéricos para controlar el orden de ejecución.

## Cambiar entre Diferentes Bases de Datos

Si tienes múltiples archivos SQL en `Creaciones/`:

1. Edita `.env` y cambia `DB_NAME` al nombre de la base de datos que deseas usar
2. Ejecuta `./preparar.sh` para regenerar el script de usuario
3. Reinicia el contenedor: `docker compose down -v && docker compose up -d`

**⚠️ Advertencia**: `docker compose down -v` eliminará todos los datos existentes.
