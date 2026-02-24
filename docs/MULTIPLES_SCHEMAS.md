# Sistema de Múltiples Schemas/Bases de Datos

Este servidor MySQL puede alojar **múltiples schemas (bases de datos)** simultáneamente, y el usuario de solo lectura (`dam`) tendrá acceso a **TODOS** ellos automáticamente.

## ¿Qué es un Schema?

En MySQL, un **schema** es sinónimo de **database** (base de datos). Son espacios de nombres separados que pueden contener sus propias tablas, vistas, procedimientos, etc.

## Cómo Funciona

### 1. Agregar Archivos SQL

Simplemente coloca tus archivos SQL en la carpeta `Creaciones/`:

```
Creaciones/
├── tienda_calzado.sql       ← Schema: tienda_calzado
├── biblioteca.sql            ← Schema: biblioteca  
├── hospital.sql              ← Schema: hospital
├── escuela.sql               ← Schema: escuela
└── ZZ-create-user.sql        ← Generado automáticamente
```

### 2. Formato de los Archivos SQL

Cada archivo debe **crear y usar su propio schema**:

```sql
-- archivo: biblioteca.sql

CREATE DATABASE IF NOT EXISTS biblioteca;
USE biblioteca;

-- Tus tablas aquí
CREATE TABLE libros (...);
CREATE TABLE autores (...);
-- etc.
```

### 3. Detección Automática

Al ejecutar `./scripts/preparar.sh`, el script:
- ✅ Escanea todos los archivos `.sql` en `Creaciones/`
- ✅ Detecta automáticamente los schemas definidos
- ✅ Genera permisos para el usuario en **TODOS** los schemas

Ejemplo de salida:

```bash
$ ./scripts/preparar.sh

🔍 Detectando schemas en archivos SQL...
   ✅ Schemas detectados:
      - tienda_calzado
      - biblioteca
      - hospital
      - escuela

📊 El usuario 'dam' tendrá acceso SELECT a:
   - tienda_calzado
   - biblioteca
   - hospital
   - escuela
```

## Uso por los Alumnos

Los alumnos se conectan con las mismas credenciales y pueden acceder a **TODOS** los schemas:

```sql
-- Ver todos los schemas disponibles
SHOW DATABASES;

-- Resultados:
-- +----------------------+
-- | Database             |
-- +----------------------+
-- | information_schema   |
-- | biblioteca           |
-- | escuela              |
-- | hospital             |
-- | tienda_calzado       |
-- +----------------------+

-- Cambiar entre schemas
USE tienda_calzado;
SELECT * FROM TIENDAS;

USE biblioteca;
SELECT * FROM libros;

USE hospital;
SELECT * FROM pacientes;
```

## Ejemplos Prácticos

### Ejemplo 1: Agregar Schema de Biblioteca

```bash
# 1. Colocar el archivo
cp ~/Downloads/biblioteca.sql Creaciones/

# 2. Preparar (detecta automáticamente)
./scripts/preparar.sh

# 3. Aplicar cambios
docker compose down -v && docker compose up -d
```

### Ejemplo 2: Agregar Múltiples Schemas de Golpe

```bash
# Copiar varios archivos
cp ~/curso/*.sql Creaciones/

# Preparar (detecta todos automáticamente)
./scripts/preparar.sh

# Aplicar
docker compose down -v && docker compose up -d
```

## Ventajas de Múltiples Schemas

✅ **Un solo servidor** para todas tus bases de datos de ejemplo  
✅ **Una sola IP/Puerto** para que los alumnos se conecten  
✅ **Un solo usuario** con acceso a todo  
✅ **Detección automática** - no necesitas configurar nada manualmente  
✅ **Fácil cambio** entre diferentes bases de datos para ejercicios  

## Estructura del Archivo ZZ-create-user.sql Generado

Después de ejecutar `./scripts/preparar.sh` con múltiples schemas:

```sql
-- ZZ-create-user.sql (generado automáticamente)

CREATE USER IF NOT EXISTS 'dam'@'%' IDENTIFIED WITH mysql_native_password BY 'dam123';

-- Permisos para cada schema detectado
GRANT SELECT ON tienda_calzado.* TO 'dam'@'%';
GRANT SELECT ON biblioteca.* TO 'dam'@'%';
GRANT SELECT ON hospital.* TO 'dam'@'%';
GRANT SELECT ON escuela.* TO 'dam'@'%';

FLUSH PRIVILEGES;
```

## Orden de Ejecución

Los archivos SQL se ejecutan en **orden alfabético**:

```
01-tienda.sql          ← Se ejecuta primero
02-biblioteca.sql      ← Luego este
03-hospital.sql        ← Luego este
ZZ-create-user.sql     ← Siempre al final
```

💡 **Tip**: Usa prefijos numéricos si necesitas controlar el orden.

## Eliminar un Schema

Para dejar de cargar un schema:

```bash
# Opción 1: Renombrar (deshabilitar temporalmente)
mv Creaciones/biblioteca.sql Creaciones/biblioteca.sql.disabled

# Opción 2: Eliminar permanentemente
rm Creaciones/biblioteca.sql

# Regenerar permisos
./scripts/preparar.sh

# Aplicar cambios
docker compose down -v && docker compose up -d
```

## Notas Importantes

⚠️ **Los schemas son independientes**: Cada uno tiene sus propias tablas y datos  
⚠️ **No hay relaciones entre schemas**: Los FOREIGN KEY solo funcionan dentro del mismo schema  
⚠️ **Reiniciar borra datos**: `docker compose down -v` elimina TODOS los datos de TODOS los schemas  
✅ **Solo lectura**: Los alumnos solo pueden hacer SELECT, no INSERT/UPDATE/DELETE  

## Ejemplo Completo

Ver el archivo `EjemploBiblioteca.sql.example` en la carpeta `Creaciones/` para un ejemplo completo de cómo estructurar un archivo SQL con su propio schema.

Para usarlo:
```bash
cp Creaciones/EjemploBiblioteca.sql.example Creaciones/biblioteca.sql
./scripts/preparar.sh
docker compose down -v && docker compose up -d
```
