# Documentación del Proyecto: Embalse de Melonares

Este archivo contiene los apartados escritos hasta el momento para el proyecto de análisis de la evolución del área de agua en el Embalse de Melonares. Estos apartados forman parte de la estructura general del trabajo y se organizan según las directrices proporcionadas en la guía de la asignatura.

---

# 1. Introducción

## 1.a. Naturaleza del estudio

El Embalse de Melonares, ubicado en Sevilla, es un importante recurso hídrico para la región andaluza. Construido sobre el río Viar y con una capacidad de 180 hm³, este embalse provee agua para consumo humano y agrícola a la zona metropolitana de Sevilla.

El presente estudio analiza la evolución mensual del área de agua del embalse durante el período 2023-2025, utilizando imágenes multiespectrales del satélite Sentinel-2. Este análisis permitirá comprender las variaciones estacionales del embalse y evaluar su respuesta ante eventos climáticos como sequías o períodos de lluvia intensa.

## 1.b. Objetivos

1. Calcular el área de agua mensual del Embalse de Melonares mediante el índice NDWI (Normalized Difference Water Index), utilizando imágenes Sentinel-2.
2. Generar mapas de clasificación que muestren la extensión del agua en diferentes períodos.
3. Comparar los resultados con datos históricos (2023-2024) para identificar patrones de variación temporal.
4. Evaluar la correlación entre los cambios en la superficie de agua y factores climáticos como precipitación y temperatura.
5. Visualizar la evolución temporal mediante gráficas que muestren las tendencias mensuales durante el período estudiado.

# 2. Metodología

## 2.a. Imágenes satelitales utilizadas

Para este estudio se utilizaron imágenes del satélite Sentinel-2, obtenidas a través de la plataforma Copernicus Browser. Las características de estas imágenes son:

| Característica | Descripción |
|----------------|-------------|
| Satélite | Sentinel-2 |
| Sensor | MultiSpectral Instrument (MSI) |
| Nivel de procesamiento | Level-2A (reflectancia de superficie) |
| Resolución espacial | 10-20m (según banda) |
| Resolución temporal | 5 días (con combinación de S-2A y S-2B) |
| Periodo analizado | Enero 2023 - Marzo 2025 |

### Bandas utilizadas

El análisis se centró principalmente en las siguientes bandas espectrales:

- **B03 (Verde)**: 560 nm, 10m de resolución - Utilizada para cálculo de NDWI
- **B08 (NIR)**: 842 nm, 10m de resolución - Utilizada para cálculo de NDWI
- **B11 (SWIR)**: 1610 nm, 20m de resolución - Apoyo para análisis complementarios
- **B12 (SWIR)**: 2190 nm, 20m de resolución - Apoyo para análisis complementarios

Para optimizar el procesamiento, las imágenes originales de 868x1599 píxeles fueron recortadas al área de interés (Embalse de Melonares) y posteriormente diezmadas conservando 1 de cada 2 píxeles, resultando en imágenes de procesamiento de aproximadamente 434x800 píxeles.

![Ejemplo de imagen del Embalse de Melonares](./resultados/ejemplo_embalse.png)

### Histograma de la banda NIR

El análisis de histograma de la banda NIR (infrarrojo cercano) es fundamental para este estudio, ya que esta banda es especialmente sensible a la presencia de agua. En las siguientes imágenes se muestra el histograma de esta banda para diferentes momentos del año:

![Histograma NIR - Enero 2023](./resultados/realce/2023-01/histograma_nir.png)
![Histograma NIR - Julio 2023](./resultados/realce/2023-07/histograma_nir.png)
![Histograma NIR - Enero 2024](./resultados/realce/2024-01/histograma_nir.png)

Los histogramas revelan una distribución bimodal característica, donde los valores más bajos corresponden a cuerpos de agua (el embalse) y los valores más altos a vegetación y suelo circundante.

### Composiciones en color

Para mejorar la interpretación visual de las imágenes, se generaron dos tipos de composiciones en color:

**Composición en color verdadero (True-color)**: Simula lo que vería el ojo humano, utilizando las bandas visibles.

![True-color - Enero 2023](./resultados/realce/2023-01/true_color.png)

**Composición en falso color (NIR-G-B)**: Coloca la banda NIR en el canal rojo, resaltando la vegetación en tonos rojizos y el agua en tonos oscuros.

![False-color - Enero 2023](./resultados/realce/2023-01/false_color.png)

Esta combinación es particularmente útil para distinguir el límite agua-tierra del embalse.

## 2.b. Indicador empleado

Para identificar y cuantificar el área de agua del Embalse de Melonares, se utilizó el Índice de Diferencia Normalizada de Agua (NDWI, Normalized Difference Water Index). Este índice fue propuesto por McFeeters (1996) y es especialmente efectivo para resaltar cuerpos de agua abiertos.

### Fundamento del NDWI

El NDWI aprovecha las propiedades espectrales del agua, que refleja más radiación en el espectro visible (especialmente verde) que en el infrarrojo cercano (NIR). La fórmula utilizada es:

NDWI = (Verde - NIR) / (Verde + NIR)

Donde:
- Verde corresponde a la banda B03 (560 nm) de Sentinel-2
- NIR corresponde a la banda B08 (842 nm) de Sentinel-2

### Rangos de trabajo

El NDWI genera valores en el rango de -1 a 1, donde:
- Valores positivos (> 0) indican presencia de agua
- Valores negativos (< 0) representan superficies terrestres
- Cuanto mayor es el valor positivo, mayor es la probabilidad de que sea agua pura

### Visualización del NDWI

Para una mejor interpretación visual, se aplicó una escala de pseudocolor al NDWI:
- Tonos azules: representan píxeles con alta probabilidad de ser agua (NDWI > 0)
- Tonos verdes: representan píxeles sin agua (NDWI ≤ 0)

![NDWI - Enero 2023](./resultados/indices/2023-01/ndwi_color.png)
![NDWI - Julio 2023](./resultados/indices/2023-07/ndwi_color.png)

Esta representación permite identificar fácilmente los límites del embalse y valorar visualmente los cambios temporales en su extensión.

# 3. Resultados

## 3.a. Mapas de clasificación

A partir del índice NDWI, se realizó una clasificación binaria para identificar los píxeles correspondientes a agua y no-agua. Se utilizó un umbral de 0.2, que es comúnmente aceptado para distinguir cuerpos de agua claros.

La clasificación generó los siguientes mapas para diferentes fechas:

| Fecha | Mapa de Clasificación | Área (ha) |
|-------|------------------------|-----------|
| Enero 2023 | ![Clasificación Ene-2023](./resultados/clasificacion/2023-01/clasificacion_color.png) | 642.3 |
| Abril 2023 | ![Clasificación Abr-2023](./resultados/clasificacion/2023-04/clasificacion_color.png) | 723.8 |
| Julio 2023 | ![Clasificación Jul-2023](./resultados/clasificacion/2023-07/clasificacion_color.png) | 618.5 |
| Octubre 2023 | ![Clasificación Oct-2023](./resultados/clasificacion/2023-10/clasificacion_color.png) | 582.7 |

En los mapas de clasificación, el color azul representa el agua y el verde las áreas terrestres circundantes. Se puede observar cómo la extensión del embalse varía a lo largo del año, con máximos típicamente en primavera tras las lluvias estacionales, y mínimos a finales de verano debido a la elevada evaporación y el consumo hídrico.

La evolución temporal del área de agua muestra patrones estacionales claros:

![Evolución Temporal](./resultados/clasificacion/evolucion_temporal.png)

Esta gráfica permite identificar los periodos de mayor almacenamiento y las tendencias interanuales, lo que resulta fundamental para la gestión del recurso hídrico.

## 3.b. Mapas de clasificación filtrados

Para reducir el ruido en los mapas de clasificación y obtener una delimitación más precisa del embalse, se aplicó un filtro de mediana a los resultados. Este filtro es especialmente útil para eliminar píxeles aislados ("sal y pimienta") sin afectar significativamente los bordes del embalse.

A continuación se muestra la comparación entre mapas originales y filtrados para algunas fechas seleccionadas:

| Fecha | Clasificación Original | Clasificación Filtrada |
|-------|------------------------|------------------------|
| Enero 2023 | ![Original Ene-2023](./resultados/clasificacion/2023-01/clasificacion_color.png) | ![Filtrado Ene-2023](./resultados/filtrados/2023-01/clasificacion_filtrada_color.png) |
| Julio 2023 | ![Original Jul-2023](./resultados/clasificacion/2023-07/clasificacion_color.png) | ![Filtrado Jul-2023](./resultados/filtrados/2023-07/clasificacion_filtrada_color.png) |

Se puede observar cómo el filtro de mediana elimina pequeños grupos de píxeles clasificados erróneamente, produciendo una delimitación más homogénea y realista del embalse.

## 3.c. Datos obtenidos (gráficas)

La aplicación del filtro de mediana tuvo un impacto en la estimación del área del embalse. La siguiente gráfica muestra la comparación entre las áreas calculadas con y sin filtrado:

![Comparación de Filtrado](./resultados/filtrados/comparacion_filtrado.png)

Las principales estadísticas del efecto del filtrado son:
- Diferencia media: 8.45 hectáreas
- Diferencia porcentual media: 1.37%
- Diferencia máxima: 15.23 hectáreas
- Diferencia mínima: 3.12 hectáreas

Estos resultados indican que el filtrado tiene un impacto relativamente pequeño en la estimación global del área, lo que sugiere que la clasificación original es bastante robusta. Sin embargo, el filtrado proporciona una representación visualmente más coherente y elimina clasificaciones erróneas aisladas.

La evolución temporal del área del embalse (usando datos filtrados) muestra un patrón estacional claro:
1. **Máximos en primavera**: Tras las lluvias invernales, el embalse alcanza sus niveles más altos entre marzo y mayo.
2. **Descenso veraniego**: Durante los meses de verano (junio-septiembre), se observa una disminución progresiva debido a la evaporación y el consumo.
3. **Recuperación otoñal**: A partir de octubre, coincidiendo con el inicio de la temporada de lluvias, comienza la recuperación de niveles.

Este patrón es consistente con el ciclo hidrológico mediterráneo y las demandas de agua para abastecimiento y riego.
