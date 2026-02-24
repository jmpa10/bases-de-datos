# 🚀 Guía Rápida - Desplegar Cualquier Base de Datos

## Primera Vez

### 1. Configuración Inicial
```bash
# Copiar configuración de ejemplo
cp .env.example .env

# Editar con tus preferencias
nano .env  # o vim, code, etc.
```

### 2. Preparar y Desplegar
```bash
# Dar permisos a los scripts
chmod +x preparar.sh agregar-bd.sh verificar.sh

# Preparar archivos
./preparar.sh

# Levantar el servidor
docker compose up -d
```

### 3. Verificar
```bash
./verificar.sh
```

## Agregar una Nueva Base de Datos

### Opción A: Script Asistido 🎯
```bash
./agregar-bd.sh
```

### Opción B: Manual
```bash
# 1. Copiar tu archivo SQL
cp /ruta/tu_base_datos.sql Creaciones/

# 2. Editar .env
nano .env
# Cambiar: DB_NAME=nombre_tu_base_datos

# 3. Preparar
./preparar.sh

# 4. Reiniciar contenedor
docker compose down -v
docker compose up -d
```

## Comandos Útiles

```bash
# Ver logs del contenedor
docker logs bbdd_alumnos -f

# Detener servidor
docker compose down

# Detener y borrar datos
docker compose down -v

# Reiniciar servidor
docker compose restart

# Ver estado
docker compose ps

# Conectarse como root desde el servidor
docker exec -it bbdd_alumnos mysql -uroot -p
```

## Estructura de Archivos

```
.
├── .env                    # Tu configuración (NO SUBIR A GIT)
├── .env.example           # Plantilla de configuración
├── docker-compose.yml     # Configuración de Docker
├── preparar.sh            # Prepara archivos antes de desplegar
├── agregar-bd.sh          # Asistente para agregar BD
├── verificar.sh           # Verifica que todo funciona
├── Creaciones/            # Tus archivos SQL aquí
│   ├── MiBaseDatos.sql
│   ├── OtraBaseDatos.sql
│   └── ZZ-create-user.sql # (Generado automáticamente)
└── README.md              # Documentación completa
```

## Solución de Problemas

### Error: Access denied for user
```bash
# Regenerar usuario
./preparar.sh
docker compose down -v
docker compose up -d
```

### Error: Database doesn't exist
```bash
# Verificar que el archivo SQL tenga:
# USE nombre_base_datos;
# Y que .env tenga el mismo nombre en DB_NAME
```

### Ver qué archivos se ejecutarán
```bash
ls -la Creaciones/*.sql
```

## Ejemplos de .env

### Para desarrollo/pruebas
```env
DB_NAME=test_db
DB_USER=alumno
DB_PASSWORD=alumno123
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=root123
```

### Para producción
```env
DB_NAME=empresa_db
DB_USER=readonly_user
DB_PASSWORD=Str0ng_P@ssw0rd_2024
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=V3ry_S3cur3_R00t_P@ss
```

---

💡 **Recuerda**: Siempre ejecuta `./preparar.sh` después de cambiar el `.env`
