# Ejemplo: Agregar una Nueva Base de Datos

Este es un ejemplo práctico de cómo agregar una nueva base de datos al servidor.

## Escenario

Tienes un archivo SQL llamado `biblioteca.sql` que crea una base de datos de una biblioteca con tablas de libros, autores y préstamos.

## Método 1: Script Asistido (Más Fácil)

```bash
# 1. Ejecutar el script asistente
./scripts/agregar-bd.sh

# El script te preguntará:
# "📄 Ingresa la ruta al archivo SQL de la base de datos:"
/home/profesor/descargas/biblioteca.sql

# "🏷️ Ingresa el nombre de la base de datos (ej: mi_base_datos):"
biblioteca

# "¿Deseas actualizar el archivo .env para usar esta base de datos? (s/n)"
s

# 2. Preparar los archivos
./scripts/preparar.sh

# 3. Reiniciar el contenedor
docker compose down -v
docker compose up -d

# 4. Verificar
./scripts/verificar.sh
```

## Método 2: Manual (Más Control)

```bash
# 1. Copiar el archivo a Creaciones/
cp /home/profesor/descargas/biblioteca.sql Creaciones/

# 2. (Opcional) Renombrar para controlar orden de ejecución
mv Creaciones/biblioteca.sql Creaciones/01-biblioteca.sql

# 3. Verificar que el archivo SQL use el nombre correcto
nano Creaciones/01-biblioteca.sql
# Asegurarse que tenga al inicio:
# USE biblioteca;
# o
# CREATE DATABASE IF NOT EXISTS biblioteca;
# USE biblioteca;

# 4. Actualizar .env
nano .env
# Cambiar la línea:
DB_NAME=biblioteca

# 5. Preparar
./scripts/preparar.sh

# 6. Reiniciar
docker compose down -v
docker compose up -d

# 7. Verificar
docker logs bbdd_alumnos --tail 30
```

## Múltiples Bases de Datos en Creaciones/

Si tienes varios archivos SQL en `Creaciones/`:

```
Creaciones/
├── 01-tienda-calzado.sql
├── 02-biblioteca.sql
├── 03-hospital.sql
└── ZZ-create-user.sql (generado automáticamente)
```

**Solo se activará la base de datos especificada en `.env`:**

```bash
# Para usar biblioteca:
# En .env:
DB_NAME=biblioteca

# Preparar y desplegar:
./scripts/preparar.sh
docker compose down -v
docker compose up -d
```

**Los archivos SQL deben tener `USE nombre_bd;` para indicar qué base de datos usar.**

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

## Cambiar Entre Bases de Datos

```bash
# Cambiar de tienda_calzado a biblioteca
nano .env
# Cambiar: DB_NAME=biblioteca

./scripts/preparar.sh
docker compose down -v
docker compose up -d

# Cambiar de vuelta a tienda_calzado
nano .env
# Cambiar: DB_NAME=tienda_calzado

./scripts/preparar.sh
docker compose down -v
docker compose up -d
```

## Verificar Qué Base de Datos Está Activa

```bash
# Método 1: Ver el archivo .env
cat .env | grep DB_NAME

# Método 2: Conectarse y verificar
docker exec -it bbdd_alumnos mysql -udam -pdam123 -e "SHOW DATABASES;"

# Método 3: Ver las tablas de la base de datos actual
docker exec -it bbdd_alumnos mysql -udam -pdam123 -e "USE $(grep DB_NAME .env | cut -d'=' -f2); SHOW TABLES;"
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
