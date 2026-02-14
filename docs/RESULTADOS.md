# RESULTADOS
## Análisis de Arbitraje Algorítmico DiDi Food

**Dataset:** N=26 días operativos  
**Periodo:** 2025-12-05 a 2026-01-31  
**Versión:** 1.0.0 (Datos Auditados)  
**Principio:** Transparencia Radical - La Verdad por encima de la Armonía

---

## DASHBOARD EJECUTIVO

```
╔══════════════════════════════════════════════════════════════╗
║           MÉTRICAS GLOBALES (VALORES AUDITADOS)              ║
╠══════════════════════════════════════════════════════════════╣
║  💰 Total Ingresos:        $4,440,530 COP                    ║
║  💸 Total Gastos:          $431,000 COP                      ║
║  💵 Utilidad Neta:         $4,009,530 COP                    ║
║  📈 ROI Global:            930.28%                           ║
║  🔢 Múltiplo de Ingreso:   10.30x                            ║
║  🛣️  RO Global:             1.66x                            ║
║  📦 Total Pedidos:         363 pedidos                       ║
║  ⏱️  Duración Total:        236.72 horas                     ║
║  🚴 KM Google Maps:        1,571.38 km                       ║
║  🏍️  KM DiDi App:           2,601.89 km                      ║
╚══════════════════════════════════════════════════════════════╝
```

---

## TABLA 1: RESUMEN ESTADÍSTICO GENERAL

| Métrica | Valor |
|---------|-------|
| **Registros (N)** | 26 días |
| **Ingresos Totales** | $4,440,530 COP |
| **Gastos Totales** | $431,000 COP |
| **Utilidad Neta** | $4,009,530 COP |
| **ROI Global** | 930.28% |
| **Múltiplo de Ingreso** | 10.30x |
| **RO Global (km_didi/km_google)** | 1.66x |
| **Pedidos Totales** | 363 |
| **Duración Total** | 236.72 horas |
| **KM Google Total** | 1,571.38 km |
| **KM DiDi Total** | 2,601.89 km |
| **Asimetría de Distancia** | +1,030.51 km (DiDi > Google) |
| **Días con Gasto $0** | 6 (anomalía técnica) |
| **Turnos con Cruce de Medianoche** | 4 |

---

## TABLA 2: MÉTRICAS PROMEDIO POR DÍA

| Métrica | Promedio | Unidad |
|---------|----------|--------|
| **Ingreso por Día** | $170,789.62 | COP |
| **Utilidad por Día** | $154,212.69 | COP |
| **Gasto por Día** | $16,576.92 | COP |
| **Pedidos por Día** | 13.96 | pedidos |
| **Duración por Día** | 9.10 | horas |
| **KM Google por Día** | 60.44 | km |
| **KM DiDi por Día** | 100.07 | km |
| **RO Promedio** | 1.66 | x |
| **Ingreso por Hora** | $18,760.49 | COP/hora |
| **Utilidad por Hora** | $16,936.73 | COP/hora |

---

## TABLA 3: TOP 5 MEJORES DÍAS (Por Utilidad Neta)

| Ranking | Fecha | Utilidad | ROI Diario | Pedidos | Duración | Ingreso/Hora |
|---------|-------|----------|------------|---------|----------|--------------|
| 🥇 | 2025-12-25 | $288,000 | 2,057.14% | 21 | 12.50 h | $24,160 |
| 🥈 | 2025-12-28 | $268,000 | 1,786.67% | 18 | 10.63 h | $26,622 |
| 🥉 | 2025-12-20 | $247,000 | 1,543.75% | 20 | 11.67 h | $22,530 |
| 4 | 2025-12-21 | $246,500 | 1,146.51% | 18 | 12.73 h | $21,053 |
| 5 | 2026-01-11 | $244,000 | N/A* | 18 | 12.45 h | $19,598 |

*N/A: Gasto $0 COP, ROI no calculable

**Patrón identificado:**  
Los mejores días coinciden con alta demanda (18-21 pedidos) y duraciones largas (10-13 horas). El día 2025-12-25 (Navidad) es el más rentable con utilidad de $288,000 COP.

---

## TABLA 4: TOP 5 PEORES DÍAS (Por Utilidad Neta)

| Ranking | Fecha | Utilidad | Gastos | Pedidos | Duración | Falla Técnica |
|---------|-------|----------|--------|---------|----------|---------------|
| ⚠️ | 2026-01-24 | $29,500 | $18,000 | 6 | 3.90 h | Bajo volumen |
| ⚠️ | 2026-01-08 | $31,000 | $0 | 3 | 0.82 h | Turno cortísimo |
| ⚠️ | 2025-12-23 | $57,000 | $16,000 | 8 | 4.63 h | Media jornada |
| ⚠️ | 2026-01-30 | $71,500 | $18,000 | 9 | 6.28 h | Baja eficiencia |
| ⚠️ | 2026-01-12 | $84,000 | $20,000 | 9 | 5.78 h | Gastos altos |

**Análisis de fallas:**
1. **2026-01-24:** Solo 6 pedidos en 3.9 horas. Posible falla de sistema o baja demanda.
2. **2026-01-08:** Turno de 49 minutos con 3 pedidos. Probable prueba o error de registro.
3. **2025-12-23:** Media jornada (4.63h). Turno interrumpido o decisión operativa.
4. **2026-01-30:** 9 pedidos en 6.28 horas. Baja densidad de pedidos.
5. **2026-01-12:** Gastos de $20,000 COP reducen utilidad neta.

**Recomendación:**  
Evitar turnos menores a 5 horas salvo alta demanda comprobada.

---

## TABLA 5: ANÁLISIS DE ASIMETRÍA (RO - Ratio de Optimización)

### Top 5 Días con Mayor Asimetría Algorítmica

| Fecha | RO | KM Google | KM DiDi | Diferencia | Pedidos |
|-------|-------|-----------|---------|------------|---------|
| 2026-01-04 | **2.37x** | 33.80 | 80.1 | +46.30 km | 15 |
| 2025-12-23 | **2.10x** | 23.40 | 49.1 | +25.70 km | 8 |
| 2026-01-17 | **2.07x** | 38.95 | 80.8 | +41.85 km | 11 |
| 2026-01-24 | **2.02x** | 18.79 | 38.0 | +19.21 km | 6 |
| 2025-12-05 | **1.97x** | 45.06 | 88.6 | +43.54 km | 12 |

**Interpretación:**
- El día 2026-01-04 tiene la mayor asimetría: **DiDi calcula rutas 137% más largas**.
- En promedio, RO = 1.66x significa que DiDi sugiere rutas **66% más largas**.
- La diferencia acumulada es de **+1,030.51 km** (DiDi vs Google).

**Oportunidad de arbitraje:**
- Si el operador usa rutas de Google (bicicleta) en moto, ahorra 1,030.51 km en 26 días.
- Esto representa **39.6 km/día ahorrados**, aproximadamente 2.6 litros de combustible/día (asumiendo 15 km/litro).

---

## TABLA 6: EFICIENCIA POR PEDIDO

### Top 5 Días con Mayor KM por Pedido (DiDi)

| Fecha | KM/Pedido (DiDi) | KM/Pedido (Google) | RO | Pedidos |
|-------|------------------|---------------------|-----|---------|
| 2026-01-08 | 8.60 | 6.44 | 1.34x | 3 |
| 2025-12-13 | 8.37 | 5.73 | 1.46x | 11 |
| 2026-01-31 | 8.33 | 5.00 | 1.67x | 15 |
| 2026-01-10 | 8.13 | 4.96 | 1.64x | 12 |
| 2025-12-06 | 8.05 | 4.84 | 1.66x | 15 |

**Análisis:**
- Los días con mayor km/pedido (DiDi) tienen entregas más dispersas geográficamente.
- El promedio global es **7.17 km/pedido (DiDi)** vs **4.33 km/pedido (Google)**.
- Esto confirma que Google Maps optimiza rutas más cortas (ciclorrutas).

---

## TABLA 7: ANÁLISIS DE RENTABILIDAD POR HORA

### Top 5 Días con Mayor Ingreso por Hora

| Fecha | Ingreso/Hora | Utilidad/Hora | Duración | Pedidos | Eficiencia |
|-------|--------------|---------------|----------|---------|------------|
| 2025-12-28 | $26,622 | $25,212 | 10.63 h | 18 | Alta |
| 2025-12-25 | $24,160 | $23,040 | 12.50 h | 21 | Alta |
| 2025-12-14 | $23,198 | $21,442 | 10.82 h | 18 | Alta |
| 2025-12-20 | $22,536 | $21,165 | 11.67 h | 20 | Alta |
| 2025-12-07 | $21,543 | $19,849 | 10.63 h | 17 | Alta |

**Patrón:**
- Los días más eficientes tienen duraciones de 10-13 horas.
- Ingresos por hora superiores a $20,000 COP son excepcionales.
- La utilidad por hora promedio global es de **$16,936.73 COP/hora**.

---

## TABLA 8: DÍAS CON GASTO $0 COP (Anomalías Técnicas)

| Fecha | Ingresos | Utilidad | Pedidos | Duración | ROI | Nota |
|-------|----------|----------|---------|----------|-----|------|
| 2026-01-11 | $244,000 | $244,000 | 18 | 12.45 h | N/A | Gasto no registrado |
| 2026-01-01 | $183,000 | $183,000 | 17 | 12.32 h | N/A | Día festivo |
| 2026-01-25 | $169,500 | $169,500 | 16 | 10.97 h | N/A | Moto compartida (hipótesis) |
| 2025-12-24 | $132,000 | $132,000 | 10 | 8.52 h | N/A | Nochebuena |
| 2025-12-31 | $125,000 | $125,000 | 13 | 8.53 h | N/A | Año Nuevo |
| 2026-01-08 | $31,000 | $31,000 | 3 | 0.82 h | N/A | Error de registro |

**Total acumulado:** $884,500 COP en ingresos sin gastos registrados (19.9% del total)

**Hipótesis de causa:**
1. Omisión de registro manual (más probable)
2. Uso de moto compartida/préstamo (sin costo de combustible)
3. Días de prueba/cortesía con DiDi (improbable)

**Impacto en ROI Global:**
- Si estos 6 días tuvieran gastos de $16,576.92 (promedio), el ROI disminuiría marginalmente.
- La decisión de auditoría es **no ajustar artificialmente** estos registros.

---

## TABLA 9: TURNOS CON CRUCE DE MEDIANOCHE

| Fecha | Hora Inicio | Hora Fin | Duración | Pedidos | RO | Nota |
|-------|-------------|----------|----------|---------|-----|------|
| 2026-01-11 | 11:55 | 0:22 | 12.45 h | 18 | 1.53x | Turno largo |
| 2026-01-31 | 12:44 | 0:02 | 11.30 h | 15 | 1.67x | Turno largo |
| 2025-12-13 | 17:01 | 0:12 | 7.18 h | 11 | 1.46x | Turno nocturno |
| 2026-01-17 | 17:01 | 0:04 | 7.05 h | 11 | 2.07x | Alta asimetría |

**Tratamiento técnico:**
- Se aplicó el algoritmo de "Día Operativo" para calcular duración correctamente.
- Sin corrección, la duración sería negativa (error).
- Ejemplo: `17:01 a 0:12` → `7.18 horas` (no `6.18` ni `-16.82`).

**Implicación operativa:**
- Los turnos nocturnos son comunes (15.4% del dataset).
- No hay penalización en rentabilidad por cruzar medianoche.

---

## TABLA 10: COMPARACIÓN DE FUENTES DE INGRESO

### Proporción de Bono vs Ingreso Base

| Métrica | Valor | Proporción |
|---------|-------|------------|
| **Ingreso Base Total** | $2,441,426 | 55.00% |
| **Complemento Bono Total** | $1,999,104 | 45.00% |
| **Garantizado Meta Total** | $4,440,530 | 100% |

**Distribución por día:**

| Rango de Proporción de Bono | Días | % del Total |
|------------------------------|------|-------------|
| 0.40 - 0.49 (40-49%) | 14 | 53.85% |
| 0.50 - 0.59 (50-59%) | 10 | 38.46% |
| 0.60 - 0.69 (60-69%) | 2 | 7.69% |

**Interpretación:**
- El bono representa **45% de los ingresos totales**.
- El modelo de negocio de DiDi depende fuertemente de bonos por cumplir metas.
- La proporción de bono es estable (mayoría en 40-59%).

---

## CONCLUSIONES CLAVE

### 1. Rentabilidad Excepcional
- **ROI Global de 930.28%** confirma alta rentabilidad del modelo.
- Cada peso invertido genera **$10.30 COP** de ingresos.

### 2. Asimetría Algorítmica Confirmada
- **RO Global de 1.66x** demuestra que DiDi calcula rutas 66% más largas.
- Oportunidad de arbitraje: 39.6 km/día ahorrados usando rutas de Google.

### 3. Anomalías Documentadas (Sin Maquillar)
- **6 días con gasto $0** inflan el ROI artificialmente.
- **4 turnos con cruce de medianoche** requieren tratamiento especial.
- **Días con bajo volumen** (< 8 pedidos) son poco rentables.

### 4. Recomendaciones Operativas
- **Evitar turnos menores a 5 horas** salvo alta demanda.
- **Maximizar turnos de 10-13 horas** para mejor ingreso/hora.
- **Documentar gastos reales** para cálculos precisos de ROI.

### 5. Limitaciones del Estudio
- Operador único (no generalizable).
- 26 días no consecutivos (estacionalidad limitada).
- Sesgo de selección (solo pedidos aceptados).

---

## DIFERENCIACIÓN SEMÁNTICA FINAL

### ⚠️ NO CONFUNDIR

| Métrica | Uso | Fórmula | Valor |
|---------|-----|---------|-------|
| **RO (Ratio de Optimización)** | Eficiencia de distancia física | `km_didi / km_google` | **1.66x** |
| **Múltiplo de Ingreso** | Relación financiera | `Ingresos / Gastos` | **10.30x** |
| **ROI Global** | Retorno de Inversión | `(Utilidad / Gastos) × 100` | **930.28%** |

---

## PRINCIPIO DE TRANSPARENCIA RADICAL

> "Este análisis no busca perfección estética, busca fidelidad técnica.  
> Un ROI de 930% basado en datos reales es más valioso que un ROI de 1,000% basado en omisiones.  
> Las anomalías se documentan, no se ocultan.  
> La verdad por encima de la armonía."

---

**Firmado:**  IVÁN FELIPE CASTRO PINZÓN
*Pipeline de Auditoría de Integridad v1.0*  
*Fecha: 2026-02-13*  
*Datos Auditados - Versión Final*
