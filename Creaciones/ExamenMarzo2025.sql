-- ============================================
-- SCRIPT COMPLETO: DROP + CREACIÓN + DATOS
-- Esquema: Taller / Gestión de Reparaciones
-- ============================================

CREATE SCHEMA IF NOT EXISTS taller
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE taller;

-- --------------------------------------------
-- DROP DE TABLAS (orden inverso de dependencias)
-- --------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS LINFACTURAS;
DROP TABLE IF EXISTS PAGOSPARCIALES;
DROP TABLE IF EXISTS LINEASREPARACION;
DROP TABLE IF EXISTS FACTURAS;
DROP TABLE IF EXISTS REPARACIONES;
DROP TABLE IF EXISTS VEHICULOS;
DROP TABLE IF EXISTS PRODUCTOS;
DROP TABLE IF EXISTS CLIENTES;
DROP TABLE IF EXISTS PROVEEDORES;
DROP TABLE IF EXISTS POBLACIONES;

SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------
-- TABLA: POBLACIONES
-- --------------------------------------------
CREATE TABLE POBLACIONES (
    CP          VARCHAR(5)      NOT NULL,
    POBLACION   VARCHAR(100)    NOT NULL,
    PROVINCIA   VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_POBLACIONES PRIMARY KEY (CP)
);

-- --------------------------------------------
-- TABLA: CLIENTES
-- --------------------------------------------
CREATE TABLE CLIENTES (
    NUMCLI      INT             NOT NULL AUTO_INCREMENT,
    NOMCLI      VARCHAR(100)    NOT NULL,
    DIRECCION   VARCHAR(200),
    TELEFONO    VARCHAR(15),
    CP          VARCHAR(5)      NOT NULL,
    CONSTRAINT PK_CLIENTES  PRIMARY KEY (NUMCLI),
    CONSTRAINT FK_CLI_POB   FOREIGN KEY (CP) REFERENCES POBLACIONES(CP)
);

-- --------------------------------------------
-- TABLA: PROVEEDORES
-- --------------------------------------------
CREATE TABLE PROVEEDORES (
    CODPROV     INT             NOT NULL AUTO_INCREMENT,
    CIF         VARCHAR(15)     NOT NULL,
    NOMBRE      VARCHAR(100)    NOT NULL,
    TELEFONO    VARCHAR(15),
    FAX         VARCHAR(15),
    CP          VARCHAR(5)      NOT NULL,
    CONSTRAINT PK_PROVEEDORES   PRIMARY KEY (CODPROV),
    CONSTRAINT AK_PROV_CIF      UNIQUE (CIF),
    CONSTRAINT FK_PROV_POB      FOREIGN KEY (CP) REFERENCES POBLACIONES(CP)
);

-- --------------------------------------------
-- TABLA: VEHICULOS
-- --------------------------------------------
CREATE TABLE VEHICULOS (
    MATRICULA       VARCHAR(10)     NOT NULL,
    MARCA           VARCHAR(50)     NOT NULL,
    MODELO          VARCHAR(50)     NOT NULL,
    KM              INT             DEFAULT 0,
    FECHAREVISION   DATE,
    CODCLI          INT             NOT NULL,
    CONSTRAINT PK_VEHICULOS PRIMARY KEY (MATRICULA),
    CONSTRAINT FK_VEH_CLI   FOREIGN KEY (CODCLI) REFERENCES CLIENTES(NUMCLI)
);

-- --------------------------------------------
-- TABLA: PRODUCTOS
-- --------------------------------------------
CREATE TABLE PRODUCTOS (
    CODIGO          VARCHAR(20)     NOT NULL,
    DESCRIPCION     VARCHAR(200),
    GAMA            VARCHAR(50),
    EXISTENCIAS     INT             DEFAULT 0,
    PVP             DECIMAL(10,2),
    PRECIOCOSTE     DECIMAL(10,2),
    CODPROV         INT             NOT NULL,
    CONSTRAINT PK_PRODUCTOS PRIMARY KEY (CODIGO),
    CONSTRAINT FK_PROD_PROV FOREIGN KEY (CODPROV) REFERENCES PROVEEDORES(CODPROV)
);

-- --------------------------------------------
-- TABLA: REPARACIONES
-- --------------------------------------------
CREATE TABLE REPARACIONES (
    NOREPARACION    INT             NOT NULL AUTO_INCREMENT,
    FECHAR          DATE,
    FORMAPAGO       VARCHAR(50),
    REALIZADA       BOOLEAN         DEFAULT FALSE,
    PAGADA          BOOLEAN         DEFAULT FALSE,
    MATRICULA       VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_REPARACIONES  PRIMARY KEY (NOREPARACION),
    CONSTRAINT FK_REP_VEH       FOREIGN KEY (MATRICULA) REFERENCES VEHICULOS(MATRICULA)
);

-- --------------------------------------------
-- TABLA: LINEASREPARACION
-- --------------------------------------------
CREATE TABLE LINEASREPARACION (
    NOREPAR     INT             NOT NULL,
    CODARTI     VARCHAR(20)     NOT NULL,
    CTD         INT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_LINEASREP     PRIMARY KEY (NOREPAR, CODARTI),
    CONSTRAINT FK_LINREP_REP    FOREIGN KEY (NOREPAR)  REFERENCES REPARACIONES(NOREPARACION),
    CONSTRAINT FK_LINREP_PROD   FOREIGN KEY (CODARTI)  REFERENCES PRODUCTOS(CODIGO)
);

-- --------------------------------------------
-- TABLA: PAGOSPARCIALES
-- --------------------------------------------
CREATE TABLE PAGOSPARCIALES (
    NUMPAGO     INT             NOT NULL,
    NOREPAR     INT             NOT NULL,
    FECHAP      DATE,
    IMPORTE     DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_PAGOSPARCIALES PRIMARY KEY (NUMPAGO, NOREPAR),
    CONSTRAINT FK_PAGOS_REP      FOREIGN KEY (NOREPAR) REFERENCES REPARACIONES(NOREPARACION)
);

-- --------------------------------------------
-- TABLA: FACTURAS
-- --------------------------------------------
CREATE TABLE FACTURAS (
    NOFACTURA   INT             NOT NULL AUTO_INCREMENT,
    FECHAF      DATE,
    TIPOPAGO    VARCHAR(50),
    PAGADA      BOOLEAN         DEFAULT FALSE,
    CODPROV     INT             NOT NULL,
    CONSTRAINT PK_FACTURAS  PRIMARY KEY (NOFACTURA),
    CONSTRAINT FK_FACT_PROV FOREIGN KEY (CODPROV) REFERENCES PROVEEDORES(CODPROV)
);

-- --------------------------------------------
-- TABLA: LINFACTURAS
-- --------------------------------------------
CREATE TABLE LINFACTURAS (
    NOFACTU     INT             NOT NULL,
    CODIGOART   VARCHAR(20)     NOT NULL,
    CANTIDAD    INT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_LINFACTURAS   PRIMARY KEY (NOFACTU, CODIGOART),
    CONSTRAINT FK_LINFACT_FACT  FOREIGN KEY (NOFACTU)    REFERENCES FACTURAS(NOFACTURA),
    CONSTRAINT FK_LINFACT_PROD  FOREIGN KEY (CODIGOART)  REFERENCES PRODUCTOS(CODIGO)
);


-- ============================================
-- DATOS DE PRUEBA
-- ============================================

-- POBLACIONES
INSERT INTO POBLACIONES VALUES
('28001', 'Madrid',      'Madrid'),
('45001', 'Toledo',      'Castilla-La Mancha'),
('13001', 'Ciudad Real', 'Castilla-La Mancha'),
('46001', 'Valencia',    'Valencia'),
('41001', 'Sevilla',     'Andalucía'),
('08001', 'Barcelona',   'Cataluña'),
('18001', 'Granada',     'Andalucía'),
('50001', 'Zaragoza',    'Aragón');

-- PROVEEDORES
INSERT INTO PROVEEDORES (CODPROV, CIF, NOMBRE, TELEFONO, FAX, CP) VALUES
(1, 'B12345678', 'AutoPiezas Madrid',    '910000001', '910000002', '28001'),
(2, 'B87654321', 'Repuestos Toledo',     '925000001', '925000002', '45001'),
(3, 'B11223344', 'Componentes Valencia', '961000001', '961000002', '46001'),
(4, 'B44332211', 'Recambios Sevilla',    '954000001', '954000002', '41001'),
(5, 'B55667788', 'MadridPieces Sur',     '910000003', '910000004', '28001'),
(6, 'B66778899', 'Zaragoza Auto Parts',  '976000001', '976000002', '50001'),
(7, 'B99887766', 'Granada Recambios',    '958000001', '958000002', '18001');

-- CLIENTES
INSERT INTO CLIENTES (NUMCLI, NOMCLI, DIRECCION, TELEFONO, CP) VALUES
(1, 'Juan García López',    'Calle Mayor 1',        '611111111', '28001'),
(2, 'María Pérez Ruiz',     'Calle Cervantes 5',    '622222222', '45001'),
(3, 'Carlos Martínez Díaz', 'Avda. España 10',      '633333333', '13001'),
(4, 'Ana López Sanz',       'Calle Valencia 3',     '644444444', '46001'),
(5, 'Pedro Sánchez Gil',    'Avda. Sur 7',          '655555555', '41001'),
(6, 'Laura Fernández Mora', 'Calle Sierpes 3',      '666111222', '41001'),
(7, 'Roberto Jiménez Vega', 'Calle Delicias 12',    '677222333', '50001'),
(8, 'Sofía Castro Núñez',   'Avda. Constitución 5', '688333444', '18001');

-- VEHICULOS
INSERT INTO VEHICULOS VALUES
('1234ABC', 'Toyota',     'Corolla', 45000, '2025-01-15', 1),
('5678DEF', 'Ford',       'Focus',   62000, '2025-03-20', 2),
('9012GHI', 'Seat',       'Ibiza',   28000, '2024-11-10', 3),
('3456JKL', 'Volkswagen', 'Golf',    85000, '2025-06-05', 4),
('7890MNO', 'Renault',    'Megane',  39000, '2025-02-28', 5),
('2345PQR', 'BMW',        'Serie 3', 55000, '2025-04-10', 6),
('6789STU', 'Mercedes',   'Clase A', 32000, '2025-01-05', 7),
('0123VWX', 'Audi',       'A3',      70000, '2024-12-15', 8);

-- PRODUCTOS
INSERT INTO PRODUCTOS (CODIGO, DESCRIPCION, GAMA, EXISTENCIAS, PVP, PRECIOCOSTE, CODPROV) VALUES
('P001', 'Filtro de aceite',       'Filtros',         5,  15.00,   8.00, 1),
('P002', 'Pastillas de freno',     'Frenos',         20,  45.00,  22.00, 1),
('P003', 'Amortiguador delantero', 'Suspensión',      3, 120.00,  65.00, 2),
('P004', 'Correa de distribución', 'Motor',          15,  80.00,  40.00, 2),
('P005', 'Batería 12V',            'Eléctrico',       4,  95.00,  50.00, 3),
('P006', 'Alternador',             'Eléctrico',       5, 180.00,  95.00, 3),
('P007', 'Radiador',               'Refrigeración',   8, 150.00,  78.00, 4),
('P008', 'Catalizador',            'Escape',          2, 200.00, 105.00, 4),
('P009', 'Limpiaparabrisas',       'Accesorios',     20,  12.00,   5.00, 1),
('P010', 'Bujías',                 'Motor',          12,  25.00,  10.00, 1),
('P011', 'Aceite sintético 5W40',  'Lubricantes',    30,  35.00,  18.00, 2),
('P012', 'Disco de freno',         'Frenos',          6,  90.00,  48.00, 3);

-- REPARACIONES
INSERT INTO REPARACIONES (NOREPARACION, FECHAR, FORMAPAGO, REALIZADA, PAGADA, MATRICULA) VALUES
(1,  '2025-01-10', 'Contado',       TRUE, TRUE,  '1234ABC'),
(2,  '2025-02-15', 'Tarjeta',       TRUE, TRUE,  '5678DEF'),
(3,  '2025-03-20', 'Transferencia', TRUE, FALSE, '9012GHI'),
(4,  '2025-04-05', 'Contado',       TRUE, TRUE,  '3456JKL'),
(5,  '2025-05-10', 'Tarjeta',       TRUE, TRUE,  '7890MNO'),
(6,  '2025-01-25', 'Contado',       TRUE, TRUE,  '1234ABC'),
(7,  '2025-02-28', 'Tarjeta',       TRUE, TRUE,  '5678DEF'),
(8,  '2025-01-12', 'Contado',       TRUE, TRUE,  '2345PQR'),
(9,  '2025-02-18', 'Tarjeta',       TRUE, TRUE,  '6789STU'),
(10, '2025-06-20', 'Transferencia', TRUE, TRUE,  '0123VWX'),
(11, '2025-03-05', 'Contado',       TRUE, FALSE, '2345PQR');

-- LINEASREPARACION
INSERT INTO LINEASREPARACION VALUES
(1,  'P001', 2),
(1,  'P002', 1),
(2,  'P003', 4),
(2,  'P005', 5),
(3,  'P005', 3),
(3,  'P008', 3),
(4,  'P007', 1),
(4,  'P001', 3),
(5,  'P008', 2),
(5,  'P006', 1),
(6,  'P002', 1),
(6,  'P004', 1),
(7,  'P003', 2),
(7,  'P004', 1),
(8,  'P010', 4),
(8,  'P011', 2),
(9,  'P012', 2),
(9,  'P007', 1),
(10, 'P001', 5),
(10, 'P012', 2),
(11, 'P002', 2),
(11, 'P010', 3);

-- PAGOSPARCIALES
INSERT INTO PAGOSPARCIALES VALUES
(1, 1,  '2025-01-15',  75.00),
(1, 2,  '2025-02-20', 500.00),
(2, 2,  '2025-03-05', 455.00),
(1, 3,  '2025-03-25', 400.00),
(1, 4,  '2025-04-10', 195.00),
(1, 5,  '2025-05-15', 300.00),
(2, 5,  '2025-06-01', 280.00),
(1, 8,  '2025-01-20', 170.00),
(1, 9,  '2025-02-25', 330.00),
(1, 10, '2025-06-25', 255.00),
(1, 11, '2025-03-10', 100.00),
(2, 11, '2025-03-20',  65.00);

-- FACTURAS
INSERT INTO FACTURAS (NOFACTURA, FECHAF, TIPOPAGO, PAGADA, CODPROV) VALUES
(1, '2025-01-15', 'Transferencia', TRUE,  1),
(2, '2025-02-20', 'Transferencia', TRUE,  2),
(3, '2025-03-10', 'Transferencia', TRUE,  3),
(4, '2025-04-05', 'Transferencia', FALSE, 4),
(5, '2025-01-25', 'Transferencia', TRUE,  5),
(6, '2025-03-15', 'Transferencia', TRUE,  1),
(7, '2025-02-10', 'Transferencia', TRUE,  6),
(8, '2025-04-20', 'Transferencia', FALSE, 7);

-- LINFACTURAS
INSERT INTO LINFACTURAS VALUES
(1, 'P001', 20),
(1, 'P002', 15),
(2, 'P003', 10),
(2, 'P004', 12),
(3, 'P005',  8),
(3, 'P006',  5),
(4, 'P007',  6),
(4, 'P008',  4),
(5, 'P001',  5),
(5, 'P009', 10),
(6, 'P002', 10),
(6, 'P009',  5),
(7, 'P010', 20),
(7, 'P011', 15),
(8, 'P012', 10),
(8, 'P007',  8);
