# Documentación del Proyecto: Embalse de Melonares

Este archivo contiene los apartados escritos hasta el momento para el proyecto de análisis de la evolución del área de agua en el Embalse de Melonares. Estos apartados forman parte de la estructura general del trabajo y se organizan según las directrices proporcionadas en la guía de la asignatura.

---

## 1. Introducción

### 1.a: Naturaleza del estudio

El **Embalse de Melonares**, ubicado en la provincia de Sevilla (España), es una infraestructura hidráulica clave para el abastecimiento de agua en la región. Geográficamente, se sitúa entre las coordenadas *[-5.855, 37.717] y [-5.933, 37.831]* (archivo `embalse-melonares.geojson`), abarcando una superficie máxima de aproximadamente **2.5 km²**.

Este estudio se centra en analizar la **evolución mensual del área superficial de agua** del embalse entre **marzo de 2024 y marzo de 2025**, utilizando imágenes satelitales **Sentinel-2** procesadas en **MATLAB**. La variación del área de agua se calculará mediante el **Índice de Diferencia Normalizada de Agua (NDWI)**, una técnica ampliamente validada en teledetección para identificar masas de agua.

---

### 1.b: Objetivos

**Objetivo principal**:  
Cuantificar la variación mensual del área de agua del Embalse de Melonares durante el período **marzo 2024 - marzo 2025**, utilizando **13 imágenes Sentinel-2** (1 por mes) descargadas desde Copernicus Browser.

**Metodología de análisis**:  
- **Rango temporal**: 13 meses (desde marzo 2024 hasta marzo 2025).  
- **Frecuencia**: Adquisición de 1 imagen mensual, priorizando fechas cercanas al día 15 para minimizar variaciones estacionales.  
- **Indicador**: Cálculo del NDWI (\( \text{NDWI} = \frac{B3 - B8}{B3 + B8} \)) y umbralización (\( \text{NDWI} \geq 0.2 \)) para discriminar agua.  

**Objetivo secundario**:  
Comparar los resultados con datos históricos de **2023** para identificar anomalías asociadas a eventos climáticos extremos (ej. sequías).

---

## 2. Metodología

### 2.a: Imágenes Satelitales Utilizadas

| **Fecha**       | **Satélite** | **Sensor** | **Bandas** | **Resolución** | **Nubosidad** |  
|-----------------|--------------|------------|------------|-----------------|---------------|  
| 15/03/2024     | Sentinel-2B  | MSI        | B3, B8, B11, B12 | 10m | <5% |  
| 15/04/2024     | Sentinel-2A  | MSI        | B3, B8, B11, B12 | 10m | <5% |  
| ...            | ...          | ...        | ...        | ...             | ...           |  

- **Bandas utilizadas**:  
  - **B3 (Verde)**: Para el cálculo del NDWI.  
  - **B8 (NIR)**: Para el cálculo del NDWI.  
  - **B11 (SWIR)**: Opcional, para el cálculo del MNDWI.  
  - **B12 (SWIR)**: Opcional, para mejorar la precisión en zonas con vegetación acuática.  

- **Recorte de la ROI**:  
  Se utilizó un archivo **GeoJSON** para definir la región de interés (ROI) del embalse. Las imágenes se recortaron utilizando las coordenadas del embalse.

---

## 📄 Más Información

Para más detalles sobre el proyecto, consulta el archivo [README.md](README.md).