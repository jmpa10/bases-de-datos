# Instrucciones para actualizar el servidor

## El problema
El script original era un archivo `.sh` (bash) pero MySQL solo ejecuta automáticamente archivos `.sql` al iniciar.

## Solución
En el servidor (192.168.5.21), ejecuta estos comandos:

```bash
# 1. Ve al directorio del proyecto
cd /ruta/donde/esta/el/proyecto

# 2. Actualiza el código desde GitHub
git pull origin main

# 3. Detén y elimina el contenedor actual (esto borrará los datos)
docker compose down -v

# 4. Levanta el contenedor de nuevo con la configuración corregida
docker compose up -d

# 5. Espera unos segundos para que inicie completamente
sleep 10

# 6. Verifica que todo funciona
docker logs bbdd_alumnos
```

## Verificación rápida
Para verificar que el usuario se creó correctamente:

```bash
docker exec bbdd_alumnos mysql -udam -pdam123 -e "SELECT USER(), DATABASE(); USE tienda_calzado; SHOW TABLES;"
```

Deberías ver la lista de tablas sin errores de acceso.
