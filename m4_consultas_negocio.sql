-- PRE-ENTREGA 4: CONSULTAS SQL DE NEGOCIO
-- Proyecto: Ventas_Tech_DB (RetailPro)
-- Motor utilizado: SQL Server (Azure Data Studio en macOS)

-- CONSULTA 1 — Resumen  mensual
--Total facturado, cantidad de pedidos y ticket promedio, agrupados por mes.
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(id_venta) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);


-- CONSULTA 2 — Ranking de productos
-- Top 5 de id_producto por total facturado, mostrando unidades y total generado.
SELECT TOP 5 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- CONSULTA 3 — Clientes recurrentes
-- Clientes que realizaron más de un pedido, con cantidad de pedidos y total gastado.
SELECT 
    id_cliente,
    COUNT(id_venta) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(id_venta) > 1;


-- CONSULTA 4 — Productos por encima/por debajo del promedio
-- Facturación por producto etiquetada comparada con el promedio general.
WITH FacturacionProductos AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
),
PromedioGeneral AS (
    SELECT AVG(total_facturado) AS promedio_facturacion
    FROM FacturacionProductos
)
SELECT 
    fp.id_producto,
    fp.total_facturado,
    CASE 
        WHEN fp.total_facturado >= pg.promedio_facturacion THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM FacturacionProductos fp
CROSS JOIN PromedioGeneral pg;


-- SINTESIS Y RESPUESTAS:
-- 1. Concentración de ventas: El producto ID 1 (Laptop Pro 15) lidera ampliamente 
--    el ranking de facturación debido a su alto precio unitario, a pesar de no ser 
--   el artículo con mayor volumen de unidades vendidas.
-- 2. Comportamiento de clientes recurrentes: Los clientes 1 y 3 muestran patrones 
--    de compra repetitivos (más de un pedido), lo que los posiciona como clientes 
--    clave de alta fidelización para campañas de retención.
-- 3. Polarización de ticket: El análisis por tramos de facturación por producto 
--    muestra una clara división entre productos de alta gama (como Laptops y Monitores) 
--    y accesorios de menor valor (como mouses y auriculares).