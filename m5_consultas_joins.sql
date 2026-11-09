-- PRE-ENTREGA 5: CONSULTAS CON JOINS PARA EL PROYECTO
-- Motor utilizado: SQL Server (Azure Data Studio en macOS)

-- ============================================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Combinar ventas con clientes, productos y categorías para obtener 
-- la vista enriquecida que servirá como fuente de datos principal en Power BI.
SELECT 
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS cliente,
    c.ciudad AS region,
    p.nombre_producto,
    cat.nombre_categoria AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;

-- Hallazgo: La vista unificada consolida con éxito la trazabilidad completa de cada 
-- transacción, vinculando al cliente y al producto de audio (Auriculares BT Pro) 
-- con su respectiva categoría, estructurando la base analítica clave para migrarlo a PowerBI.


-- ============================================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Identificar clientes registrados que aún no han realizado ninguna 
-- compra, permitiendo al área de CRM lanzar campañas de activación.
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgo: No see detectaron registros de clientes que aún no registran transacciones 
-- en el sistema


-- ============================================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Detectar artículos del catálogo que no tienen ninguna venta registrada 
-- para que el área de producto evalúe su rotación o estrategia comercial.

SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgo: Al no haber ningún producto inactivo o sin ventas, el 
-- filtro WHERE v.id_venta IS NULL también devuelve 0 resultados.


-- ============================================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: Comparar el volumen de facturación segmentado por canales de venta 
-- (Online vs Presencial) utilizando valores literales y UNION ALL.

SELECT canal, SUM(total) AS total_canal
FROM (
    -- Ventas del canal Online (ej. primera quincena de marzo)
    SELECT fecha_venta, (cantidad * precio_unitario) AS total, 'Online' AS canal
    FROM ventas 
    WHERE fecha_venta <= '2024-03-10'
    
    UNION ALL
    
    -- Ventas del canal Presencial (ej. segunda quincena de marzo)
    SELECT fecha_venta, (cantidad * precio_unitario) AS total, 'Presencial' AS canal
    FROM ventas 
    WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY canal;

-- Hallazgo: La segmentación por canales muestra la distribución temporal de los ingresos 
-- de la compañía, nos muestra que hay un mayor volumen de ventas por canal ONLINE