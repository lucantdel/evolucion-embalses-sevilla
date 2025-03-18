# Análisis de la Evolución del Área de Agua en el Embalse de Melonares

Este repositorio contiene el código, datos y resultados del proyecto de teledetección realizado para analizar la evolución mensual del área de agua en el **Embalse de Melonares (Sevilla)** entre **marzo de 2024 y marzo de 2025**. El proyecto utiliza imágenes satelitales **Sentinel-2** descargadas desde **Copernicus Browser** y procesadas en **MATLAB** para calcular el **Índice de Diferencia Normalizada de Agua (NDWI)**. Además, se incluye una comparación con datos de **2023** para identificar patrones anómalos, como sequías.

---

## 📌 Objetivos

1. **Principal**:  
   Cuantificar la variación mensual del área de agua del embalse entre marzo de 2024 y marzo de 2025 utilizando imágenes Sentinel-2 y el NDWI.

2. **Secundario**:  
   Comparar los resultados con datos de 2023 para identificar anomalías asociadas a eventos climáticos extremos (ej. sequías).

---

## 🛠️ Herramientas Utilizadas

- **MATLAB**: Para el procesamiento de imágenes y cálculo de NDWI.
- **Copernicus Browser**: Para la descarga de imágenes Sentinel-2.
- **GeoJSON**: Para definir la región de interés (ROI) del embalse.
- **GitHub**: Para la gestión y documentación del proyecto.

---

## 📂 Estructura del Repositorio

Para más detalles sobre la estructura del proyecto, consulta el archivo [apartados.md](documentacion/apartados.md).

---

## 🚀 Cómo Usar Este Repositorio

1. **Clona el repositorio**:
    '''bash
    https://github.com/lucantdel/evolucion-embalses-sevilla.git
    '''

2. **Ejecuta los scripts de MATLAB**:
   - Navega a la carpeta `/codigo` y ejecuta los scripts en el siguiente orden:
     1. `descarga_imagenes.m`: Para cargar y recortar las imágenes.
     2. `calculo_NDWI.m`: Para calcular el NDWI.
     3. `clasificacion.m`: Para generar mapas binarios de agua.
     4. `filtrado.m`: Para aplicar el filtro de mediana.

3. **Explora los resultados**:
   - Los mapas y gráficas generados se encuentran en la carpeta `/resultados`.

---

## 🔗 Enlace al Repositorio

[https://github.com/lucantdel/evolucion-embalses-sevilla](https://github.com/lucantdel/evolucion-embalses-sevilla)
