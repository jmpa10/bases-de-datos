# Guía de Conexión para Alumnos

## Datos de Conexión

Para conectarte a la base de datos del curso, utiliza los siguientes datos:

```
Host/Servidor: [TU_PROFESOR_TE_DARÁ_LA_IP]
Puerto: 3306
Base de datos: tienda_calzado
Usuario: dam
Contraseña: dam123
```

## Cómo Conectarse

### Opción 1: MySQL Workbench (Recomendado)

1. Abre MySQL Workbench
2. Haz clic en el **+** junto a "MySQL Connections"
3. Rellena los datos:
   - **Connection Name**: Servidor DAM
   - **Hostname**: [La IP que te proporcione el profesor]
   - **Port**: 3306
   - **Username**: dam
   - **Password**: Haz clic en "Store in Keychain" y escribe: dam123
   - **Default Schema**: tienda_calzado
4. Haz clic en "Test Connection" para verificar
5. Si todo va bien, haz clic en "OK"

### Opción 2: Línea de Comandos

```bash
mysql -h [IP_DEL_SERVIDOR] -P 3306 -u dam -pdam123 tienda_calzado
```

### Opción 3: DBeaver

1. Abre DBeaver
2. Nueva Conexión → MySQL
3. Rellena:
   - **Server Host**: [IP del profesor]
   - **Port**: 3306
   - **Database**: tienda_calzado
   - **Username**: dam
   - **Password**: dam123
4. Test Connection → Finish

## Base de Datos

La base de datos **tienda_calzado** contiene información sobre una cadena de tiendas de calzado:

### Tablas Disponibles:
- **POBLACIONES**: Códigos postales y localidades
- **TIENDAS**: Tiendas de la cadena
- **PROVEEDORES**: Proveedores de calzado
- **ZAPATOS**: Catálogo de productos (zapatos, botas, deportivos, etc.)
- **VENTAS**: Registro de ventas realizadas
- **LINEASVENTA**: Detalle de productos vendidos en cada venta
- **FACTURAS**: Facturas recibidas de proveedores
- **LINEASFACTURA**: Detalle de los productos en cada factura
- **PAGOS**: Pagos realizados a las facturas

## Consultas de Ejemplo

### Ver todas las tiendas
```sql
SELECT * FROM TIENDAS;
```

### Ver todos los zapatos disponibles
```sql
SELECT * FROM ZAPATOS;
```

### Ver tiendas con su población
```sql
SELECT 
    t.CODTIENDA,
    t.DIRECCCION,
    p.POBLACION,
    p.PROVINCIA
FROM TIENDAS t
INNER JOIN POBLACIONES p ON t.CP = p.CP;
```

### Ver zapatos con su proveedor
```sql
SELECT 
    z.TIPO,
    z.DESCRIPCION,
    z.PVP,
    p.NOMBRE AS PROVEEDOR
FROM ZAPATOS z
INNER JOIN PROVEEDORES p ON z.CODPROV = p.CODPROV
ORDER BY z.PVP;
```

## ⚠️ Importante

- **SOLO** puedes hacer consultas (SELECT)
- **NO** puedes modificar datos (INSERT, UPDATE, DELETE)
- **NO** puedes crear o eliminar tablas
- Los datos son compartidos por todos los alumnos, así que no te preocupes si no puedes modificarlos

## Solución de Problemas

### No puedo conectarme
- Verifica que estés usando los datos correctos
- Asegúrate de que tu ordenador tenga acceso a Internet
- Comprueba que el puerto 3306 no esté bloqueado por tu firewall
- Consulta con el profesor

### Error "Access denied"
- Verifica que el usuario sea exactamente: **dam** (en minúsculas)
- Verifica que la contraseña sea exactamente: **dam123**

### No veo las tablas
- Asegúrate de haber seleccionado la base de datos **tienda_calzado**
- En MySQL Workbench: `USE tienda_calzado;`

---

¿Dudas? Consulta con tu profesor.
