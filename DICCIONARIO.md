# 📖 Diccionario de Variables - Sistema de Análisis DiDi Food

**Versión:** 2.0 (Actualizado)  
**Fecha:** 2026-01-30  
**Dataset:** sgt_didi_delivery_efficiency_2026.csv (24 días)

---

## 🎯 Variables Primarias (Del CSV Original)

| **Variable**          | **Tipo**       | **Definición**                                                                 |
|-----------------------|----------------|--------------------------------------------------------------------------------|
| `fecha`               | DATE           | Fecha de operación (YYYY-MM-DD)                                                |
| `ingreso_base`        | DECIMAL(10,2)  | Ingreso base calculado por DiDi antes de aplicar bonos o complementos (COP)    |
| `complemento_bono`    | DECIMAL(10,2)  | Bonificaciones y complementos adicionales pagados por DiDi (COP)               |
| `garantizado_meta`    | DECIMAL(10,2)  | **Ingreso total garantizado** = ingreso_base + complemento_bono (COP)          |
| `pedidos_fisicos`     | INT            | **Total de pedidos entregados** físicamente en el día (conteo real)            |
| `unidades_progreso`   | INT            | **Cantidad de pedidos cohete** del día (pedidos largos ≥7km que cuentan doble)|
| `gastos_operativos`   | DECIMAL(10,2)  | Costos totales del día (gasolina + comida + otros) (COP)                      |

---

## 🚀 Aclaración Crítica: ¿Qué son los "Pedidos Cohete"?

**Definición operativa:**
- Un "pedido cohete" es una entrega con distancia ≥ 7km (ONE-WAY)
- En el sistema de DiDi, estos pedidos **cuentan doble** para alcanzar metas semanales
- `unidades_progreso` = conteo directo de cuántos cohetes se hicieron ese día

**Ejemplo:**
```
Día 2025-12-06:
  pedidos_fisicos = 15    (entregas reales)
  unidades_progreso = 15  (todos fueron cohetes)
  → 15 pedidos cohete de 15 totales = 100% eficiencia
  → Para DiDi, este día cuenta como 30 unidades de progreso (15 × 2)
```

---

## 📊 Variables Calculadas (Derivadas)

| **Variable**            | **Tipo**       | **Fórmula**                                      | **Interpretación**                                    |
|-------------------------|----------------|--------------------------------------------------|-------------------------------------------------------|
| `pedidos_normales`      | INT            | `pedidos_fisicos - pedidos_cohete`               | Pedidos "cortos" (<7km) que cuentan simple            |
| `utilidad_real`         | DECIMAL(10,2)  | `garantizado_meta - gastos_operativos`           | **Ganancia neta del día** (lo que realmente queda)    |
| `eficiencia_cohete`     | DECIMAL(5,2)   | `(pedidos_cohete / pedidos_fisicos) × 100`       | **% de pedidos largos** (meta: >80%)                  |
| `ingreso_por_pedido`    | DECIMAL(8,2)   | `garantizado_meta / pedidos_fisicos`             | Ingreso promedio por entrega                          |
| `costo_por_pedido`      | DECIMAL(8,2)   | `gastos_operativos / pedidos_fisicos`            | Costo promedio por entrega                            |
| `utilidad_por_pedido`   | DECIMAL(8,2)   | `utilidad_real / pedidos_fisicos`                | Ganancia neta por entrega                             |

---

## 📈 Variables de Clasificación

### **nivel_eficiencia** (ENUM)
Clasifica los días según el porcentaje de cohetes:

| **Nivel**     | **Criterio**              | **Interpretación**                                |
|---------------|---------------------------|---------------------------------------------------|
| `Excelente`   | eficiencia ≥ 90%          | Casi todos los pedidos fueron cohetes             |
| `Alto`        | 70% ≤ eficiencia < 90%    | Mayoría de pedidos fueron cohetes                 |
| `Medio`       | 50% ≤ eficiencia < 70%    | Balance entre cohetes y normales                  |
| `Bajo`        | eficiencia < 50%          | Mayoría de pedidos fueron cortos                  |

### **nivel_utilidad** (ENUM)
Clasifica los días según la ganancia neta:

| **Nivel**  | **Criterio**              | **Interpretación**                                |
|------------|---------------------------|---------------------------------------------------|
| `Alto`     | utilidad ≥ $200,000       | Día muy rentable                                  |
| `Medio`    | $100,000 ≤ utilidad < $200,000 | Día rentable estándar                       |
| `Bajo`     | utilidad < $100,000       | Día poco rentable (revisar causas)                |

---

## 📊 Métricas Estadísticas Globales

**Tabla:** `metricas_globales`

| **Métrica**                  | **Descripción**                                                       |
|------------------------------|-----------------------------------------------------------------------|
| `total_dias`                 | Días operados en el periodo (N=24)                                    |
| `total_pedidos`              | Suma de todos los pedidos físicos                                     |
| `total_cohetes`              | Suma de todos los pedidos cohete                                      |
| `eficiencia_cohete_promedio` | Media de eficiencia cohete del periodo                                |
| `utilidad_promedio_dia`      | Ganancia neta promedio por día                                        |
| `utilidad_desviacion`        | Desviación estándar de utilidad (mide volatilidad)                    |
| `roi_porcentaje`             | Retorno sobre inversión: `(utilidad_total / gastos_totales) × 100`   |

---

## 🧮 Resultados del Análisis (24 días)

### **Estadísticas Globales**

```
Total de días operados:          24 días
Periodo:                         2025-12-05 a 2026-01-25
Total pedidos físicos:           339 pedidos
Total pedidos cohete:            284 pedidos
Eficiencia cohete promedio:      83.4%
Utilidad total periodo:          $3,785,000 COP
Utilidad promedio/día:           $157,708 COP
Mejor día (utilidad):            $288,000 (2025-12-25)
Peor día (utilidad):             $29,500 (2026-01-24)
```

### **Composición de Ingresos**

```
Ingreso Base:       $2,128,334 (51.3%)
Complementos:       $2,018,166 (48.7%)
Total Ingresos:     $4,146,500
```

### **Distribución por Nivel de Eficiencia**

| **Nivel**    | **Días** | **Eficiencia Promedio** | **Utilidad Promedio** |
|--------------|----------|-------------------------|-----------------------|
| Excelente    | 13 días  | 96.8%                   | $166,885              |
| Alto         | 8 días   | 77.5%                   | $159,250              |
| Medio        | 2 días   | 56.5%                   | $127,250              |
| Bajo         | 1 día    | 50.0%                   | $29,500               |

---

## 🔗 Relaciones Entre Variables (Hipótesis de Tesis)

### **Hipótesis 1: Alta Eficiencia de Cohetes → Mayor Utilidad**
```sql
-- Correlación positiva moderada
-- Días con ≥90% cohetes → Utilidad promedio: $166,885
-- Días con <70% cohetes → Utilidad promedio: $98,375
```

### **Hipótesis 2: Complementos Representan ~50% del Ingreso**
```sql
-- Bonos y complementos son críticos para la viabilidad
-- Sin complementos, ingreso base solo = $2.1M (vs $4.1M total)
```

### **Hipótesis 3: Volatilidad de Utilidad es Alta**
```sql
-- Desviación estándar: $74,650
-- Coeficiente de variación: ~47% (operación moderadamente variable)
```

---

## 📏 Rangos Operativos Observados

| **Variable**            | **Mínimo** | **Promedio** | **Máximo** | **Interpretación**              |
|-------------------------|------------|--------------|------------|---------------------------------|
| `garantizado_meta`      | $31,000    | $172,771     | $302,000   | Alta variabilidad de ingresos   |
| `pedidos_fisicos`       | 3          | 14.1         | 21         | Volumen moderado                |
| `pedidos_cohete`        | 3          | 11.8         | 18         | Alta proporción de cohetes      |
| `eficiencia_cohete`     | 50.0%      | 83.4%        | 100.0%     | Estrategia cohete muy efectiva  |
| `gastos_operativos`     | $0         | $15,062      | $58,000    | Costos variables (¿vehículo?)   |
| `utilidad_real`         | $29,500    | $157,708     | $288,000   | Alta dispersión de rentabilidad |

---

## 🛠️ Consideraciones Técnicas

### **Precisión de Datos**
- Moneda: Pesos colombianos (COP), sin decimales en la fuente original
- Fechas: Solo fecha del día (sin hora específica del turno)
- Porcentajes: Almacenados como decimales (83.4 = 83.4%)

### **Valores Especiales**
- `gastos_operativos = 0`: Días donde no hubo costos (¿vehículo propio sin combustible?)
- `eficiencia_cohete = 100%`: Todos los pedidos fueron cohetes (13 días)
- `pedidos_fisicos = 3`: Día atípico (2026-01-08) con muy bajo volumen

### **Limitaciones del Dataset**
- No hay variable de **vehículo** (cicla vs carro) → Imposible segmentar por tipo
- No hay **hora de inicio/fin** de turno → No se puede medir duración
- No hay **zona geográfica** → No se puede analizar por sector de la ciudad
- `gastos_operativos` es **agregado** → No se puede separar gasolina vs comida

---

## 📚 Uso en la Tesis

### **Tablas Recomendadas**
1. **Tabla 1:** Estadísticas Descriptivas (metricas_globales)
2. **Tabla 2:** Distribución por Nivel de Eficiencia (v_analisis_por_nivel)
3. **Tabla 3:** Top 10 Mejores Días (v_mejores_dias_eficiencia)
4. **Tabla 4:** Composición de Ingresos (ingreso_base vs complemento)

### **Gráficos Recomendados**
1. **Línea:** Utilidad por día (tendencia temporal)
2. **Barras:** Utilidad promedio por nivel de eficiencia
3. **Dispersión:** Eficiencia cohete (X) vs Utilidad (Y) → Correlación
4. **Pastel:** Composición de ingresos (base vs complementos)
5. **Histograma:** Distribución de eficiencia cohete

### **Análisis Estadísticos**
- Correlación de Pearson entre `eficiencia_cohete` y `utilidad_real`
- ANOVA para comparar utilidad entre niveles de eficiencia
- Regresión lineal: Utilidad ~ Eficiencia + Pedidos + Gastos

---

## 🔄 Historial de Versiones

| Versión | Fecha      | Cambios                                                   |
|---------|------------|-----------------------------------------------------------|
| 1.0     | 2026-01-30 | Versión inicial con estructura hipotética                 |
| 2.0     | 2026-01-30 | **ACTUALIZADO:** Datos reales, unidades_progreso=cohetes  |

---

**Autor:** [Tu Nombre]  
**Contacto:** [Tu Email]  
**Proyecto:** Análisis de Eficiencia Operativa DiDi Food - Tesis de Grado  
**Dataset:** N=24 días (2025-12-05 a 2026-01-25)
