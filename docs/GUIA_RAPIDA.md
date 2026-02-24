# 🚀 Guía Rápida - Desplegar Cualquier Base de Datos

## Primera Vez

### 1. Configuración Inicial
```bash
# Copiar configuración de ejemplo
cp .env.example .env

# Editar con tus preferencias
nano .env  # o vim, code, etc.
```

### 2. Desplegar
```bash
# Levantar el servidor
docker compose up -d
```

**⚡ ¡Eso es todo!** El sistema detecta automáticamente todos los schemas y configura los permisos.

### 3. Verificar
```bash
./scripts/verificar.sh
```

## Agregar una Nueva Base de Datos

### Proceso Simplificado ✨
```bash
# 1. Copiar tu archivo SQL (debe contener CREATE DATABASE y USE)
cp /ruta/tu_base_datos.sql Creaciones/

# 2. Reiniciar contenedor
docker compose down -v
docker compose up -d
```

**⚡ ¡Automático!** El sistema detecta el nuevo schema y configura los permisos automáticamente.

### Opción Alternativa: Script Asistido
```bash
./scripts/agregar-bd.sh
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
./scripts/preparar.sh
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

💡 **Recuerda**: Siempre ejecuta `./scripts/preparar.sh` después de cambiar el `.env`
