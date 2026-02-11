# 📐 Metodología del Análisis

## Marco Conceptual

### Definición del Problema

El algoritmo de ruteo de DiDi Food calcula distancias basándose en rutas vehiculares optimizadas para automóviles. Sin embargo, un ciclista urbano en Bogotá (específicamente en Kennedy/Fontibón) tiene acceso a:

1. **Infraestructura ciclística exclusiva** (ciclorrutas, ciclobandas)
2. **Atajos peatonales** (parques, plazas, andenes amplios)
3. **Flexibilidad de tránsito** (contraflujo seguro, giros prohibidos para carros)

Esta **asimetría de información** genera una oportunidad de arbitraje cuantificable.

---

## Diseño del Estudio

### Tipo de Estudio
- **Observacional descriptivo**
- **Longitudinal** (25 días consecutivos de operación)
- **Caso único** (1 operador)

### Población y Muestra
- **Población:** Repartidores en bicicleta de DiDi Food en Bogotá
- **Muestra:** N=25 días operativos (censo completo del periodo)
- **Periodo:** 5 diciembre 2025 - 30 enero 2026
- **Zona:** Kennedy, Salitre, Fontibón

---

## Variables del Estudio

### Variables Primarias (Recolectadas)

| Variable | Tipo | Unidad | Método de Recolección |
|----------|------|--------|----------------------|
| `fecha` | Cualitativa nominal | YYYY-MM-DD | Calendario |
| `h_inicio` | Cuantitativa continua | HH:MM | App DiDi (timestamp) |
| `h_fin` | Cuantitativa continua | HH:MM | App DiDi (timestamp) |
| `km_google_maps` | Cuantitativa continua | km | Google Maps Timeline |
| `km_didi_app` | Cuantitativa continua | km | App DiDi (suma de pedidos) |
| `ingreso_bruto` | Cuantitativa continua | COP | App DiDi (resumen) |
| `pedidos_cohete` | Cuantitativa discreta | pedidos | Contador manual |
| `pedidos_normales` | Cuantitativa discreta | pedidos | Contador manual |
| `gasto_extra` | Cuantitativa continua | COP | Recibos físicos |

### Variables Derivadas (Calculadas)

| Variable | Fórmula | Interpretación |
|----------|---------|----------------|
| **Ratio de Optimización (RO)** | `km_didi_app / km_google_maps` | Factor de multiplicación algorítmico |
| **Utilidad Neta** | `ingreso - gasto - (km × 124)` | Ganancia real después de desgaste |
| **Ingreso por KM Real** | `utilidad / km_google` | Rentabilidad por kilómetro pedaleado |
| **Velocidad Enganche** | `tiempo_total / pedidos` | Minutos promedio por pedido |
| **Velocidad Operativa** | `km_google / tiempo_horas` | Velocidad real de desplazamiento |
| **Salario Efectivo/Hora** | `utilidad / tiempo_horas` | Ganancia horaria real |
| **Eficiencia Cohete %** | `(cohetes / totales) × 100` | Proporción de pedidos largos |

---

## Instrumentos de Medición

### 1. Google Maps Timeline
- **Propósito:** Medir km_google_maps (distancia real)
- **Precisión:** ±5% en ambiente urbano
- **Ventaja:** Registra automáticamente rutas completas

### 2. App DiDi Food
- **Propósito:** Obtener km_didi_app, ingreso_bruto
- **Método:** Captura de pantalla de cada pedido
- **Limitación:** Solo muestra distancia euclidiana/vehicular

### 3. Contador Manual
- **Propósito:** Clasificar pedidos (cohete vs normal)
- **Criterio:** Cohete si distancia ≥ 7km
- **Método:** Anotación en tiempo real

### 4. Recibos Físicos
- **Propósito:** Registrar gasto_extra
- **Componentes:** Comida, bebidas, reparaciones
- **Método:** Fotografía + suma diaria

---

## Protocolo de Recolección

### Pre-Turno
1. Verificar Google Maps esté rastreando ubicación
2. Sincronizar hora del dispositivo
3. Preparar material de anotación

### Durante Turno
1. Anotar hora inicio al aceptar primer pedido
2. Registrar distancia mostrada por DiDi en cada pedido
3. Marcar como "cohete" si distancia ≥7km
4. Guardar todos los recibos de gastos

### Post-Turno
1. Anotar hora fin al llegar a casa
2. Capturar Google Maps Timeline
3. Capturar resumen DiDi del día
4. Transferir datos a CSV
5. Verificar integridad de datos

---

## Tratamiento de Datos

### Limpieza

```python
# Conversión de formatos
km_google = float(valor.replace(',', '.').replace(' km', ''))

# Cálculo de pedidos normales
pedidos_normales = pedidos_fisicos - pedidos_cohete

# Validaciones
assert km_didi >= km_google * 0.8  # Verificar coherencia
assert ingreso_bruto > 0
```

### Exclusión de Datos
- **Días excluidos:** 0 (todos los días fueron válidos)
- **Criterio de inclusión:** Turno completo con datos completos

---

## Cálculos Estadísticos

### Medidas de Tendencia Central
- Media aritmética para todas las métricas continuas
- Mediana para distribuciones asimétricas

### Medidas de Dispersión
- Desviación estándar
- Rango (mínimo - máximo)
- Coeficiente de variación (CV)

### Análisis de Relaciones
- Correlación de Pearson entre:
  - `ratio_optimizacion` y `eficiencia_cohete`
  - `km_google_maps` y `salario_efectivo_hora`
  - `tiempo_total` y `utilidad_neta`

---

## Supuestos y Limitaciones

### Supuestos

1. **Desgaste de bicicleta:** $124/km constante
   - Basado en costo de consumibles (llantas, cadena, frenos)
   - Promedio de vida útil de componentes

2. **Clima:** Siempre operación en seco
   - Criterio operativo: No trabajar bajo lluvia
   - Por tanto, clima no se registra como variable

3. **Zona:** Operación concentrada en Kennedy/Fontibón
   - Infraestructura ciclística relativamente homogénea
   - Resultados podrían no generalizarse a otras zonas

### Limitaciones

1. **Muestra de tamaño N=1:** Un solo operador
   - Limita generalización a otros ciclistas
   - Mitiga: Periodo extenso (25 días)

2. **Sin control de variables externas:**
   - Tráfico vehicular
   - Día de la semana
   - Hora del día (mañana vs tarde vs noche)

3. **Medición de km_google:**
   - Depende de precisión GPS
   - Posibles errores en túneles/edificios altos

4. **Sesgo de selección de pedidos:**
   - El operador elige qué pedidos aceptar
   - Podría inflar artificialmente el RO

---

## Validez y Confiabilidad

### Validez Interna
- ✅ Datos verificables (capturas de pantalla)
- ✅ Mediciones objetivas (GPS, app)
- ✅ Protocolo estandarizado de recolección

### Validez Externa
- ⚠️ Limitada a contexto urbano Bogotá
- ⚠️ Específico para infraestructura Kennedy/Fontibón
- ⚠️ Periodo corto (2 meses)

### Confiabilidad
- ✅ Datos replicables (mismo operador, misma zona)
- ✅ Instrumentos estandarizados (Google Maps, DiDi App)
- ✅ Protocolo documentado

---

## Consideraciones Éticas

1. **Privacidad:** Datos anonimizados (sin nombres de clientes)
2. **Legalidad:** Cumplimiento de términos de servicio de DiDi
3. **Transparencia:** Metodología completamente documentada
4. **Uso:** Estrictamente académico/investigativo

---

## Procesamiento de Datos

### Software Utilizado
- **MySQL 8.0:** Almacenamiento y análisis de datos
- **Python 3.8:** Limpieza y validación de datos
- **Excel:** Entrada inicial de datos

### Pipeline de Datos

```
CSV Crudo → Limpieza Python → MySQL → Análisis SQL → Resultados
```

### Control de Calidad
- ✅ Verificación de suma: km_didi ≈ suma de pedidos individuales
- ✅ Coherencia temporal: h_fin > h_inicio
- ✅ Rango válido: RO entre 0.8 y 3.0

---

## Próximos Pasos Metodológicos

Para futuras extensiones del estudio:

1. **Ampliar muestra:** Múltiples operadores
2. **Análisis espacial:** Mapeo de zonas con mayor RO
3. **Variables adicionales:** Clima, tráfico, día de semana
4. **Estudio comparativo:** Bogotá vs otras ciudades
5. **Modelado predictivo:** Predecir RO basado en condiciones

---

**Documento de Metodología v1.0**  
**Fecha:** Enero 2026  
**Autor:** [Tu Nombre]
