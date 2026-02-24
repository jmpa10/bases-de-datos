# Servidor de Base de Datos para Alumnos

Este proyecto despliega un servidor MySQL con Docker Compose para que los alumnos puedan conectarse y realizar consultas.

**✨ Sistema flexible con múltiples schemas**: 
- Despliega **todos los schemas/bases de datos** que agregues a la carpeta `Creaciones/`
- Detección automática de schemas en archivos SQL
- El usuario de solo lectura tiene acceso a **TODOS** los schemas automáticamente

## Configuración Inicial

### 1. Crear archivo de configuración
```bash
cp .env.example .env
```

### 2. Editar la configuración
Abre el archivo `.env` y configura:
- `DB_USER`: Usuario de solo lectura para los alumnos
- `DB_PASSWORD`: Contraseña del usuario
- `MYSQL_PORT`: Puerto a exponer (por defecto 3306)
- `MYSQL_ROOT_PASSWORD`: Contraseña de root (para administración)

**No necesitas especificar nombres de bases de datos** - se detectan automáticamente desde los archivos SQL.

### 3. Preparar los archivos
```bash
chmod +x preparar.sh
./preparar.sh
```

Este script:
- Detecta automáticamente todos los schemas en tus archivos SQL
- Genera el archivo de creación de usuario con permisos para TODOS los schemas

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

## Agregar Nuevos Schemas/Bases de Datos

### Opción 1: Script Asistido (Recomendado)
```bash
chmod +x agregar-bd.sh
./agregar-bd.sh
```

El script te guiará paso a paso y verificará que el archivo SQL contenga las definiciones necesarias.

### Opción 2: Manual

1. **Copia tu archivo SQL a la carpeta Creaciones/**
   ```bash
   cp /ruta/a/tu/archivo.sql Creaciones/
   ```

2. **Asegúrate de que el archivo SQL defina el schema**
   
   El archivo debe incluir:
   ```sql
   -- Al inicio del archivo
   CREATE DATABASE IF NOT EXISTS nombre_schema;
   USE nombre_schema;
   
   -- Luego tus tablas y datos...
   CREATE TABLE mi_tabla (
       id INT PRIMARY KEY,
       ...
   );
   ```

3. **Prepara los archivos (detecta schemas automáticamente)**
   ```bash
   ./preparar.sh
   ```
   
   Este comando detectará automáticamente el nuevo schema y agregará los permisos.

4. **Reinicia el contenedor**
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

## Múltiples Schemas Simultáneos

**✨ Todos los schemas se despliegan simultáneamente:**

Si tienes múltiples archivos SQL en `Creaciones/`:

```
Creaciones/
├── tienda_calzado.sql      → Crea schema 'tienda_calzado'
├── biblioteca.sql          → Crea schema 'biblioteca'
├── hospital.sql            → Crea schema 'hospital'
└── ZZ-create-user.sql      → Generado automáticamente
```

Todos se crean y están disponibles simultáneamente. Los alumnos pueden:

```sql
-- Ver todos los schemas disponibles
SHOW DATABASES;

-- Cambiar entre schemas
USE tienda_calzado;
SELECT * FROM TIENDAS;

USE biblioteca;
SELECT * FROM libros;
```

**Cada vez que agregues un nuevo archivo SQL:**
1. Ejecuta `./preparar.sh` para actualizar permisos
2. Reinicia: `docker compose down -v && docker compose up -d`

**⚠️ Advertencia**: `docker compose down -v` eliminará todos los datos existentes.
