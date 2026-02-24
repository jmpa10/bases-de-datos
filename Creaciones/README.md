# Carpeta Creaciones

Esta carpeta contiene los archivos SQL que se ejecutarán automáticamente al iniciar el contenedor de MySQL.

## 📝 Reglas

1. **Todos los archivos `.sql` en esta carpeta se ejecutan automáticamente** al iniciar el contenedor
2. **Se ejecutan en orden alfabético**
3. **El archivo `ZZ-create-user.sql` se genera automáticamente** (no editar manualmente)

## 📂 Organización

### Archivos actuales:
- `CreacionExamen2021.sql` - Base de datos de tienda de calzado
- `ZZ-create-user.sql` - Script de creación de usuario (generado automáticamente)

### Nombres recomendados para nuevos archivos:
```
01-nombre-descriptivo.sql
02-otro-archivo.sql
03-datos-ejemplo.sql
...
ZZ-create-user.sql (siempre al final, generado automáticamente)
```

## ➕ Agregar un Nuevo Archivo SQL

### Opción 1: Copiar directamente
```bash
cp /ruta/a/tu/archivo.sql Creaciones/
```

### Opción 2: Usar el script asistente
```bash
../agregar-bd.sh
```

## ⚠️ Importante

- **Todos los archivos SQL deben incluir `USE nombre_base_datos;`** al inicio
- Si creas una nueva base de datos, usa:
  ```sql
  CREATE DATABASE IF NOT EXISTS nombre_bd;
  USE nombre_bd;
  ```
- El nombre de la base de datos debe coincidir con `DB_NAME` en el archivo `.env`
- Para aplicar cambios, ejecuta:
  ```bash
  ../preparar.sh
  docker compose down -v
  docker compose up -d
  ```

## 🗑️ Eliminar una Base de Datos

Para dejar de usar un archivo SQL:

1. **Opción temporal**: Renombra el archivo añadiendo `.disabled`
   ```bash
   mv archivo.sql archivo.sql.disabled
   ```

2. **Opción permanente**: Elimina el archivo
   ```bash
   rm archivo.sql
   ```

3. Reinicia el contenedor:
   ```bash
   docker compose down -v
   docker compose up -d
   ```

## 📖 Más Información

- Ver [GUIA_RAPIDA.md](../GUIA_RAPIDA.md) para comandos útiles
- Ver [EJEMPLO_AGREGAR_BD.md](../EJEMPLO_AGREGAR_BD.md) para ejemplos completos
- Ver [README.md](../README.md) para documentación completa
