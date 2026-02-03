-- ============================================================================
-- PROYECTO COMPLETO: ANÁLISIS EFICIENCIA DIDI FOOD
-- Sistema de 4 scripts para análisis de miniproyecto
-- Estructura: unidades_progreso = pedidos_cohete (conteo directo)
-- ============================================================================

-- ============================================================================
-- SCRIPT 1: CREAR BASE DE DATOS Y CARGAR DATOS
-- ============================================================================

CREATE DATABASE IF NOT EXISTS didi_operaciones
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE didi_operaciones;

-- Tabla RAW (backup sagrado)
DROP TABLE IF EXISTS registros_didi_raw;

CREATE TABLE registros_didi_raw (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    ingreso_base DECIMAL(10,2) NOT NULL,
    complemento_bono DECIMAL(10,2) NOT NULL,
    garantizado_meta DECIMAL(10,2) NOT NULL,
    pedidos_fisicos INT NOT NULL,
    unidades_progreso INT NOT NULL COMMENT 'Cantidad de pedidos cohete',
    gastos_operativos DECIMAL(10,2) DEFAULT 0,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_fecha (fecha)
) ENGINE=InnoDB;

-- Insertar datos completos (24 días)
INSERT INTO registros_didi_raw 
(fecha, ingreso_base, complemento_bono, garantizado_meta, pedidos_fisicos, unidades_progreso, gastos_operativos)
VALUES
('2025-12-05', 66676, 63324, 130000, 12, 11, 17000),
('2025-12-06', 86990, 101010, 188000, 15, 15, 17000),
('2025-12-07', 94980, 134020, 229000, 17, 14, 18000),
('2025-12-08', 87390, 121610, 209000, 17, 17, 21000),
('2025-12-13', 72264, 70736, 143000, 11, 10, 58000),
('2025-12-14', 113138, 137862, 251000, 18, 18, 19000),
('2025-12-20', 137686, 125314, 263000, 20, 18, 16000),
('2025-12-21', 137538, 130462, 268000, 18, 18, 21500),
('2025-12-23', 42654, 30346, 73000, 8, 6, 16000),
('2025-12-24', 67362, 64638, 132000, 10, 8, 0),
('2025-12-25', 133056, 168944, 302000, 21, 12, 14000),
('2025-12-27', 84076, 100924, 185000, 15, 9, 19000),
('2025-12-28', 102150, 180850, 283000, 18, 13, 15000),
('2025-12-31', 59162, 65838, 125000, 13, 10, 0),
('2026-01-01', 112975, 70025, 183000, 17, 12, 0),
('2026-01-04', 72888, 41112, 114000, 15, 8, 18000),
('2026-01-08', 16921, 14079, 31000, 3, 3, 0),
('2026-01-10', 84425, 62575, 147000, 12, 12, 17000),
('2026-01-11', 134896, 109104, 244000, 18, 18, 0),
('2026-01-12', 57136, 46864, 104000, 9, 7, 20000),
('2026-01-17', 80157, 38843, 119000, 11, 10, 16000),
('2026-01-18', 120293, 86207, 206500, 19, 17, 21000),
('2026-01-24', 44244, 3256, 47500, 6, 3, 18000),
('2026-01-25', 119277, 50223, 169500, 16, 15, 0);

-- Verificar carga
SELECT COUNT(*) AS total, MIN(fecha) AS desde, MAX(fecha) AS hasta FROM registros_didi_raw;


-- ============================================================================
-- SCRIPT 2: CREAR TABLA DE ANÁLISIS CON VARIABLES CALCULADAS
-- ============================================================================

DROP TABLE IF EXISTS registros_didi_analisis;

CREATE TABLE registros_didi_analisis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    
    -- Variables originales
    ingreso_base DECIMAL(10,2) NOT NULL,
    complemento_bono DECIMAL(10,2) NOT NULL,
    garantizado_meta DECIMAL(10,2) NOT NULL,
    pedidos_fisicos INT NOT NULL,
    pedidos_cohete INT NOT NULL COMMENT 'unidades_progreso = cohetes',
    gastos_operativos DECIMAL(10,2) DEFAULT 0,
    
    -- Variables calculadas
    pedidos_normales INT COMMENT 'pedidos_fisicos - pedidos_cohete',
    utilidad_real DECIMAL(10,2) COMMENT 'garantizado_meta - gastos_operativos',
    eficiencia_cohete DECIMAL(5,2) COMMENT '(pedidos_cohete / pedidos_fisicos) * 100',
    ingreso_por_pedido DECIMAL(8,2) COMMENT 'garantizado_meta / pedidos_fisicos',
    costo_por_pedido DECIMAL(8,2) COMMENT 'gastos_operativos / pedidos_fisicos',
    utilidad_por_pedido DECIMAL(8,2) COMMENT 'utilidad_real / pedidos_fisicos',
    
    -- Clasificaciones
    nivel_eficiencia ENUM('Bajo', 'Medio', 'Alto', 'Excelente') COMMENT 'Clasificación por eficiencia cohete',
    nivel_utilidad ENUM('Bajo', 'Medio', 'Alto') COMMENT 'Clasificación por utilidad',
    
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_fecha (fecha),
    INDEX idx_eficiencia (eficiencia_cohete),
    INDEX idx_utilidad (utilidad_real)
) ENGINE=InnoDB;

-- Migrar y calcular todo
INSERT INTO registros_didi_analisis 
(fecha, ingreso_base, complemento_bono, garantizado_meta, pedidos_fisicos, pedidos_cohete, gastos_operativos)
SELECT 
    fecha,
    ingreso_base,
    complemento_bono,
    garantizado_meta,
    pedidos_fisicos,
    unidades_progreso AS pedidos_cohete,
    gastos_operativos
FROM registros_didi_raw;

-- Calcular variables derivadas
UPDATE registros_didi_analisis
SET 
    pedidos_normales = pedidos_fisicos - pedidos_cohete,
    utilidad_real = garantizado_meta - gastos_operativos,
    eficiencia_cohete = ROUND((pedidos_cohete / pedidos_fisicos) * 100, 2),
    ingreso_por_pedido = ROUND(garantizado_meta / pedidos_fisicos, 2),
    costo_por_pedido = ROUND(gastos_operativos / pedidos_fisicos, 2),
    utilidad_por_pedido = ROUND((garantizado_meta - gastos_operativos) / pedidos_fisicos, 2),
    
    nivel_eficiencia = CASE 
        WHEN (pedidos_cohete / pedidos_fisicos) * 100 >= 90 THEN 'Excelente'
        WHEN (pedidos_cohete / pedidos_fisicos) * 100 >= 70 THEN 'Alto'
        WHEN (pedidos_cohete / pedidos_fisicos) * 100 >= 50 THEN 'Medio'
        ELSE 'Bajo'
    END,
    
    nivel_utilidad = CASE 
        WHEN (garantizado_meta - gastos_operativos) >= 200000 THEN 'Alto'
        WHEN (garantizado_meta - gastos_operativos) >= 100000 THEN 'Medio'
        ELSE 'Bajo'
    END
WHERE pedidos_fisicos > 0;

-- Ver resultados
SELECT * FROM registros_didi_analisis ORDER BY fecha DESC LIMIT 10;


-- ============================================================================
-- SCRIPT 3: CREAR VISTAS Y MÉTRICAS AGREGADAS
-- ============================================================================

-- Vista: Resumen mensual
CREATE OR REPLACE VIEW v_resumen_mensual AS
SELECT 
    DATE_FORMAT(fecha, '%Y-%m') AS mes,
    COUNT(*) AS dias_trabajados,
    SUM(pedidos_fisicos) AS total_pedidos,
    SUM(pedidos_cohete) AS total_cohetes,
    AVG(eficiencia_cohete) AS eficiencia_promedio,
    SUM(garantizado_meta) AS ingreso_total,
    SUM(gastos_operativos) AS gastos_totales,
    SUM(utilidad_real) AS utilidad_total,
    AVG(utilidad_real) AS utilidad_promedio_dia,
    AVG(ingreso_por_pedido) AS ingreso_promedio_pedido
FROM registros_didi_analisis
GROUP BY mes
ORDER BY mes DESC;

-- Vista: Top días por eficiencia
CREATE OR REPLACE VIEW v_mejores_dias_eficiencia AS
SELECT 
    fecha,
    pedidos_fisicos,
    pedidos_cohete,
    eficiencia_cohete,
    utilidad_real,
    ingreso_por_pedido,
    nivel_eficiencia
FROM registros_didi_analisis
ORDER BY eficiencia_cohete DESC, utilidad_real DESC;

-- Vista: Análisis por nivel de eficiencia
CREATE OR REPLACE VIEW v_analisis_por_nivel AS
SELECT 
    nivel_eficiencia,
    COUNT(*) AS dias,
    AVG(eficiencia_cohete) AS eficiencia_promedio,
    AVG(utilidad_real) AS utilidad_promedio,
    AVG(ingreso_por_pedido) AS ingreso_promedio_pedido,
    SUM(utilidad_real) AS utilidad_total
FROM registros_didi_analisis
GROUP BY nivel_eficiencia
ORDER BY FIELD(nivel_eficiencia, 'Excelente', 'Alto', 'Medio', 'Bajo');

-- Tabla de métricas globales
DROP TABLE IF EXISTS metricas_globales;
CREATE TABLE metricas_globales AS
SELECT 
    COUNT(*) AS total_dias,
    SUM(pedidos_fisicos) AS total_pedidos,
    SUM(pedidos_cohete) AS total_cohetes,
    
    -- Promedios
    AVG(pedidos_fisicos) AS pedidos_promedio_dia,
    AVG(eficiencia_cohete) AS eficiencia_cohete_promedio,
    AVG(garantizado_meta) AS ingreso_promedio_dia,
    AVG(utilidad_real) AS utilidad_promedio_dia,
    
    -- Extremos
    MIN(utilidad_real) AS utilidad_minima,
    MAX(utilidad_real) AS utilidad_maxima,
    MIN(eficiencia_cohete) AS eficiencia_minima,
    MAX(eficiencia_cohete) AS eficiencia_maxima,
    
    -- Desviaciones
    STDDEV(utilidad_real) AS utilidad_desviacion,
    STDDEV(eficiencia_cohete) AS eficiencia_desviacion,
    
    -- Totales
    SUM(garantizado_meta) AS ingreso_total_periodo,
    SUM(gastos_operativos) AS gastos_total_periodo,
    SUM(utilidad_real) AS utilidad_total_periodo,
    
    -- ROI
    ROUND(
  (SUM(utilidad_real) / NULLIF(SUM(gastos_operativos), 0)) * 100,
  2
) AS roi_porcentaje
FROM registros_didi_analisis;

SELECT * FROM metricas_globales;


-- ============================================================================
-- SCRIPT 4: QUERIES DE ANÁLISIS PARA TESIS
-- ============================================================================

-- ANÁLISIS 1: Resumen general
SELECT 'RESUMEN GENERAL DEL PERIODO' AS analisis;
SELECT * FROM metricas_globales;

-- ANÁLISIS 2: Desempeño mensual
SELECT 'DESEMPEÑO POR MES' AS analisis;
SELECT * FROM v_resumen_mensual;

-- ANÁLISIS 3: Clasificación por nivel de eficiencia
SELECT 'ANÁLISIS POR NIVEL DE EFICIENCIA' AS analisis;
SELECT * FROM v_analisis_por_nivel;

-- ANÁLISIS 4: Top 10 mejores días
SELECT 'TOP 10 MEJORES DÍAS (EFICIENCIA)' AS analisis;
SELECT * FROM v_mejores_dias_eficiencia LIMIT 10;

-- ANÁLISIS 5: Top 10 mejores días (utilidad)
SELECT 'TOP 10 MEJORES DÍAS (UTILIDAD)' AS analisis;
SELECT fecha, utilidad_real, eficiencia_cohete, pedidos_fisicos, nivel_utilidad
FROM registros_didi_analisis
ORDER BY utilidad_real DESC
LIMIT 10;

-- ANÁLISIS 6: Correlación eficiencia vs utilidad
SELECT 'CORRELACIÓN EFICIENCIA-UTILIDAD' AS analisis;
SELECT 
    CASE 
        WHEN eficiencia_cohete >= 90 THEN '90-100%'
        WHEN eficiencia_cohete >= 80 THEN '80-89%'
        WHEN eficiencia_cohete >= 70 THEN '70-79%'
        WHEN eficiencia_cohete >= 60 THEN '60-69%'
        ELSE '<60%'
    END AS rango_eficiencia,
    COUNT(*) AS dias,
    AVG(utilidad_real) AS utilidad_promedio,
    AVG(ingreso_por_pedido) AS ingreso_promedio_pedido
FROM registros_didi_analisis
GROUP BY rango_eficiencia
ORDER BY AVG(eficiencia_cohete) DESC;

-- ANÁLISIS 7: Días con alta vs baja utilidad
SELECT 'COMPARACIÓN ALTA VS BAJA UTILIDAD' AS analisis;
SELECT 
    nivel_utilidad,
    COUNT(*) AS dias,
    AVG(eficiencia_cohete) AS eficiencia_promedio,
    AVG(pedidos_fisicos) AS pedidos_promedio,
    AVG(gastos_operativos) AS gastos_promedio
FROM registros_didi_analisis
GROUP BY nivel_utilidad
ORDER BY FIELD(nivel_utilidad, 'Alto', 'Medio', 'Bajo');

-- ANÁLISIS 8: Composición de ingresos
SELECT 'COMPOSICIÓN DE INGRESOS' AS analisis;
SELECT 
    SUM(ingreso_base) AS ingreso_base_total,
    SUM(complemento_bono) AS complemento_total,
    SUM(garantizado_meta) AS ingreso_total,
    ROUND(SUM(ingreso_base) / SUM(garantizado_meta) * 100, 2) AS porcentaje_base,
    ROUND(SUM(complemento_bono) / SUM(garantizado_meta) * 100, 2) AS porcentaje_complemento
FROM registros_didi_analisis;

-- ANÁLISIS 9: Tendencia temporal
SELECT 'TENDENCIA TEMPORAL (SEMANAL)' AS analisis;
SELECT 
    YEARWEEK(fecha) AS semana,
    COUNT(*) AS dias_trabajados,
    AVG(eficiencia_cohete) AS eficiencia_promedio,
    AVG(utilidad_real) AS utilidad_promedio,
    SUM(utilidad_real) AS utilidad_semanal
FROM registros_didi_analisis
GROUP BY semana
ORDER BY semana;

-- ANÁLISIS 10: Días extremos (outliers)
SELECT 'MEJOR DÍA' AS tipo, fecha, utilidad_real, eficiencia_cohete, pedidos_fisicos
FROM registros_didi_analisis
WHERE utilidad_real = (SELECT MAX(utilidad_real) FROM registros_didi_analisis)

UNION ALL

SELECT 'PEOR DÍA', fecha, utilidad_real, eficiencia_cohete, pedidos_fisicos
FROM registros_didi_analisis
WHERE utilidad_real = (SELECT MIN(utilidad_real) FROM registros_didi_analisis)

UNION ALL

SELECT 'MÁXIMA EFICIENCIA', fecha, utilidad_real, eficiencia_cohete, pedidos_fisicos
FROM registros_didi_analisis
WHERE eficiencia_cohete = (SELECT MAX(eficiencia_cohete) FROM registros_didi_analisis);

-- ============================================================================
-- FIN DE LOS SCRIPTS
-- ============================================================================
