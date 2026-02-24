# Ejemplo: Agregar una Nueva Base de Datos

Este es un ejemplo práctico de cómo agregar una nueva base de datos al servidor.

## Escenario

Tienes un archivo SQL llamado `biblioteca.sql` que crea una base de datos de una biblioteca con tablas de libros, autores y préstamos.

## Método 1: Proceso Automatizado ⚡ (Recomendado)

```bash
# 1. Copiar el archivo a Creaciones/
cp /home/profesor/descargas/biblioteca.sql Creaciones/

# 2. (Opcional) Renombrar para controlar orden de ejecución
mv Creaciones/biblioteca.sql Creaciones/01-biblioteca.sql

# 3. Verificar que el archivo SQL tenga CREATE DATABASE y USE
nano Creaciones/01-biblioteca.sql
# Debe tener al inicio:
# CREATE DATABASE IF NOT EXISTS biblioteca;
# USE biblioteca;

# 4. Reiniciar el contenedor
docker compose down -v
docker compose up -d
```

**¡Eso es todo!** El sistema detecta automáticamente el nuevo schema y configura los permisos.

## Método 2: Script Asistido

```bash
# 1. Ejecutar el script asistente
./scripts/agregar-bd.sh

# El script te preguntará información y copiará el archivo automáticamente

# 2. Reiniciar el contenedor
docker compose down -v
docker compose up -d
```

## Múltiples Bases de Datos en Creaciones/

Si tienes varios archivos SQL en `Creaciones/`:

```
Creaciones/
├── 00-setup.sh               ← Detecta schemas automáticamente
├── 01-tienda-calzado.sql     ← Schema: tienda_calzado
├── 02-biblioteca.sql         ← Schema: biblioteca
├── 03-hospital.sql           ← Schema: hospital
└── ZZZ-create-user.sql       ← Generado automáticamente
```

**Todos los schemas se despliegan simultáneamente:**

```bash
# Simplemente reinicia el contenedor
docker compose down -v
docker compose up -d
```

**El sistema detecta automáticamente todos los schemas** y los alumnos tendrán acceso a todos ellos.

## Ejemplo Completo de Archivo SQL

```sql
-- Creaciones/biblioteca.sql

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS biblioteca;

-- Usar la base de datos
USE biblioteca;

-- Eliminar tablas si existen (para recrear)
DROP TABLE IF EXISTS prestamos;
DROP TABLE IF EXISTS libros;
DROP TABLE IF EXISTS autores;

-- Crear tablas
CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libros (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    id_autor INT,
    isbn VARCHAR(13),
    anio_publicacion YEAR,
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

CREATE TABLE prestamos (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_libro INT,
    nombre_usuario VARCHAR(100) NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion DATE,
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
);

-- Insertar datos de ejemplo
INSERT INTO autores (nombre, nacionalidad) VALUES
('Gabriel García Márquez', 'Colombia'),
('Isabel Allende', 'Chile'),
('Mario Vargas Llosa', 'Perú');

INSERT INTO libros (titulo, id_autor, isbn, anio_publicacion) VALUES
('Cien años de soledad', 1, '9780307474728', 1967),
('La casa de los espíritus', 2, '9788497592444', 1982),
('La ciudad y los perros', 3, '9788420412146', 1963);

INSERT INTO prestamos (id_libro, nombre_usuario, fecha_prestamo, fecha_devolucion) VALUES
(1, 'Juan Pérez', '2024-02-01', '2024-02-15'),
(2, 'María García', '2024-02-10', NULL),
(3, 'Carlos López', '2024-02-15', '2024-02-22');
```

## Acceder a Diferentes Schemas

Con el sistema automatizado, **todos los schemas están disponibles simultáneamente**. Los alumnos pueden cambiar entre ellos usando SQL:

```sql
-- Ver todos los schemas disponibles
SHOW DATABASES;

-- Cambiar a biblioteca
USE biblioteca;
SHOW TABLES;
SELECT * FROM libros;

-- Cambiar a tienda_calzado
USE tienda_calzado;
SHOW TABLES;
SELECT * FROM TIENDAS;
```

No necesitas reiniciar el contenedor para cambiar entre schemas.

## Verificar Schemas Disponibles

```bash
# Ver todos los schemas
docker exec -it bbdd_alumnos mysql -udam -pdam123 -e "SHOW DATABASES;"

# Ver las tablas de un schema específico
docker exec -it bbdd_alumnos mysql -udam -pdam123 -e "USE biblioteca; SHOW TABLES;"
```

## Consejos

- ✅ **Nombres descriptivos**: Usa nombres claros para tus archivos SQL
- ✅ **Orden de ejecución**: Usa prefijos numéricos (01-, 02-) si tienes múltiples archivos
- ✅ **Siempre incluye `USE nombre_bd;`** al inicio de tus archivos SQL
- ✅ **Prueba primero**: Prueba el archivo SQL localmente antes de subirlo al servidor
- ✅ **Backup**: Guarda copias de seguridad de tus archivos SQL
- ⚠️ **`docker compose down -v` borra datos**: Asegúrate de que no necesitas los datos antes de ejecutar

## Solución de Problemas

### "Database doesn't exist"
→ Verifica que tu archivo SQL tenga `CREATE DATABASE` o `USE` con el nombre correcto

### "Access denied"
→ Ejecuta `./scripts/preparar.sh` de nuevo para regenerar el usuario

### "Table already exists"
→ Usa `DROP TABLE IF EXISTS` antes de `CREATE TABLE` en tu SQL

### Cambios no se aplican
→ Asegúrate de ejecutar `docker compose down -v` para eliminar datos antiguos
