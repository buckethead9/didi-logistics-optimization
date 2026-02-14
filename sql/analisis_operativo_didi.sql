-- ====================================================================
-- PIPELINE DE AUDITORÍA - ARBITRAJE ALGORÍTMICO DIDI FOOD
-- Versión: 1.0.0
-- Base de Datos: MySQL 8.0+
-- Autor: Ingeniero de Datos Senior
-- Fecha: 2026-02-13
-- ====================================================================

-- ====================================================================
-- SECCIÓN 1: CONFIGURACIÓN INICIAL
-- ====================================================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS didi_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE didi_analytics;

-- Eliminar tabla si existe (para re-ejecución limpia)
DROP TABLE IF EXISTS didi_operaciones;

-- ====================================================================
-- SECCIÓN 2: DEFINICIÓN DE TABLA PRINCIPAL
-- ====================================================================

CREATE TABLE didi_operaciones (
    -- Variables Primarias
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL COMMENT 'Fecha del día operativo',
    h_inicio TIME NOT NULL COMMENT 'Hora de inicio del turno',
    h_fin TIME NOT NULL COMMENT 'Hora de fin del turno',
    
    -- Distancias
    km_google DECIMAL(8,2) NOT NULL COMMENT 'Distancia según Google Maps (ciclorrutas)',
    km_didi DECIMAL(8,2) NOT NULL COMMENT 'Distancia según DiDi App (rutas motorizadas)',
    
    -- Ingresos
    garantizado_meta INT NOT NULL COMMENT 'Ingreso total garantizado (COP)',
    ingreso_base INT NOT NULL COMMENT 'Ingreso base por pedidos (COP)',
    complemento_bono INT NOT NULL COMMENT 'Bono por cumplir meta (COP)',
    
    -- Pedidos
    pedidos_fisicos INT NOT NULL COMMENT 'Número de pedidos completados',
    unidades_progreso INT NOT NULL COMMENT 'Unidades contabilizadas por DiDi',
    
    -- Gastos
    gastos_operativos INT NOT NULL DEFAULT 0 COMMENT 'Gastos del turno (COP)',
    
    -- Variables Derivadas (Calculadas en Python o con triggers)
    duracion_horas DECIMAL(5,2) COMMENT 'Duración del turno en horas',
    utilidad_neta INT COMMENT 'Ganancia neta después de gastos (COP)',
    ratio_optimizacion DECIMAL(4,2) COMMENT 'RO: km_didi / km_google',
    km_por_pedido_google DECIMAL(5,2) COMMENT 'KM por pedido según Google',
    km_por_pedido_didi DECIMAL(5,2) COMMENT 'KM por pedido según DiDi',
    ingreso_por_km_google DECIMAL(8,2) COMMENT 'Ingreso por KM (Google)',
    ingreso_por_km_didi DECIMAL(8,2) COMMENT 'Ingreso por KM (DiDi)',
    ingreso_por_hora DECIMAL(8,2) COMMENT 'Ingreso por hora trabajada',
    utilidad_por_hora DECIMAL(8,2) COMMENT 'Utilidad por hora trabajada',
    eficiencia_cumplimiento DECIMAL(4,2) COMMENT 'Unidades / Pedidos',
    proporcion_bono DECIMAL(4,2) COMMENT 'Bono / Ingreso Total',
    roi_diario DECIMAL(8,2) COMMENT 'ROI diario (%)',
    rentabilidad_binaria TINYINT(1) COMMENT '1 si utilidad > 0, 0 si no',
    
    -- Índices para optimización de consultas
    INDEX idx_fecha (fecha),
    INDEX idx_utilidad (utilidad_neta DESC),
    INDEX idx_roi (roi_diario DESC),
    INDEX idx_pedidos (pedidos_fisicos)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tabla principal de operaciones DiDi Food';

-- ====================================================================
-- SECCIÓN 3: CARGA DE DATOS
-- ====================================================================

-- NOTA: Los datos se deben cargar desde el CSV procesado.
-- Opción 1: Usar LOAD DATA INFILE
-- LOAD DATA INFILE '/ruta/a/didi_procesado.csv'
-- INTO TABLE didi_operaciones
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- Opción 2: Insertar manualmente o desde script Python con mysql-connector

-- ====================================================================
-- SECCIÓN 4: VISTAS DE ANÁLISIS (10 VISTAS)
-- ====================================================================

-- --------------------------------------------------------------------
-- VISTA 1: RESUMEN GLOBAL
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_resumen_global AS
SELECT
    COUNT(*) AS n_registros,
    SUM(garantizado_meta) AS total_ingresos_cop,
    SUM(gastos_operativos) AS total_gastos_cop,
    SUM(utilidad_neta) AS utilidad_neta_cop,
    ROUND((SUM(utilidad_neta) / SUM(gastos_operativos)) * 100, 2) AS roi_global_pct,
    ROUND(SUM(km_didi) / SUM(km_google), 2) AS ro_global,
    ROUND(SUM(garantizado_meta) / SUM(gastos_operativos), 2) AS multiplo_ingreso,
    SUM(pedidos_fisicos) AS total_pedidos,
    ROUND(SUM(duracion_horas), 2) AS duracion_total_horas,
    ROUND(SUM(km_google), 2) AS km_google_total,
    ROUND(SUM(km_didi), 2) AS km_didi_total,
    SUM(CASE WHEN gastos_operativos = 0 THEN 1 ELSE 0 END) AS dias_gasto_cero
FROM didi_operaciones;

-- --------------------------------------------------------------------
-- VISTA 2: MÉTRICAS PROMEDIO POR DÍA
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_promedios AS
SELECT
    ROUND(AVG(garantizado_meta), 2) AS ingreso_promedio_cop,
    ROUND(AVG(utilidad_neta), 2) AS utilidad_promedio_cop,
    ROUND(AVG(gastos_operativos), 2) AS gasto_promedio_cop,
    ROUND(AVG(pedidos_fisicos), 2) AS pedidos_promedio,
    ROUND(AVG(duracion_horas), 2) AS duracion_promedio_horas,
    ROUND(AVG(ratio_optimizacion), 2) AS ro_promedio,
    ROUND(AVG(ingreso_por_hora), 2) AS ingreso_hora_promedio_cop,
    ROUND(AVG(utilidad_por_hora), 2) AS utilidad_hora_promedio_cop,
    ROUND(AVG(km_google), 2) AS km_google_promedio,
    ROUND(AVG(km_didi), 2) AS km_didi_promedio
FROM didi_operaciones;

-- --------------------------------------------------------------------
-- VISTA 3: TOP 10 MEJORES DÍAS (Por Utilidad)
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_top_10_mejores_dias AS
SELECT
    RANK() OVER (ORDER BY utilidad_neta DESC) AS ranking,
    fecha,
    utilidad_neta AS utilidad_cop,
    ROUND(roi_diario, 2) AS roi_pct,
    pedidos_fisicos,
    duracion_horas,
    ROUND(ingreso_por_hora, 2) AS ingreso_hora_cop,
    ROUND(ratio_optimizacion, 2) AS ro
FROM didi_operaciones
ORDER BY utilidad_neta DESC
LIMIT 10;

-- --------------------------------------------------------------------
-- VISTA 4: TOP 10 PEORES DÍAS (Por Utilidad)
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_top_10_peores_dias AS
SELECT
    RANK() OVER (ORDER BY utilidad_neta ASC) AS ranking,
    fecha,
    utilidad_neta AS utilidad_cop,
    gastos_operativos AS gastos_cop,
    pedidos_fisicos,
    duracion_horas,
    CASE
        WHEN pedidos_fisicos < 8 THEN 'Bajo volumen'
        WHEN duracion_horas < 5 THEN 'Turno corto'
        WHEN gastos_operativos > 20000 THEN 'Gastos altos'
        WHEN gastos_operativos = 0 THEN 'Sin gastos (anomalía)'
        ELSE 'Baja eficiencia'
    END AS falla_tecnica
FROM didi_operaciones
ORDER BY utilidad_neta ASC
LIMIT 10;

-- --------------------------------------------------------------------
-- VISTA 5: ANÁLISIS DE ASIMETRÍA (RO)
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_analisis_asimetria AS
SELECT
    fecha,
    ROUND(ratio_optimizacion, 2) AS ro,
    ROUND(km_google, 2) AS km_google,
    ROUND(km_didi, 2) AS km_didi,
    ROUND(km_didi - km_google, 2) AS diferencia_km,
    pedidos_fisicos,
    CASE
        WHEN ratio_optimizacion >= 2.0 THEN 'Asimetría Extrema'
        WHEN ratio_optimizacion >= 1.7 THEN 'Asimetría Alta'
        WHEN ratio_optimizacion >= 1.5 THEN 'Asimetría Moderada'
        ELSE 'Asimetría Baja'
    END AS clasificacion_asimetria
FROM didi_operaciones
ORDER BY ratio_optimizacion DESC;

-- --------------------------------------------------------------------
-- VISTA 6: EFICIENCIA POR PEDIDO
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_eficiencia_por_pedido AS
SELECT
    fecha,
    ROUND(km_por_pedido_didi, 2) AS km_pedido_didi,
    ROUND(km_por_pedido_google, 2) AS km_pedido_google,
    ROUND(ratio_optimizacion, 2) AS ro,
    pedidos_fisicos,
    ROUND(ingreso_por_km_didi, 2) AS ingreso_km_didi_cop,
    ROUND(ingreso_por_km_google, 2) AS ingreso_km_google_cop
FROM didi_operaciones
ORDER BY km_por_pedido_didi DESC;

-- --------------------------------------------------------------------
-- VISTA 7: RENTABILIDAD POR HORA
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_rentabilidad_por_hora AS
SELECT
    fecha,
    ROUND(ingreso_por_hora, 2) AS ingreso_hora_cop,
    ROUND(utilidad_por_hora, 2) AS utilidad_hora_cop,
    duracion_horas,
    pedidos_fisicos,
    CASE
        WHEN ingreso_por_hora >= 25000 THEN 'Excepcional'
        WHEN ingreso_por_hora >= 20000 THEN 'Alta'
        WHEN ingreso_por_hora >= 15000 THEN 'Moderada'
        ELSE 'Baja'
    END AS eficiencia_horaria
FROM didi_operaciones
ORDER BY ingreso_por_hora DESC;

-- --------------------------------------------------------------------
-- VISTA 8: DÍAS CON GASTO $0 (Anomalías)
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_anomalias_gasto_cero AS
SELECT
    fecha,
    garantizado_meta AS ingresos_cop,
    utilidad_neta AS utilidad_cop,
    pedidos_fisicos,
    duracion_horas,
    'Gasto no registrado' AS tipo_anomalia,
    CASE
        WHEN DAYOFWEEK(fecha) IN (1, 7) THEN 'Fin de semana'
        WHEN fecha IN ('2025-12-24', '2025-12-25', '2025-12-31', '2026-01-01') THEN 'Día festivo'
        ELSE 'Día laborable'
    END AS contexto
FROM didi_operaciones
WHERE gastos_operativos = 0
ORDER BY fecha;

-- --------------------------------------------------------------------
-- VISTA 9: TURNOS CON CRUCE DE MEDIANOCHE
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_cruces_medianoche AS
SELECT
    fecha,
    h_inicio,
    h_fin,
    duracion_horas,
    pedidos_fisicos,
    ROUND(ratio_optimizacion, 2) AS ro,
    utilidad_neta AS utilidad_cop,
    'Cruce de medianoche' AS nota
FROM didi_operaciones
WHERE HOUR(h_fin) < HOUR(h_inicio)
ORDER BY fecha;

-- --------------------------------------------------------------------
-- VISTA 10: DISTRIBUCIÓN DE FUENTES DE INGRESO
-- --------------------------------------------------------------------
CREATE OR REPLACE VIEW v_distribucion_ingresos AS
SELECT
    fecha,
    ingreso_base AS ingreso_base_cop,
    complemento_bono AS bono_cop,
    garantizado_meta AS total_cop,
    ROUND(proporcion_bono * 100, 2) AS proporcion_bono_pct,
    CASE
        WHEN proporcion_bono < 0.40 THEN 'Bono Bajo (<40%)'
        WHEN proporcion_bono BETWEEN 0.40 AND 0.49 THEN 'Bono Moderado (40-49%)'
        WHEN proporcion_bono BETWEEN 0.50 AND 0.59 THEN 'Bono Alto (50-59%)'
        ELSE 'Bono Muy Alto (≥60%)'
    END AS categoria_bono
FROM didi_operaciones
ORDER BY proporcion_bono DESC;

-- ====================================================================
-- SECCIÓN 5: CONSULTAS DE VALIDACIÓN
-- ====================================================================

-- Validar carga de datos
-- SELECT COUNT(*) AS total_registros FROM didi_operaciones;

-- Ver resumen global
-- SELECT * FROM v_resumen_global;

-- Ver promedios
-- SELECT * FROM v_promedios;

-- Ver mejores días
-- SELECT * FROM v_top_10_mejores_dias;

-- Ver peores días
-- SELECT * FROM v_top_10_peores_dias;

-- ====================================================================
-- SECCIÓN 6: CONSULTAS AVANZADAS (EJEMPLOS)
-- ====================================================================

-- --------------------------------------------------------------------
-- Consulta 1: Rendimiento por Franja Horaria
-- --------------------------------------------------------------------
-- Clasifica turnos en Mañana, Tarde, Noche
/*
SELECT
    CASE
        WHEN HOUR(h_inicio) BETWEEN 6 AND 11 THEN 'Mañana'
        WHEN HOUR(h_inicio) BETWEEN 12 AND 17 THEN 'Tarde'
        ELSE 'Noche'
    END AS franja_horaria,
    COUNT(*) AS n_turnos,
    ROUND(AVG(utilidad_neta), 2) AS utilidad_promedio_cop,
    ROUND(AVG(pedidos_fisicos), 2) AS pedidos_promedio,
    ROUND(AVG(ingreso_por_hora), 2) AS ingreso_hora_promedio_cop
FROM didi_operaciones
GROUP BY franja_horaria
ORDER BY utilidad_promedio_cop DESC;
*/

-- --------------------------------------------------------------------
-- Consulta 2: Días con Mayor ROI (Excluye gasto $0)
-- --------------------------------------------------------------------
/*
SELECT
    fecha,
    ROUND(roi_diario, 2) AS roi_pct,
    utilidad_neta AS utilidad_cop,
    gastos_operativos AS gastos_cop,
    pedidos_fisicos
FROM didi_operaciones
WHERE gastos_operativos > 0
ORDER BY roi_diario DESC
LIMIT 10;
*/

-- --------------------------------------------------------------------
-- Consulta 3: Correlación RO vs Utilidad
-- --------------------------------------------------------------------
/*
SELECT
    ROUND(ratio_optimizacion, 2) AS ro,
    utilidad_neta AS utilidad_cop,
    pedidos_fisicos,
    duracion_horas
FROM didi_operaciones
ORDER BY ratio_optimizacion DESC;
*/

-- --------------------------------------------------------------------
-- Consulta 4: Días de Fin de Semana vs Días Laborables
-- --------------------------------------------------------------------
/*
SELECT
    CASE
        WHEN DAYOFWEEK(fecha) IN (1, 7) THEN 'Fin de semana'
        ELSE 'Día laborable'
    END AS tipo_dia,
    COUNT(*) AS n_dias,
    ROUND(AVG(utilidad_neta), 2) AS utilidad_promedio_cop,
    ROUND(AVG(pedidos_fisicos), 2) AS pedidos_promedio
FROM didi_operaciones
GROUP BY tipo_dia;
*/

-- ====================================================================
-- SECCIÓN 7: NOTAS TÉCNICAS
-- ====================================================================

-- IMPORTANTE:
-- 1. Los datos deben cargarse desde el CSV procesado (didi_procesado.csv)
-- 2. Las métricas auditadas son:
--    - Total Gastos: $431,000 COP (ajustado)
--    - ROI Global: 930.28%
--    - RO Global: 1.66x
--    - Múltiplo de Ingreso: 10.30x
-- 3. La moneda es COP (Pesos Colombianos), NO USD
-- 4. Todas las vistas respetan el principio de Transparencia Radical

-- ====================================================================
-- FIN DEL SCRIPT
-- ====================================================================

-- Para ejecutar este script:
-- mysql -u root -p < ANALISIS_SQL_FINAL.sql

-- Para verificar que todo funcionó:
-- USE didi_analytics;
-- SHOW TABLES;
-- SELECT * FROM v_resumen_global;
