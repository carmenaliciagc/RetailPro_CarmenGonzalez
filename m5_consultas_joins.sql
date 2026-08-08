--Creación de la Base de Datos Retail Pro
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RetailPro')
BEGIN
    CREATE DATABASE RetailPro;
END
USE RetailPro;

--Eliminación de Tablas
DROP TABLE IF EXISTS ventas_presencial;
DROP TABLE IF EXISTS ventas_online;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS territorios;

--Creación de Tablas
CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    fecha_registro DATE NOT NULL,
    segmento VARCHAR(50)
);

CREATE TABLE productos (
    producto_id INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);

CREATE TABLE territorios (
    territorio_id INT PRIMARY KEY,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE ventas_presencial (
    venta_id INT PRIMARY KEY,
    fecha DATE NOT NULL,
    cliente_id INT,
    producto_id INT,
    territorio_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    monto_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id),
    FOREIGN KEY (territorio_id) REFERENCES territorios(territorio_id)
);

CREATE TABLE ventas_online (
    venta_id INT PRIMARY KEY,
    fecha DATE NOT NULL,
    cliente_id INT,
    producto_id INT,
    monto_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

--Insertar Datos

--Tabla Clientes
INSERT INTO clientes (cliente_id, nombre, email, fecha_registro, segmento) VALUES
(1, 'María García', 'maria@email.com', '2026-03-01', 'Corporativo'),
(2, 'Juan Pérez', 'juan@email.com', '2026-03-02', 'Consumo'),
(3, 'Carlos López', 'carlos@email.com', '2026-03-03', 'PyME'),
(4, 'Ana Martínez', 'ana@email.com',  '2026-03-04','Consumo');

--Tabla Productos
INSERT INTO productos (producto_id, nombre_producto, categoria, precio) VALUES
(10, 'Notebook Pro 15', 'Tecnología', 1200.00),
(20, 'Monitor 27 Pulgadas', 'Tecnología', 550.00),
(30, 'Silla Ergonómica', 'Mobiliario', 220.00),
(40, 'Teclado Mecánico', 'Accesorios', 90.00);

--Tabla Territorios
INSERT INTO territorios (territorio_id, region) VALUES
(100, 'Norte'),
(200, 'Sur'),
(300, 'Centro');

--Tabla Ventas Presencial
INSERT INTO ventas_presencial (venta_id, fecha, cliente_id, producto_id, territorio_id, cantidad, precio_unitario, monto_total) VALUES
(1, '2026-03-01', 1, 10, 100, 1, 1200.00, 1200.00),
(2, '2026-03-02', 2, 20, 200, 2, 300.00, 600.00),
(3, '2026-03-03', 3, 30, 300, 1, 250.00, 250.00),
(4, '2026-03-04', 1, 40, 100, 2, 50.00, 100.00);

--Tabla Ventas Online
INSERT INTO ventas_online (venta_id, fecha, cliente_id, producto_id, monto_total) VALUES
(100, '2026-03-01', 1, 10, 250.00),
(101, '2026-03-02', 2, 20, 640.00),
(102, '2026-03-05', 99, 40, 100.00);

--Consulta 1 — Vista base del proyecto (INNER JOIN)
SELECT
    vp.fecha,
    c.nombre AS nombre_cliente,
    c.segmento,
    t.region,
    p.nombre_producto,
    p.categoria,
    vp.cantidad,
    vp.precio_unitario,
    vp.monto_total,
    'Presencial' AS canal
FROM ventas_presencial vp
INNER JOIN clientes c ON vp.cliente_id = c.cliente_id
INNER JOIN productos p ON vp.producto_id = p.producto_id
INNER JOIN territorios t ON vp.territorio_id = t.territorio_id

--Consulta 2 — Clientes sin ventas (LEFT JOIN)
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas_presencial vp ON c.cliente_id = vp.cliente_id
LEFT JOIN ventas_online vo ON c.cliente_id = vo.cliente_id
WHERE vo.venta_id IS NULL AND vp.venta_id IS NULL;

--Consulta 3 — Productos sin ventas (LEFT JOIN)
SELECT
    p.nombre_producto,
    p.categoria,
    p.precio
FROM productos p
LEFT JOIN ventas_presencial vp ON p.producto_id = vp.producto_id
LEFT JOIN ventas_online vo ON p.producto_id = vo.producto_id
WHERE vo.venta_id IS NULL AND vp.venta_id IS NULL;

--Consulta 4 — Consolidado por canal (UNION ALL)
SELECT
    canal,
    SUM (monto_total) AS total_por_canal
FROM (
    SELECT monto_total,'Online' AS canal FROM ventas_online
    UNION ALL
    SELECT monto_total, 'Presencial' AS canal FROM ventas_presencial
) AS ventas_totales
GROUP BY canal;
