-- Este script de prueba puede ser utilizado por los alumnos
-- para verificar que su conexión funciona correctamente

-- Mostrar todas las bases de datos disponibles
SHOW DATABASES;

-- Usar la base de datos tienda_calzado
USE tienda_calzado;

-- Mostrar todas las tablas
SHOW TABLES;

-- Consulta simple: Ver todas las poblaciones
SELECT * FROM POBLACIONES LIMIT 10;

-- Consulta simple: Ver todas las tiendas
SELECT * FROM TIENDAS;

-- Consulta con JOIN: Ver tiendas con su población
SELECT 
    t.CODTIENDA,
    t.DIRECCCION,
    t.TELEFONO,
    p.POBLACION,
    p.PROVINCIA
FROM TIENDAS t
INNER JOIN POBLACIONES p ON t.CP = p.CP
ORDER BY p.PROVINCIA, p.POBLACION;

-- Consulta: Ver zapatos con su proveedor
SELECT 
    z.CODIGO,
    z.TIPO,
    z.DESCRIPCION,
    z.PVP,
    z.STOCK,
    p.NOMBRE AS PROVEEDOR
FROM ZAPATOS z
INNER JOIN PROVEEDORES p ON z.CODPROV = p.CODPROV
ORDER BY z.TIPO, z.PVP;

-- Estas consultas NO funcionarán (solo tienen permisos de lectura):
-- INSERT INTO POBLACIONES VALUES ('00000', 'Prueba', 'Prueba');
-- UPDATE ZAPATOS SET STOCK = 0 WHERE CODIGO = 1;
-- DELETE FROM VENTAS WHERE NOVENTA = 1;
