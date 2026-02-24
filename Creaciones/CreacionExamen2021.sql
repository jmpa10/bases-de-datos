-- ============================================================
-- BASE DE DATOS: CADENA DE TIENDAS DE CALZADO
-- Compatible con: MySQL / MariaDB
-- SCRIPT COMPLETO Y CORREGIDO (v4 - UTF-8)
-- ============================================================

-- Configurar la codificación de la conexión a UTF-8
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Crear la base de datos con UTF-8
CREATE SCHEMA IF NOT EXISTS tienda_calzado
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos tienda_calzado
USE tienda_calzado;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS PAGOS;
DROP TABLE IF EXISTS LINEASFACTURA;
DROP TABLE IF EXISTS FACTURAS;
DROP TABLE IF EXISTS LINEASVENTA;
DROP TABLE IF EXISTS VENTAS;
DROP TABLE IF EXISTS TIENDAS;
DROP TABLE IF EXISTS ZAPATOS;
DROP TABLE IF EXISTS PROVEEDORES;
DROP TABLE IF EXISTS POBLACIONES;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- CREACIÓN DE TABLAS
-- ============================================================

CREATE TABLE POBLACIONES (
    CP        CHAR(5)       NOT NULL,
    POBLACION VARCHAR(100)  NOT NULL,
    PROVINCIA VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_POBLACIONES PRIMARY KEY (CP)
);

CREATE TABLE TIENDAS (
    CODTIENDA  INT          NOT NULL AUTO_INCREMENT,
    DIRECCCION VARCHAR(150) NOT NULL,
    TELEFONO   CHAR(9)      NOT NULL,
    CP         CHAR(5)      NOT NULL,
    CONSTRAINT PK_TIENDAS    PRIMARY KEY (CODTIENDA),
    CONSTRAINT FK_TIENDAS_CP FOREIGN KEY (CP) REFERENCES POBLACIONES(CP)
);

CREATE TABLE VENTAS (
    NOVENTA   INT  NOT NULL AUTO_INCREMENT,
    FECHAV    DATE NOT NULL,
    CODTIENDA INT  NOT NULL,
    CONSTRAINT PK_VENTAS        PRIMARY KEY (NOVENTA),
    CONSTRAINT FK_VENTAS_TIENDA FOREIGN KEY (CODTIENDA) REFERENCES TIENDAS(CODTIENDA)
);

CREATE TABLE PROVEEDORES (
    CODPROV  INT          NOT NULL AUTO_INCREMENT,
    CIF      CHAR(9)      NOT NULL,
    NOMBRE   VARCHAR(100) NOT NULL,
    TELEFONO CHAR(9)      NOT NULL,
    FAX      CHAR(9),
    CP       CHAR(5)      NOT NULL,
    CONSTRAINT PK_PROVEEDORES    PRIMARY KEY (CODPROV),
    CONSTRAINT AK_PROVEEDORES    UNIQUE      (CIF),
    CONSTRAINT FK_PROVEEDORES_CP FOREIGN KEY (CP) REFERENCES POBLACIONES(CP)
);

CREATE TABLE ZAPATOS (
    CODIGO      INT           NOT NULL AUTO_INCREMENT,
    TIPO        VARCHAR(50)   NOT NULL,
    DESCRIPCION VARCHAR(200)  NOT NULL,
    STOCK       INT           NOT NULL DEFAULT 0,
    PVP         DECIMAL(10,2) NOT NULL,
    PRECIOCOSTE DECIMAL(10,2) NOT NULL,
    CODPROV     INT           NOT NULL,
    CONSTRAINT PK_ZAPATOS       PRIMARY KEY (CODIGO),
    CONSTRAINT FK_ZAPATOS_PROV  FOREIGN KEY (CODPROV) REFERENCES PROVEEDORES(CODPROV),
    CONSTRAINT CHK_STOCK        CHECK (STOCK >= 0),
    CONSTRAINT CHK_PVP          CHECK (PVP > 0),
    CONSTRAINT CHK_PRECIOCOSTE  CHECK (PRECIOCOSTE > 0)
);

CREATE TABLE LINEASVENTA (
    NOVENTA INT NOT NULL,
    CODARTI INT NOT NULL,
    CTDV    INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_LINEASVENTA PRIMARY KEY (NOVENTA, CODARTI),
    CONSTRAINT FK_LV_VENTA    FOREIGN KEY (NOVENTA)  REFERENCES VENTAS(NOVENTA),
    CONSTRAINT FK_LV_ZAPATO   FOREIGN KEY (CODARTI)  REFERENCES ZAPATOS(CODIGO),
    CONSTRAINT CHK_CTDV       CHECK (CTDV > 0)
);

CREATE TABLE FACTURAS (
    NOFACTURA  INT          NOT NULL AUTO_INCREMENT,
    FECHAF     DATE         NOT NULL,
    FORMAPAGO  VARCHAR(50)  NOT NULL,
    PAGADA     TINYINT(1)   NOT NULL DEFAULT 0,
    CODPROV    INT          NOT NULL,
    CONSTRAINT PK_FACTURAS  PRIMARY KEY (NOFACTURA),
    CONSTRAINT FK_FACT_PROV FOREIGN KEY (CODPROV) REFERENCES PROVEEDORES(CODPROV)
);

CREATE TABLE LINEASFACTURA (
    NOFACTURA INT NOT NULL,
    CODARTI   INT NOT NULL,
    CANTIDAD  INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_LINEASFACTURA PRIMARY KEY (NOFACTURA, CODARTI),
    CONSTRAINT FK_LF_FACTURA    FOREIGN KEY (NOFACTURA) REFERENCES FACTURAS(NOFACTURA),
    CONSTRAINT FK_LF_ZAPATO     FOREIGN KEY (CODARTI)   REFERENCES ZAPATOS(CODIGO),
    CONSTRAINT CHK_CANTIDAD     CHECK (CANTIDAD > 0)
);

CREATE TABLE PAGOS (
    NOFACTURA INT           NOT NULL,
    NOPAGO    INT           NOT NULL,
    FECHAPAGO DATE          NOT NULL,
    IMPORTE   DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_PAGOS      PRIMARY KEY (NOFACTURA, NOPAGO),
    CONSTRAINT FK_PAGOS_FACT FOREIGN KEY (NOFACTURA) REFERENCES FACTURAS(NOFACTURA),
    CONSTRAINT CHK_IMPORTE   CHECK (IMPORTE > 0)
);

-- ============================================================
-- DATOS: POBLACIONES (39 localidades)
-- ============================================================

INSERT INTO POBLACIONES (CP, POBLACION, PROVINCIA) VALUES
-- Albacete
('02001', 'Albacete',                'Albacete'),
('02200', 'Casas-Ibáñez',            'Albacete'),
('02400', 'Hellín',                  'Albacete'),
('02440', 'Madrigueras',             'Albacete'),
('02520', 'Chinchilla de Montearagón','Albacete'),
('02640', 'Almansa',                 'Albacete'),
-- Ciudad Real
('13001', 'Ciudad Real',             'Ciudad Real'),
('13300', 'Valdepeñas',              'Ciudad Real'),
('13400', 'Manzanares',              'Ciudad Real'),
('13500', 'Puertollano',             'Ciudad Real'),
('13600', 'Alcázar de San Juan',     'Ciudad Real'),
('13700', 'Tomelloso',               'Ciudad Real'),
-- Cuenca
('16001', 'Cuenca',                  'Cuenca'),
('16200', 'Motilla del Palancar',    'Cuenca'),
('16400', 'Tarancón',                'Cuenca'),
('16500', 'Huete',                   'Cuenca'),
-- Guadalajara
('19001', 'Guadalajara',             'Guadalajara'),
('19100', 'Molina de Aragón',        'Guadalajara'),
('19200', 'Azuqueca de Henares',     'Guadalajara'),
-- Toledo
('45001', 'Toledo',                  'Toledo'),
('45200', 'Illescas',                'Toledo'),
('45300', 'Ocaña',                   'Toledo'),
('45600', 'Talavera de la Reina',    'Toledo'),
('45800', 'Quintanar de la Orden',   'Toledo'),
-- Resto de España
('03203', 'Elche',                   'Alicante'),
('07001', 'Palma de Mallorca',       'Islas Baleares'),
('08001', 'Barcelona',               'Barcelona'),
('15001', 'A Coruña',                'A Coruña'),
('20001', 'San Sebastián',           'Guipúzcoa'),
('28001', 'Madrid',                  'Madrid'),
('29001', 'Málaga',                  'Málaga'),
('30001', 'Murcia',                  'Murcia'),
('35001', 'Las Palmas de Gran Canaria','Las Palmas'),
('36001', 'Pontevedra',              'Pontevedra'),
('41001', 'Sevilla',                 'Sevilla'),
('46001', 'Valencia',                'Valencia'),
('48001', 'Bilbao',                  'Vizcaya'),
('50001', 'Zaragoza',                'Zaragoza');

-- ============================================================
-- DATOS: PROVEEDORES (7 proveedores, CODPROV 1-7)
-- ============================================================

INSERT INTO PROVEEDORES (CIF, NOMBRE, TELEFONO, FAX, CP) VALUES
('B02345678', 'Calzados La Manchuela S.L.',        '967430210', '967430211', '02640'),
('A03198765', 'Elche Shoes International S.A.',    '965421300', '965421301', '03203'),
('B41876543', 'Distribuciones Calzado Sur S.L.',   '954312780', '954312781', '41001'),
('A08234567', 'Piel y Moda Barcelona S.A.',        '932456780', '932456781', '08001'),
('B13654321', 'Calzados Manchegos S.L.',            '926543200', '926543201', '13001'),
('B46789012', 'Calzados Valencia Premium S.L.',    '963456780', '963456781', '46001'),
('A48123456', 'Distribuciones Bilbao Shoes S.A.',  '944543210', '944543211', '48001');

-- ============================================================
-- DATOS: ZAPATOS (27 modelos, CODIGO 1-27)
-- CODPROV: 1=La Manchuela, 2=Elche Shoes, 3=Calzado Sur,
--          4=Piel y Moda, 5=Calzados Manchegos,
--          6=Valencia Premium, 7=Bilbao Shoes
-- ============================================================

INSERT INTO ZAPATOS (TIPO, DESCRIPCION, STOCK, PVP, PRECIOCOSTE, CODPROV) VALUES
('Deportivo',    'Zapatilla running Nike Air Max 270 negro talla 40-45',         45, 129.95,  72.00, 2),
('Deportivo',    'Zapatilla casual Adidas Stan Smith blanca unisex',              38,  89.95,  50.00, 2),
('Bota',         'Bota de piel marrón con punta reforzada caballero',             20, 145.00,  84.00, 1),
('Mocasín',      'Mocasín de cuero negro con suela de goma caballero',            30,  79.95,  44.00, 1),
('Sandalia',     'Sandalia de verano mujer piel beige con tiras cruzadas',        25,  59.95,  32.00, 3),
('Vestir',       'Zapato Oxford marrón cordones caballero piel genuina',          15, 119.95,  68.00, 4),
('Vestir',       'Zapato salón negro mujer tacón 7 cm piel suave',                22,  95.00,  54.00, 4),
('Deportivo',    'Zapatilla trail running Salomon XT-6 hombre camuflaje',         18, 149.95,  88.00, 2),
('Bota montaña', 'Bota trekking Gore-Tex impermeable marrón unisex',              12, 189.95, 108.00, 2),
('Alpargata',    'Alpargata esparto con cuña 5 cm mujer natural y azul',          40,  39.95,  21.00, 3),
('Zueco',        'Zueco sanitario antideslizante blanco unisex',                   50,  29.95,  15.00, 5),
('Sandalia',     'Sandalia deportiva hombre correas ajustables negro',             28,  49.95,  27.00, 3),
('Mocasín',      'Mocasín mujer cuero camel con borla dorada',                     17,  69.95,  39.00, 1),
('Deportivo',    'Zapatilla baloncesto New Balance 550 retro blanca',              22, 109.95,  63.00, 2),
('Botín',        'Botín Chelsea mujer tacón medio ante gris oscuro',               19,  99.95,  57.00, 4),
('Deportivo',    'Zapatilla fitness mujer Nike Revolution 7 rosa',                 35,  69.95,  38.00, 6),
('Bota',         'Bota campera cowboy cuero marrón caballero',                     15, 159.95,  92.00, 1),
('Sandalia',     'Sandalia plataforma mujer corcho y lona verano',                 30,  44.95,  24.00, 3),
('Vestir',       'Zapato vestir mujer punta fina cuero negro tacón 5 cm',         18, 109.95,  62.00, 4),
('Deportivo',    'Zapatilla Puma RS-X candy rosa y blanca unisex',                 25,  94.95,  54.00, 7),
('Mocasín',      'Mocasín sport hombre ante azul marino con suela track',          22,  74.95,  42.00, 1),
('Alpargata',    'Alpargata plataforma hombre lona azul y blanca',                 40,  34.95,  18.00, 3),
('Bota montaña', 'Bota trekking Merrell Moab 3 marrón impermeable',               10, 169.95,  98.00, 2),
('Sandalia',     'Sandalia gladiadora mujer cuero negro con hebillas',             20,  64.95,  36.00, 7),
('Deportivo',    'Zapatilla Reebok Classic Leather blanca vintage unisex',         32,  79.95,  45.00, 6),
('Vestir',       'Zapato blucher marrón caballero piel vacuno cosido Goodyear',    12, 134.95,  77.00, 4),
('Botín',        'Botín montañero hombre cuero serraje tostado',                   16,  89.95,  50.00, 5);

-- ============================================================
-- DATOS: TIENDAS (14 tiendas, CODTIENDA 1-14)
-- ============================================================

INSERT INTO TIENDAS (DIRECCCION, TELEFONO, CP) VALUES
('Calle Mayor, 15',                 '967211345', '02001'),  --  1 Albacete
('Pasaje Lodares, 3',               '967234890', '02001'),  --  2 Albacete
('Av. del Rey Juan Carlos I, 42',   '926210987', '13001'),  --  3 Ciudad Real
('Calle de la Paz, 7',              '925213456', '45001'),  --  4 Toledo
('Calle San Julián, 12',           '969215678', '16001'),  --  5 Cuenca
('Calle Virgen de las Viñas, 18',  '926512234', '13700'),  --  6 Tomelloso
('Calle Cervantes, 8',              '926321456', '13300'),  --  7 Valdepeñas
('Calle Ancha de Castelar, 24',    '949231890', '19001'),  --  8 Guadalajara
('Ronda de Toledo, 5',              '925800234', '45600'),  --  9 Talavera de la Reina
('Calle del Carmen, 6',             '967558812', '02440'),  -- 10 Madrigueras
('Calle Cervantes, 22',             '967462034', '02200'),  -- 11 Casas-Ibáñez
('Calle Goya, 11',                  '926580347', '13600'),  -- 12 Alcázar de San Juan
('Plaza Mayor, 3',                  '925185623', '45800'),  -- 13 Quintanar de la Orden
('Calle Colón, 15',                 '969320156', '16200');  -- 14 Motilla del Palancar

-- ============================================================
-- DATOS: VENTAS (50 ventas, NOVENTA 1-50)
-- ============================================================

INSERT INTO VENTAS (FECHAV, CODTIENDA) VALUES
-- Enero
('2024-01-15', 1),   -- 1
('2024-01-22', 2),   -- 2
-- Febrero
('2024-02-03', 3),   -- 3
('2024-02-14', 4),   -- 4
('2024-02-28', 5),   -- 5
-- Marzo
('2024-03-01', 10),  -- 6  Madrigueras (apertura)
('2024-03-05', 6),   -- 7
('2024-03-07', 5),   -- 8
('2024-03-12', 7),   -- 9
('2024-03-16', 11),  -- 10 Casas-Ibáñez
('2024-03-20', 1),   -- 11
-- Abril (24 ventas, días laborables + Semana Santa)
('2024-04-01', 10),  -- 12 Madrigueras
('2024-04-02', 1),   -- 13
('2024-04-03', 6),   -- 14 Tomelloso
('2024-04-04', 12),  -- 15 Alcázar de San Juan
('2024-04-05', 3),   -- 16 Ciudad Real
('2024-04-06', 4),   -- 17 Toledo
('2024-04-08', 10),  -- 18 Madrigueras
('2024-04-09', 2),   -- 19 Albacete 2
('2024-04-10', 11),  -- 20 Casas-Ibáñez
('2024-04-11', 7),   -- 21 Valdepeñas
('2024-04-12', 13),  -- 22 Quintanar de la Orden
('2024-04-14', 8),   -- 23 Guadalajara
('2024-04-15', 1),   -- 24 Albacete 1
('2024-04-16', 9),   -- 25 Talavera de la Reina
('2024-04-17', 10),  -- 26 Madrigueras (pico Semana Santa)
('2024-04-18', 14),  -- 27 Motilla del Palancar
('2024-04-19', 6),   -- 28 Tomelloso
('2024-04-22', 5),   -- 29 Cuenca (post Semana Santa)
('2024-04-23', 12),  -- 30 Alcázar de San Juan (San Jorge)
('2024-04-24', 3),   -- 31 Ciudad Real
('2024-04-25', 10),  -- 32 Madrigueras
('2024-04-26', 7),   -- 33 Valdepeñas
('2024-04-29', 11),  -- 34 Casas-Ibáñez
('2024-04-30', 4),   -- 35 Toledo
-- Mayo
('2024-05-06', 5),   -- 36
('2024-05-10', 10),  -- 37 Madrigueras
('2024-05-15', 6),   -- 38
('2024-05-20', 13),  -- 39 Quintanar
-- Junio
('2024-06-01', 7),   -- 40
('2024-06-10', 2),   -- 41
('2024-06-15', 14),  -- 42 Motilla
('2024-06-22', 4),   -- 43
-- Julio
('2024-07-04', 8),   -- 44
('2024-07-19', 9),   -- 45
('2024-07-20', 10),  -- 46 Madrigueras (verano)
-- Agosto
('2024-08-05', 10),  -- 47 Madrigueras
('2024-08-12', 6),   -- 48 Tomelloso
-- Septiembre
('2024-09-10', 3),   -- 49
('2024-09-25', 1);   -- 50

-- ============================================================
-- DATOS: LINEASVENTA (103 líneas)
-- ============================================================

INSERT INTO LINEASVENTA (NOVENTA, CODARTI, CTDV) VALUES
-- Enero-Febrero (NOVENTA 1-5)
(1,  1,  2), (1,  4,  1),
(2,  6,  1), (2,  7,  1),
(3,  3,  1), (3,  5,  2),
(4,  8,  1), (4,  9,  1),
(5,  10, 3), (5,  11, 2),
-- Marzo (NOVENTA 6-11)
(6,  16, 2), (6,  22, 3),
(7,  2,  1), (7,  12, 1),
(8,  5,  1), (8,  10, 2), (8,  18, 1),
(9,  13, 1), (9,  14, 1),
(10, 21, 1), (10, 17, 1),
(11, 15, 1), (11, 4,  2),
-- Abril (NOVENTA 12-35)
(12, 16, 1), (12,  5, 2),
(13,  1, 2), (13,  4, 1), (13, 25, 1),
(14, 10, 3), (14, 22, 2),
(15, 12, 1), (15, 18, 2), (15, 24, 1),
(16,  6, 1), (16,  7, 1), (16, 19, 1),
(17,  8, 1), (17,  9, 1),
(18, 16, 2), (18, 20, 1), (18, 22, 1),
(19,  2, 2), (19, 14, 1),
(20, 21, 1), (20, 26, 1),
(21, 13, 2), (21,  3, 1),
(22,  5, 3), (22, 10, 1), (22, 18, 2),
(23,  8, 1), (23, 23, 1),
(24,  1, 1), (24,  6, 2), (24, 20, 1),
(25, 11, 2), (25, 22, 3),
(26, 16, 3), (26, 17, 1), (26, 22, 2),
(27, 18, 2), (27, 24, 1),
(28, 10, 2), (28, 16, 1), (28, 22, 1),
(29,  5, 2), (29, 12, 1),
(30,  7, 1), (30, 19, 1), (30, 24, 2),
(31,  3, 1), (31, 21, 1),
(32, 16, 2), (32, 18, 1), (32, 25, 1),
(33, 13, 1), (33, 15, 1),
(34, 21, 2), (34, 26, 1),
(35,  6, 1), (35,  7, 1), (35, 19, 1),
-- Mayo (NOVENTA 36-39)
(36,  5, 2), (36, 11, 3),
(37, 16, 2), (37, 18, 3),
(38,  1, 1), (38,  6, 1),
(39,  5, 1), (39, 12, 2), (39, 24, 1),
-- Junio (NOVENTA 40-43)
(40,  7, 2), (40, 10, 1),
(41,  2, 1), (41,  9, 1),
(42, 22, 2), (42, 10, 1),
(43,  1, 1), (43,  5, 1),
-- Julio (NOVENTA 44-46)
(44,  8, 1), (44, 23, 1),
(45, 11, 2), (45, 22, 3),
(46, 16, 2), (46, 18, 3),
-- Agosto (NOVENTA 47-48)
(47, 22, 4), (47, 25, 1),
(48, 18, 3), (48, 16, 2),
-- Septiembre (NOVENTA 49-50)
(49,  3, 1), (49,  7, 1),
(50,  6, 1), (50, 19, 1);

-- ============================================================
-- DATOS: FACTURAS (22 facturas, NOFACTURA 1-22)
-- ============================================================

INSERT INTO FACTURAS (FECHAF, FORMAPAGO, PAGADA, CODPROV) VALUES
('2024-01-05', 'Transferencia bancaria', 1, 1),  --  1
('2024-01-20', 'Transferencia bancaria', 1, 2),  --  2
('2024-02-10', 'Pagaré 30 días',         1, 3),  --  3
('2024-02-25', 'Transferencia bancaria', 1, 4),  --  4
('2024-03-08', 'Pagaré 60 días',         0, 5),  --  5
('2024-03-15', 'Transferencia bancaria', 1, 1),  --  6
('2024-04-01', 'Pagaré 30 días',         1, 2),  --  7
('2024-04-02', 'Transferencia bancaria', 1, 1),  --  8
('2024-04-08', 'Pagaré 30 días',         1, 2),  --  9
('2024-04-10', 'Transferencia bancaria', 1, 3),  -- 10
('2024-04-15', 'Pagaré 60 días',         0, 6),  -- 11
('2024-04-20', 'Transferencia bancaria', 0, 3),  -- 12
('2024-04-22', 'Transferencia bancaria', 1, 4),  -- 13
('2024-04-28', 'Pagaré 30 días',         0, 7),  -- 14
('2024-05-03', 'Transferencia bancaria', 1, 5),  -- 15
('2024-05-05', 'Pagaré 60 días',         0, 4),  -- 16
('2024-05-18', 'Pagaré 30 días',         0, 1),  -- 17
('2024-05-22', 'Transferencia bancaria', 1, 5),  -- 18
('2024-06-05', 'Transferencia bancaria', 1, 6),  -- 19
('2024-06-10', 'Transferencia bancaria', 0, 1),  -- 20
('2024-06-20', 'Pagaré 60 días',         0, 2),  -- 21
('2024-06-25', 'Pagaré 30 días',         0, 2);  -- 22

-- ============================================================
-- DATOS: LINEASFACTURA
-- ============================================================

INSERT INTO LINEASFACTURA (NOFACTURA, CODARTI, CANTIDAD) VALUES
-- Enero-Febrero
(1,  3,  10), (1,  4,  15), (1,  13,  8),
(2,  1,  20), (2,  2,  15), (2,   8, 10), (2, 14, 12),
(3,  5,  25), (3, 10,  20), (3,  12, 15),
(4,  6,  10), (4,  7,  12), (4,  15,  8),
-- Marzo
(5,  11, 30),
(6,  3,  10), (6,  4,  10), (6,  13,  8),
-- Abril
(7,  1,  15), (7,  9,   6),
(8,  3,  12), (8,  4,  18), (8,  17, 10), (8, 21, 15),
(9,  1,  25), (9,  2,  20), (9,   8, 12), (9, 23,  8),
(10, 5,  30), (10, 10, 25), (10, 12, 20), (10, 18, 22), (10, 22, 30),
(11, 16, 20), (11, 25, 18), (11, 20, 15),
(12, 5,  20), (12, 10, 15), (12, 12, 10),
(13, 6,  12), (13,  7, 15), (13, 19, 10), (13, 27, 12),
(14, 20, 18), (14, 24, 14),
-- Mayo-Junio
(15, 11, 40), (15, 26, 20),
(16, 6,  10), (16,  7, 10),
(17, 3,  15), (17,  4, 20), (17, 21, 12),
(18, 11, 25), (18,  2, 12),
(19, 16, 22), (19, 25, 18),
(20, 3,   8), (20,  4, 10),
(21, 1,  12), (21,  2, 10), (21, 14,  8),
(22, 2,  20), (22,  8, 10), (22, 14, 15);

-- ============================================================
-- DATOS: PAGOS
-- Facturas pagadas (PAGADA=1): 1,2,3,4,6,7,8,9,10,13,15,18,19
-- ============================================================

INSERT INTO PAGOS (NOFACTURA, NOPAGO, FECHAPAGO, IMPORTE) VALUES
(1,  1, '2024-01-05',  1850.00),
(2,  1, '2024-01-20',  2500.00),
(2,  2, '2024-02-20',  1200.00),
(3,  1, '2024-03-10',  1890.00),
(4,  1, '2024-02-25',  2340.00),
(6,  1, '2024-03-15',  1750.00),
(7,  1, '2024-04-01',  1800.00),
(7,  2, '2024-05-01',   980.00),
(8,  1, '2024-04-02',  2340.00),
(9,  1, '2024-04-08',  2850.00),
(9,  2, '2024-05-08',  1540.00),
(10, 1, '2024-04-10',  3120.00),
(10, 2, '2024-04-25',  1580.00),
(13, 1, '2024-04-22',  2780.00),
(15, 1, '2024-05-03',  1640.00),
(18, 1, '2024-05-22',  1250.00),
(18, 2, '2024-06-22',   620.00),
(19, 1, '2024-06-05',  2160.00),
(19, 2, '2024-06-30',   980.00);

-- ============================================================
-- FIN DEL SCRIPT COMPLETO Y CORREGIDO
-- ============================================================