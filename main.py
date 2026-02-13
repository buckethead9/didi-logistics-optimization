#!/usr/bin/env python3
"""
DiDi Algorithmic Arbitrage: Pipeline de Procesamiento de Datos
Autor: Iván Felipe Castro Pinzón
Versión: 2.0
Python: 3.14

Este script procesa datos crudos de operaciones de logística en bicicleta,
audita la asimetría algorítmica y genera datasets limpios para análisis SQL.
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime, timedelta
import warnings
import sys

warnings.filterwarnings('ignore')

# =============================================================================
# CONFIGURACIÓN GLOBAL
# =============================================================================

class Config:
    """Configuración inmutable del pipeline"""
    
    # Rutas (Windows MAX_PATH compatible)
    BASE_DIR = Path(__file__).parent
    DATA_RAW = BASE_DIR / "data" / "raw"
    DATA_PROCESSED = BASE_DIR / "data" / "processed"
    SQL_DIR = BASE_DIR / "sql"
    
    # Constantes del modelo (Fuente de Verdad)
    DESGASTE_BICI_POR_KM = 124  # COP por km
    SALARIO_MINIMO_HORA = 6667  # COP 2026
    UMBRAL_COHETE = 7.0  # km
    UMBRAL_ARBITRAJE_AGRESIVO = 1.5  # RO threshold
    
    # Métricas confirmadas del análisis
    RO_GLOBAL_ESPERADO = 1.71
    UTILIDAD_TOTAL_ESPERADA = 4_009_530
    EFICIENCIA_COHETE_ESPERADA = 83.4
    ROI_OPERATIVO_ESPERADO = 2479

# =============================================================================
# FUNCIONES DE LIMPIEZA
# =============================================================================

def limpiar_kilometros(valor):
    """
    Limpia valores de KM del formato '45,06 km' a float 45.06
    
    Args:
        valor: String con formato variable
        
    Returns:
        float: Valor numérico limpio
    """
    if pd.isna(valor):
        return np.nan
    
    valor_str = str(valor)
    valor_str = valor_str.replace('"', '').replace(' km', '').replace(',', '.')
    
    try:
        return float(valor_str.strip())
    except ValueError:
        return np.nan

def limpiar_dinero(valor):
    """
    Limpia valores monetarios eliminando separadores
    
    Args:
        valor: String o número
        
    Returns:
        float: Valor numérico
    """
    if pd.isna(valor):
        return 0.0
    
    valor_str = str(valor).replace(',', '').replace('$', '')
    
    try:
        return float(valor_str.strip())
    except ValueError:
        return 0.0

def calcular_tiempo_horas(h_inicio, h_fin):
    """
    Calcula tiempo total en horas entre dos timestamps
    
    Args:
        h_inicio: String HH:MM
        h_fin: String HH:MM
        
    Returns:
        float: Horas totales
    """
    try:
        inicio = datetime.strptime(h_inicio, '%H:%M')
        fin = datetime.strptime(h_fin, '%H:%M')
        
        # Si fin < inicio, el turno cruzó medianoche
        if fin < inicio:
            fin += timedelta(days=1)
        
        diferencia = fin - inicio
        return diferencia.total_seconds() / 3600
    except:
        return np.nan

# =============================================================================
# CLASE PRINCIPAL DE PROCESAMIENTO
# =============================================================================

class DiDiDataProcessor:
    """
    Pipeline de procesamiento de datos de logística DiDi
    """
    
    def __init__(self, config=Config):
        self.config = config
        self.df_raw = None
        self.df_processed = None
        self.metricas_globales = {}
        
        # Crear directorios si no existen
        self.config.DATA_RAW.mkdir(parents=True, exist_ok=True)
        self.config.DATA_PROCESSED.mkdir(parents=True, exist_ok=True)
        self.config.SQL_DIR.mkdir(parents=True, exist_ok=True)
    
    def cargar_datos_crudos(self, filepath):
        """
        Carga dataset crudo desde CSV
        
        Args:
            filepath: Ruta al archivo CSV
            
        Returns:
            bool: True si carga exitosa
        """
        print(f"\n{'='*70}")
        print(f"[INGESTA] Cargando datos desde: {filepath}")
        print(f"{'='*70}")
        
        try:
            self.df_raw = pd.read_csv(filepath, encoding='utf-8')
            print(f"✓ {len(self.df_raw)} registros cargados exitosamente")
            return True
        except Exception as e:
            print(f"✗ ERROR: {e}")
            return False
    
    def limpiar_datos(self):
        """
        Aplica todas las transformaciones de limpieza
        
        Returns:
            bool: True si limpieza exitosa
        """
        if self.df_raw is None:
            print("✗ ERROR: No hay datos cargados")
            return False
        
        print(f"\n{'='*70}")
        print("[LIMPIEZA] Iniciando transformaciones...")
        print(f"{'='*70}")
        
        df = self.df_raw.copy()
        
        # 1. Limpiar KM
        print("  → Limpiando kilómetros...")
        if 'km_google_maps' in df.columns:
            df['km_google_maps'] = df['km_google_maps'].apply(limpiar_kilometros)
        
        if 'km_didi_app' in df.columns:
            df['km_didi_app'] = df['km_didi_app'].apply(limpiar_kilometros)
        
        # 2. Limpiar dinero
        print("  → Limpiando valores monetarios...")
        for col in ['garantizado_meta', 'ingreso_base', 'complemento_bono', 'gastos_operativos']:
            if col in df.columns:
                df[col] = df[col].apply(limpiar_dinero)
        
        # 3. Calcular pedidos normales
        if 'pedidos_fisicos' in df.columns and 'unidades_progreso' in df.columns:
            df['pedidos_normales'] = df['pedidos_fisicos'] - df['unidades_progreso']
        
        # 4. Renombrar al esquema final
        print("  → Normalizando columnas...")
        rename_map = {
            'garantizado_meta': 'ingreso_bruto',
            'unidades_progreso': 'pedidos_cohete',
            'gastos_operativos': 'gasto_extra'
        }
        df.rename(columns=rename_map, inplace=True)
        
        # 5. Seleccionar columnas finales
        cols_finales = [
            'fecha', 'h_inicio', 'h_fin',
            'km_google_maps', 'km_didi_app',
            'ingreso_bruto', 'pedidos_cohete', 'pedidos_normales',
            'gasto_extra'
        ]
        
        df = df[[col for col in cols_finales if col in df.columns]]
        
        # 6. Eliminar filas con datos críticos faltantes
        antes = len(df)
        df = df.dropna(subset=['fecha', 'km_google_maps', 'km_didi_app'])
        despues = len(df)
        
        if antes > despues:
            print(f"  → Eliminadas {antes - despues} filas con datos críticos faltantes")
        
        self.df_processed = df
        print(f"✓ Limpieza completada: {len(df)} registros válidos\n")
        
        return True
    
    def calcular_metricas(self):
        """
        Calcula todas las métricas derivadas
        
        Returns:
            bool: True si cálculo exitoso
        """
        if self.df_processed is None:
            print("✗ ERROR: No hay datos procesados")
            return False
        
        print(f"{'='*70}")
        print("[AUDITORÍA] Calculando métricas derivadas...")
        print(f"{'='*70}")
        
        df = self.df_processed.copy()
        
        # 1. Tiempo total
        print("  → Calculando tiempo_total_horas...")
        if 'h_inicio' in df.columns and 'h_fin' in df.columns:
            df['tiempo_total_horas'] = df.apply(
                lambda row: calcular_tiempo_horas(row['h_inicio'], row['h_fin']),
                axis=1
            )
        
        # 2. Pedidos totales
        df['pedidos_totales'] = df['pedidos_cohete'] + df['pedidos_normales']
        
        # 3. Ratio de Optimización (RO) - MÉTRICA CLAVE
        print("  → Calculando Ratio de Optimización (RO)...")
        df['ratio_optimizacion'] = df['km_didi_app'] / df['km_google_maps']
        
        # 4. Clasificación de Arbitraje
        df['estrategia_status'] = df['ratio_optimizacion'].apply(
            lambda x: 'Arbitraje Agresivo' if x >= self.config.UMBRAL_ARBITRAJE_AGRESIVO 
                     else 'Optimización Estándar'
        )
        
        # 5. Utilidad Neta
        print("  → Calculando utilidad_neta...")
        df['utilidad_neta'] = (
            df['ingreso_bruto'] 
            - df['gasto_extra'] 
            - (df['km_google_maps'] * self.config.DESGASTE_BICI_POR_KM)
        )
        
        # 6. Ingreso por KM Real
        df['ingreso_por_km_real'] = (
            (df['ingreso_bruto'] - df['gasto_extra']) / df['km_google_maps']
        )
        
        # 7. Velocidad de Enganche (min/pedido)
        df['velocidad_enganche'] = (
            df['tiempo_total_horas'] * 60 / df['pedidos_totales']
        )
        
        # 8. Velocidad Operativa (km/h)
        df['velocidad_operativa'] = (
            df['km_google_maps'] / df['tiempo_total_horas']
        )
        
        # 9. Salario Efectivo por Hora
        print("  → Calculando salario_efectivo_hora...")
        df['salario_efectivo_hora'] = (
            df['utilidad_neta'] / df['tiempo_total_horas']
        )
        
        # 10. Eficiencia Cohete %
        df['eficiencia_cohete_pct'] = (
            df['pedidos_cohete'] / df['pedidos_totales'] * 100
        )
        
        self.df_processed = df
        print(f"✓ Métricas calculadas: {len(df.columns)} columnas totales\n")
        
        return True
    
    def generar_reporte_auditoria(self):
        """
        Genera reporte de auditoría con métricas globales
        """
        if self.df_processed is None:
            print("✗ ERROR: No hay datos procesados")
            return
        
        df = self.df_processed
        
        print(f"{'='*70}")
        print("[AUDITORÍA] Reporte de Métricas Globales")
        print(f"{'='*70}\n")
        
        # Métricas calculadas
        ro_global = df['km_didi_app'].sum() / df['km_google_maps'].sum()
        utilidad_total = df['utilidad_neta'].sum()
        eficiencia_cohete = df['eficiencia_cohete_pct'].mean()
        
        # ROI
        gastos_totales = df['gasto_extra'].sum()
        desgaste_total = (df['km_google_maps'] * self.config.DESGASTE_BICI_POR_KM).sum()
        costos_totales = gastos_totales + desgaste_total
        roi_operativo = (utilidad_total / costos_totales) * 100
        
        # Guardar métricas
        self.metricas_globales = {
            'dias_operativos': len(df),
            'km_reales': df['km_google_maps'].sum(),
            'km_reportados': df['km_didi_app'].sum(),
            'km_fantasma': df['km_didi_app'].sum() - df['km_google_maps'].sum(),
            'ro_global': ro_global,
            'utilidad_total': utilidad_total,
            'eficiencia_cohete': eficiencia_cohete,
            'roi_operativo': roi_operativo,
            'salario_promedio_hora': df['salario_efectivo_hora'].mean()
        }
        
        # Imprimir reporte
        print(f"Días Operativos:           {self.metricas_globales['dias_operativos']}")
        print(f"KM Reales Pedaleados:      {self.metricas_globales['km_reales']:,.1f} km")
        print(f"KM Reportados por DiDi:    {self.metricas_globales['km_reportados']:,.1f} km")
        print(f"KM Fantasma:               {self.metricas_globales['km_fantasma']:,.1f} km")
        print(f"\n{'─'*70}")
        print(f"🚀 Ratio de Optimización:  {ro_global:.2f}x")
        print(f"💰 Utilidad Neta Total:    ${utilidad_total:,.0f} COP")
        print(f"📊 Eficiencia Cohete:      {eficiencia_cohete:.1f}%")
        print(f"📈 ROI Operativo:          {roi_operativo:,.0f}%")
        print(f"⏱️  Salario Promedio/Hora:  ${self.metricas_globales['salario_promedio_hora']:,.0f}/h")
        print(f"{'─'*70}\n")
        
        # Validación contra valores esperados
        print("[VALIDACIÓN] Comparando contra métricas esperadas:")
        print(f"  RO:       {ro_global:.2f}x vs {self.config.RO_GLOBAL_ESPERADO}x esperado")
        print(f"  Utilidad: ${utilidad_total:,.0f} vs ${self.config.UTILIDAD_TOTAL_ESPERADA:,.0f} esperado")
        print(f"  Efic:     {eficiencia_cohete:.1f}% vs {self.config.EFICIENCIA_COHETE_ESPERADA}% esperado")
        print(f"  ROI:      {roi_operativo:,.0f}% vs {self.config.ROI_OPERATIVO_ESPERADO}% esperado\n")
        
        # Distribución por estrategia
        print(f"{'='*70}")
        print("[DISTRIBUCIÓN] Clasificación por Estrategia")
        print(f"{'='*70}")
        dist = df['estrategia_status'].value_counts()
        for estrategia, count in dist.items():
            pct = (count / len(df)) * 100
            print(f"  {estrategia:25} {count:3} días ({pct:5.1f}%)")
        print()
    
    def guardar_procesados(self, filename="didi_procesado.csv"):
        """
        Guarda dataset procesado en CSV
        
        Args:
            filename: Nombre del archivo de salida
        """
        if self.df_processed is None:
            print("✗ ERROR: No hay datos procesados")
            return False
        
        output_path = self.config.DATA_PROCESSED / filename
        
        try:
            self.df_processed.to_csv(output_path, index=False, encoding='utf-8')
            print(f"✓ Datos guardados en: {output_path}")
            print(f"  {len(self.df_processed)} registros")
            print(f"  {len(self.df_processed.columns)} columnas\n")
            return True
        except Exception as e:
            print(f"✗ ERROR al guardar: {e}")
            return False
    
    def ejecutar_pipeline_completo(self, input_file):
        """
        Ejecuta todo el pipeline de procesamiento
        
        Args:
            input_file: Ruta al archivo CSV crudo
        """
        print("\n" + "="*70)
        print(" DiDi Algorithmic Arbitrage: Pipeline de Procesamiento")
        print(" Versión 2.0 - Auditoría de Asimetría Algorítmica")
        print("="*70)
        
        # 1. Cargar
        if not self.cargar_datos_crudos(input_file):
            return False
        
        # 2. Limpiar
        if not self.limpiar_datos():
            return False
        
        # 3. Calcular métricas
        if not self.calcular_metricas():
            return False
        
        # 4. Generar reporte
        self.generar_reporte_auditoria()
        
        # 5. Guardar
        self.guardar_procesados()
        
        print("="*70)
        print("✓ PIPELINE COMPLETADO EXITOSAMENTE")
        print("="*70 + "\n")
        
        return True

# =============================================================================
# FUNCIÓN MAIN
# =============================================================================

def main():
    """
    Punto de entrada principal del script
    """
    # Validar argumentos
    if len(sys.argv) < 2:
        print("Uso: python main.py <archivo_csv>")
        print("Ejemplo: python main.py data/raw/didi_diciembre_enero_COMPLETO.csv")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    # Validar que existe el archivo
    if not Path(input_file).exists():
        print(f"✗ ERROR: No se encuentra el archivo: {input_file}")
        sys.exit(1)
    
    # Ejecutar pipeline
    processor = DiDiDataProcessor()
    success = processor.ejecutar_pipeline_completo(input_file)
    
    if not success:
        print("\n✗ El pipeline falló. Revisa los errores anteriores.")
        sys.exit(1)
    
    print("✓ Datos procesados listos para análisis SQL")
    print(f"✓ Archivo: {Config.DATA_PROCESSED / 'didi_procesado.csv'}")

if __name__ == "__main__":
    main()
