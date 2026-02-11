# SQL Analysis Layer

## Descripción

Esta carpeta contiene el script SQL utilizado para:

- Crear la base de datos
- Definir la tabla base de registros
- Insertar los datos operativos
- Calcular métricas derivadas
- Generar vistas analíticas

El análisis está diseñado para ejecutarse en MySQL 8.0.

---

## Archivo Principal

- `analisis_operativo_didi.sql`

---

## Estructura del Script

El script incluye:

1. Creación de base de datos
2. Creación de tabla base (`registros_didi`)
3. Inserción de datos (25 días operativos)
4. Cálculo de métricas derivadas:
   - ratio_optimizacion
   - utilidad_neta
   - salario_efectivo_hora
   - eficiencia_cohete_pct
5. Creación de vistas analíticas:
   - v_resumen_ejecutivo
   - v_top_10_dias
   - v_analisis_por_ro
   - v_cohetes_vs_utilidad

---

## Cómo Ejecutarlo

1. Abrir MySQL Workbench o cliente compatible.
2. Ejecutar el script completo.
3. Consultar las vistas creadas para obtener los resultados analíticos.

---

## Notas

- No depende de carga externa de CSV.
- Todas las métricas derivadas se calculan dinámicamente.
- Maneja divisiones seguras con `NULLIF` para evitar errores.

