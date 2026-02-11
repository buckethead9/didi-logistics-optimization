# 📖 Diccionario de Variables

## Análisis McKinsey: Arbitraje Algorítmico en Logística Última Milla

**Versión:** 1.0  
**Fecha:** Enero 2026  
**Dataset:** 25 días operativos (2025-12-05 a 2026-01-30)

---

## 🎯 Variables Primarias (Recolectadas)

### 1. `fecha`
**Tipo:** Cualitativa nominal  
**Formato:** DATE (YYYY-MM-DD)  
**Ejemplo:** 2025-12-05  
**Definición:** Fecha del día operativo  
**Fuente:** Calendario  
**Rango:** 2025-12-05 a 2026-01-30  
**Valores únicos:** 25

---

### 2. `h_inicio`
**Tipo:** Cuantitativa continua  
**Formato:** TIME (HH:MM)  
**Ejemplo:** 17:05  
**Definición:** Hora exacta en que se acepta el **primer pedido** del día  
**Fuente:** App DiDi (timestamp al aceptar pedido)  
**Rango observado:** 11:36 - 18:47  
**Notas:** 
- No es la hora de salida de casa
- Es el momento exacto del primer "Aceptar"
- Formato 24 horas

---

### 3. `h_fin`
**Tipo:** Cuantitativa continua  
**Formato:** TIME (HH:MM)  
**Ejemplo:** 23:23  
**Definición:** Hora exacta en que se entrega el **último pedido** y se pone el candado a la bicicleta en casa  
**Fuente:** App DiDi + registro manual  
**Rango observado:** 18:15 - 23:56  
**Notas:**
- Marca el fin del turno completo
- Incluye el desplazamiento de regreso a casa

---

### 4. `km_google_maps`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(10,2)  
**Unidad:** Kilómetros (km)  
**Ejemplo:** 45.06  
**Definición:** Distancia **real pedaleada** según GPS  
**Fuente:** Google Maps Timeline o Strava  
**Rango observado:** 11.16 - 104.61 km  
**Promedio:** 61.05 km/día  
**Notas:**
- Incluye retornos y desplazamientos entre pedidos
- Medición GPS con precisión ±5% en zona urbana
- Es la **distancia física real** recorrida
- **Variable clave para calcular RO**

---

### 5. `km_didi_app`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(10,2)  
**Unidad:** Kilómetros (km)  
**Ejemplo:** 88.60  
**Definición:** Suma de las distancias **reportadas por DiDi** en cada pedido  
**Fuente:** App DiDi (captura de pantalla de cada pedido)  
**Rango observado:** 17.70 - 146.80 km  
**Promedio:** 100.53 km/día  
**Notas:**
- Basada en cálculo algorítmico de rutas vehiculares
- **NO refleja la distancia real pedaleada**
- Es la distancia que DiDi usa para calcular el pago
- **Variable clave para calcular RO**

---

### 6. `ingreso_bruto`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(10,2)  
**Unidad:** Pesos colombianos (COP)  
**Ejemplo:** 130000  
**Definición:** Ganancia total garantizada del día (ingreso base + complementos + bonos)  
**Fuente:** App DiDi (resumen diario)  
**Rango observado:** $31,000 - $302,000  
**Promedio:** $171,161/día  
**Componentes:**
- Ingreso base (tarifa por km/pedido)
- Complementos (bonos por eficiencia)
- Propinas (si aplican)
**Notas:**
- Es el monto **antes** de descontar gastos
- Incluye todos los incentivos del día

---

### 7. `pedidos_cohete`
**Tipo:** Cuantitativa discreta  
**Formato:** INT  
**Unidad:** Número de pedidos  
**Ejemplo:** 11  
**Definición:** Cantidad de pedidos con distancia **≥ 7 km** (cuentan doble para meta semanal)  
**Fuente:** Contador manual durante el día  
**Rango observado:** 0 - 18 pedidos  
**Promedio:** 10.8 cohetes/día  
**Criterio:** Pedido se clasifica como "cohete" si DiDi muestra distancia ≥7.0 km  
**Notas:**
- Estos pedidos cuentan **x2** para metas semanales de DiDi
- Generalmente pagan más por km
- Requieren más esfuerzo físico

---

### 8. `pedidos_normales`
**Tipo:** Cuantitativa discreta  
**Formato:** INT  
**Unidad:** Número de pedidos  
**Ejemplo:** 1  
**Definición:** Cantidad de pedidos con distancia **< 7 km**  
**Fuente:** Calculado (pedidos_fisicos - pedidos_cohete)  
**Rango observado:** 0 - 9 pedidos  
**Promedio:** 3.3 normales/día  
**Notas:**
- Representan volumen complementario
- Menor pago por km que cohetes
- Menor esfuerzo físico

---

### 9. `gasto_extra`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(10,2)  
**Unidad:** Pesos colombianos (COP)  
**Ejemplo:** 17000  
**Definición:** Gastos operativos del día (comida, bebidas, reparaciones)  
**Fuente:** Recibos físicos sumados  
**Rango observado:** $0 - $58,000  
**Promedio:** $15,300/día  
**Componentes:**
- Alimentación extra (Gatorade, snacks, almuerzo en ruta)
- Reparaciones de emergencia (pinchazo, parches)
- Otros gastos operativos
**Notas:**
- **NO incluye** comida que se consumiría en casa de todos modos
- Solo gastos **adicionales** por la operación
- Algunos días = $0 (turno sin gastos)

---

## 📊 Variables Derivadas (Calculadas por SQL)

### 10. `tiempo_total_horas`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(5,2)  
**Unidad:** Horas  
**Fórmula:** `TIMESTAMPDIFF(MINUTE, h_inicio, h_fin) / 60`  
**Ejemplo:** 6.30 horas  
**Definición:** Duración total del turno desde primer pedido hasta llegar a casa  
**Rango observado:** 3.61 - 11.72 horas  
**Promedio:** 9.12 horas/día  
**Notas:**
- Incluye tiempo de espera entre pedidos
- Incluye desplazamientos vacíos
- Incluye retorno a casa

---

### 11. `pedidos_totales`
**Tipo:** Cuantitativa discreta  
**Formato:** INT  
**Fórmula:** `pedidos_cohete + pedidos_normales`  
**Ejemplo:** 12  
**Definición:** Total de pedidos entregados en el día  
**Rango observado:** 3 - 21 pedidos  
**Promedio:** 14.1 pedidos/día  

---

### 12. `ratio_optimizacion` (RO) ⭐
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(5,2)  
**Fórmula:** `km_didi_app / km_google_maps`  
**Ejemplo:** 1.97  
**Definición:** **Factor de multiplicación algorítmica** - Cuántos km paga DiDi por cada km real pedaleado  
**Rango observado:** 1.29 - 1.99x  
**Promedio:** **1.65x**  
**Interpretación:**
- **RO > 2.0:** 🚀 Excelente (hackeo máximo del algoritmo)
- **RO 1.5-2.0:** 🟢 Bueno (ventaja competitiva)
- **RO 1.0-1.5:** 🟡 Neutro (casi como un carro)
- **RO < 1.0:** 🔴 Malo (trabajas para la app)
**Notas:**
- **Métrica central del análisis McKinsey**
- Cuantifica el arbitraje algorítmico
- Mayor RO = Mayor aprovechamiento de atajos

---

### 13. `utilidad_neta`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(10,2)  
**Unidad:** COP  
**Fórmula:** `ingreso_bruto - gasto_extra - (km_google_maps × 124)`  
**Ejemplo:** $107,456  
**Definición:** Ganancia real después de descontar gastos operativos y desgaste de bicicleta  
**Rango observado:** $25,133 - $282,256  
**Promedio:** $148,291/día  
**Componentes:**
- Ingreso bruto
- **-** Gastos operativos
- **-** Desgaste bici ($124/km)
**Notas:**
- Desgaste incluye: llantas, cadena, frenos, depreciación
- $124/km basado en costo de consumibles y vida útil

---

### 14. `ingreso_por_km_real`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(8,2)  
**Unidad:** COP/km  
**Fórmula:** `(ingreso_bruto - gasto_extra) / km_google_maps`  
**Ejemplo:** $2,355/km  
**Definición:** Ingreso neto por cada kilómetro realmente pedaleado  
**Rango observado:** $1,845 - $4,038 COP/km  
**Promedio:** $2,554/km  
**Interpretación:**
- Mayor valor = Mayor rentabilidad por esfuerzo
- Afectado por RO y eficiencia de cohetes

---

### 15. `velocidad_enganche`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(5,1)  
**Unidad:** Minutos/pedido  
**Fórmula:** `tiempo_total_horas × 60 / pedidos_totales`  
**Ejemplo:** 31.5 min/pedido  
**Definición:** Tiempo promedio que toma completar un pedido (incluyendo esperas)  
**Rango observado:** 19.9 - 73.7 min/pedido  
**Promedio:** 38.9 min/pedido  
**Interpretación:**
- <30 min/pedido: Alta productividad
- 30-40 min/pedido: Rango normal
- >40 min/pedido: Mucha espera entre pedidos
**Notas:**
- Incluye tiempo de espera de nuevos pedidos
- Incluye desplazamiento + entrega + retorno

---

### 16. `velocidad_operativa`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(5,2)  
**Unidad:** km/h  
**Fórmula:** `km_google_maps / tiempo_total_horas`  
**Ejemplo:** 7.15 km/h  
**Definición:** Velocidad promedio real considerando todo el tiempo del turno  
**Rango observado:** 4.56 - 10.39 km/h  
**Promedio:** 6.69 km/h  
**Notas:**
- Incluye paradas, esperas, entregas
- **NO** es velocidad de pedaleo puro
- Diferente de velocidad en movimiento (mayor)

---

### 17. `salario_efectivo_hora`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(8,2)  
**Unidad:** COP/hora  
**Fórmula:** `utilidad_neta / tiempo_total_horas`  
**Ejemplo:** $17,056/h  
**Definición:** Ganancia neta por hora de trabajo  
**Rango observado:** $9,657 - $52,340 COP/h  
**Promedio:** $16,256/h  
**Referencia:** Salario mínimo 2026 = $6,667/h  
**Promedio vs mínimo:** 2.44x (144% superior)  
**Interpretación:**
- <$10,000/h: Día poco rentable
- $10-20,000/h: Rentabilidad normal
- $20-30,000/h: Buen día
- >$30,000/h: Excelente día
**Notas:**
- **Métrica clave** para evaluar rentabilidad
- Comparable con otros trabajos

---

### 18. `eficiencia_cohete_pct`
**Tipo:** Cuantitativa continua  
**Formato:** DECIMAL(5,2)  
**Unidad:** Porcentaje (%)  
**Fórmula:** `(pedidos_cohete / pedidos_totales) × 100`  
**Ejemplo:** 91.67%  
**Definición:** Porcentaje de pedidos cohete sobre el total  
**Rango observado:** 0.0% - 100.0%  
**Promedio:** 76.6%  
**Interpretación:**
- ≥80%: Muy alta eficiencia
- 60-79%: Alta eficiencia
- 40-59%: Eficiencia media
- <40%: Baja eficiencia
**Correlación con utilidad:** r = +0.51 (moderada positiva)

---

## 📈 Variables de Clasificación

### 19. `nivel_ro`
**Tipo:** Cualitativa ordinal  
**Valores:** 
- 🚀 Excelente (RO ≥ 2.0)
- 🟢 Bueno (1.5 ≤ RO < 2.0)
- 🟡 Neutro (1.0 ≤ RO < 1.5)
- 🔴 Malo (RO < 1.0)
**Definición:** Clasificación del día según Ratio de Optimización  
**Distribución observada:**
- Excelente: 7 días (28%)
- Bueno: 11 días (44%)
- Neutro: 7 días (28%)
- Malo: 0 días (0%)

---

### 20. `nivel_cohetes`
**Tipo:** Cualitativa ordinal  
**Valores:**
- ≥80% cohetes
- 60-79% cohetes
- 40-59% cohetes
- <40% cohetes
**Definición:** Clasificación del día según proporción de pedidos cohete  
**Distribución observada:**
- ≥80%: 15 días (60%)
- 60-79%: 6 días (24%)
- 40-59%: 2 días (8%)
- <40%: 2 días (8%)

---

## 🔢 Variables Agregadas (Por Periodo)

### 21. Variables de resumen mensual
- `dias_trabajados`: Días operativos en el mes
- `km_reales_mes`: Total km pedaleados en el mes
- `km_didi_mes`: Total km reportados en el mes
- `ro_mensual`: RO promedio del mes
- `utilidad_mensual`: Utilidad neta total del mes

### 22. Variables de resumen semanal
- `semana`: Número de semana del año
- `dias_semana`: Días trabajados en la semana
- `ro_semanal`: RO promedio semanal
- `utilidad_semanal`: Utilidad total de la semana

---

## 📊 Constantes del Modelo

### Parámetros Fijos

| Constante | Valor | Justificación |
|-----------|-------|---------------|
| **Desgaste bici** | $124/km | Costo promedio de llantas, cadena, frenos, depreciación |
| **Salario mínimo 2026** | $6,667/h | Salario mínimo legal Colombia 2026 |
| **Criterio cohete** | ≥7 km | Definición de DiDi para pedidos largos |
| **Factor cohete meta** | 2x | Pedidos cohete cuentan doble para meta semanal |

---

## 🔗 Relaciones Entre Variables

### Correlaciones Principales (Pearson)

| Variable A | Variable B | r | Interpretación |
|------------|------------|---|----------------|
| `ratio_optimizacion` | `salario_efectivo_hora` | +0.41 | Moderada positiva |
| `eficiencia_cohete_pct` | `utilidad_neta` | +0.51 | Moderada positiva |
| `utilidad_neta` | `salario_efectivo_hora` | +0.89 | Fuerte positiva |
| `km_google_maps` | `ratio_optimizacion` | -0.12 | Débil negativa |

---

## 📏 Rangos Esperados y Outliers

### Criterios de Validación

| Variable | Mín Esperado | Máx Esperado | Outlier si |
|----------|--------------|--------------|------------|
| `km_google_maps` | 10 km | 120 km | <5 o >150 |
| `km_didi_app` | 15 km | 200 km | <10 o >250 |
| `ratio_optimizacion` | 0.8x | 3.0x | <0.5 o >3.5 |
| `pedidos_totales` | 3 | 25 | <2 o >30 |
| `gasto_extra` | $0 | $40,000 | >$60,000 |
| `salario_efectivo_hora` | $5,000 | $60,000 | <$3,000 o >$80,000 |

---

## 🎯 Variables Clave para Hipótesis de Tesis

### Hipótesis 1: Arbitraje Algorítmico
**Variables:** `ratio_optimizacion`, `km_google_maps`, `km_didi_app`  
**Resultado:** RO promedio = 1.65x (comprobado)

### Hipótesis 2: Estrategia Cohetes Rentable
**Variables:** `eficiencia_cohete_pct`, `utilidad_neta`  
**Resultado:** +39% utilidad con ≥80% cohetes (comprobado)

### Hipótesis 3: Rentabilidad Superior
**Variables:** `salario_efectivo_hora`, salario_mínimo  
**Resultado:** 2.44x salario mínimo (comprobado)

---

## 📝 Notas Metodológicas

### Precisión de Mediciones
- **GPS (km_google_maps):** ±5% en zona urbana
- **Tiempo:** ±1 minuto
- **Dinero:** Exacto (de app DiDi)
- **Pedidos:** Exacto (contador manual)

### Datos Faltantes
- **0 valores faltantes** en variables primarias
- Todos los 25 días tienen datos completos

### Transformaciones Aplicadas
- Conversión de formato de KM (coma → punto decimal)
- Cálculo de pedidos_normales (diferencia)
- Todas las métricas derivadas calculadas automáticamente en SQL

---

**Versión del Diccionario:** 1.0  
**Última actualización:** Enero 2026  
**Total de variables documentadas:** 22 (9 primarias + 13 derivadas)
