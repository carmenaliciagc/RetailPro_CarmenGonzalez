--Selección de la base de datos

USE Ventas_Tech_DB;

-- Resumen Ejecutivo Mensual

SELECT 
    MONTH(fecha_venta) AS mes,
    SUM (cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS total_pedidos,
    AVG(cantidad * precio_unitario) as ticket_promedio
FROM Ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- Ranking de productos

SELECT TOP (5)
    id_producto,
    SUM (cantidad) AS unidades_vendidas,
    SUM (cantidad * precio_unitario) AS total_facturado
FROM Ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- Clientes recurrentes

SELECT id_cliente,
    COUNT (*) AS cantidad_pedidos,
    SUM (cantidad * precio_unitario) AS total_gastado
FROM Ventas
GROUP BY id_cliente
HAVING COUNT (*) > 1
ORDER BY total_gastado DESC;

-- Meses por encima/por debajo del promedio 

SELECT
    MONTH(fecha_venta) AS mes,
    SUM (cantidad*precio_unitario) AS total_facturado,
    CASE
        WHEN SUM(cantidad*precio_unitario) > (SELECT AVG(total_mensual)
                                               FROM (SELECT SUM(cantidad*precio_unitario) AS total_mensual
                                                        FROM Ventas
                                                        GROUP BY MONTH(fecha_venta))
                                               AS promedio_mensual)
            THEN 'Por encima del promedio'
        ELSE 'Por debajo del promedio'
    END AS estado
FROM Ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- Hallazgos
-- El producto 1 concentra el 55% de la facturación
-- Las compras del cliente 1 representaron el 40% de la facturación
-- Las compras de los clientes 1, 5 y 3 se encontraron por encima del ticket promedio
