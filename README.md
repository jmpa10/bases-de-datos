# Servidor de Base de Datos para Alumnos

Este proyecto despliega una base de datos MySQL con Docker Compose para que los alumnos puedan conectarse y realizar consultas.

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
