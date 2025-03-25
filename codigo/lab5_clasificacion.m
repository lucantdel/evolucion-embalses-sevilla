% lab5_clasificacion.m
% Funciones para clasificar imágenes basadas en NDWI

% Función principal para clasificar todas las imágenes
function lab5_clasificacion()
    % Carga rutas del proyecto
    load(fullfile(fileparts(pwd), 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    
    % Carpeta para resultados de índices
    ruta_indices = fullfile(rutas.resultados, 'indices');
    
    % Carpeta para resultados de clasificación
    ruta_clasificacion = fullfile(rutas.resultados, 'clasificacion');
    if ~exist(ruta_clasificacion, 'dir')
        mkdir(ruta_clasificacion);
    end
    
    % Vector para almacenar áreas por fecha
    areas_agua = zeros(length(inventario), 1);
    fechas = cell(length(inventario), 1);
    
    % Procesa cada fecha
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Clasificando: %s (%d/%d)\n', fecha_str, i, length(inventario));
        
        % Ruta de índices para esta fecha
        ruta_indices_fecha = fullfile(ruta_indices, fecha_str);
        
        % Verifica que exista el NDWI
        if ~exist(fullfile(ruta_indices_fecha, 'ndwi_raw.mat'), 'file')
            fprintf('No se encontró NDWI para %s\n', fecha_str);
            continue;
        end
        
        % Crea carpeta para clasificación de esta fecha
        ruta_clas_fecha = fullfile(ruta_clasificacion, fecha_str);
        if ~exist(ruta_clas_fecha, 'dir')
            mkdir(ruta_clas_fecha);
        end
        
        % Clasificación por umbralización
        [mapa_clas, area_agua] = clasificacion_umbral(ruta_indices_fecha, ruta_clas_fecha);
        
        % Guarda resultados en vectores
        areas_agua(i) = area_agua;
        fechas{i} = fecha_str;
    end
    
    % Elimina entradas sin datos
    idx_validos = areas_agua > 0;
    areas_agua = areas_agua(idx_validos);
    fechas = fechas(idx_validos);
    
    % Guarda resultados
    save(fullfile(ruta_clasificacion, 'resultados_area.mat'), 'areas_agua', 'fechas');
    
    % Genera gráfica de evolución temporal
    generar_grafica_temporal(areas_agua, fechas, ruta_clasificacion);
    
    fprintf('Clasificación completada.\n');
end

% Función para clasificación por umbralización
function [mapa_clasificacion, area_agua] = clasificacion_umbral(ruta_indices, ruta_destino)
    % Carga NDWI raw
    load(fullfile(ruta_indices, 'ndwi_raw.mat'), 'ndwi_raw', 'mascara');
    
    % Parámetros de umbralización
    umbral_agua = 0.2;  % Umbral típico para agua clara
    
    % Clasificación
    [filas, cols] = size(ndwi_raw);
    mapa_clasificacion = zeros(filas, cols, 'uint8');
    
    % Clase 1: Agua (NDWI > umbral_agua)
    % Clase 2: No-agua (0 < NDWI <= umbral_agua)
    % Clase 0: Sin datos (píxeles enmascarados)
    mapa_clasificacion(ndwi_raw > umbral_agua & mascara) = 1;
    mapa_clasificacion(ndwi_raw <= umbral_agua & mascara) = 2;
    
    % Calcula área de agua (en píxeles)
    num_pixeles_agua = sum(mapa_clasificacion(:) == 1);
    
    % Suponiendo resolución de 10m x 10m por píxel en Sentinel-2 (B03, B08)
    area_agua = num_pixeles_agua * 10 * 10 / 10000;  % Área en hectáreas
    
    % Guarda mapa de clasificación
    imwrite(mapa_clasificacion, fullfile(ruta_destino, 'clasificacion.png'));
    
    % Genera mapa de clasificación a color
    mapa_color = generar_mapa_color(mapa_clasificacion);
    imwrite(mapa_color, fullfile(ruta_destino, 'clasificacion_color.png'));
    
    % Guarda información de área
    fid = fopen(fullfile(ruta_destino, 'area_info.txt'), 'w');
    fprintf(fid, 'Área de agua: %.2f hectáreas\n', area_agua);
    fprintf(fid, 'Número de píxeles de agua: %d\n', num_pixeles_agua);
    fclose(fid);
end

% Función para generar mapa de clasificación a color
function mapa_color = generar_mapa_color(mapa_clas)
    % Mapa de colores:
    % Clase 0: Negro (sin datos)
    % Clase 1: Azul (agua)
    % Clase 2: Verde (no-agua)
    [filas, cols] = size(mapa_clas);
    mapa_color = zeros(filas, cols, 3, 'uint8');
    
    % Asigna colores
    % Azul para agua
    mapa_color(:,:,3) = (mapa_clas == 1) * 255;
    
    % Verde para no-agua
    mapa_color(:,:,2) = (mapa_clas == 2) * 255;
    
    return;
end

% Función para generar gráfica temporal
function generar_grafica_temporal(areas, fechas, ruta_destino)
    % Crea figura
    fig = figure('Visible', 'off');
    
    % Convierte fechas de string a datetime
    fechas_dt = datetime(fechas, 'InputFormat', 'yyyy-MM');
    
    % Ordena datos por fecha
    [fechas_dt, idx] = sort(fechas_dt);
    areas = areas(idx);
    
    % Grafica evolución temporal
    plot(fechas_dt, areas, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    grid on;
    
    % Etiquetas y título
    title('Evolución del Área de Agua - Embalse de Melonares');
    xlabel('Fecha');
    ylabel('Área (hectáreas)');
    
    % Mejora formato de ejes
    ax = gca;
    ax.XTickLabelRotation = 45;
    ax.XTickFormat = 'yyyy-MM';
    
    % Guarda gráfico
    saveas(fig, fullfile(ruta_destino, 'evolucion_temporal.png'));
    close(fig);
end
