% lab6_filtrado.m - Funciones para aplicar filtros y obtener estadísticas finales (versión corregida)

% Función principal para filtrar clasificaciones
function lab6_filtrado
    % Carga rutas del proyecto
    load(fullfile(pwd, 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    
    % Carpeta para resultados de clasificación
    ruta_clasificacion = fullfile(rutas.resultados, 'clasificacion');
    
    % Carpeta para resultados filtrados
    ruta_filtrados = fullfile(rutas.resultados, 'filtrados');
    if ~exist(ruta_filtrados, 'dir')
        mkdir(ruta_filtrados);
    end
    
    % Vector para almacenar áreas por fecha filtradas (en hectáreas)
    areas_filtradas = zeros(length(inventario), 1);
    fechas = cell(length(inventario), 1);
    
    % Procesa cada fecha
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Filtrando %s (%d/%d)...\n', fecha_str, i, length(inventario));
        
        % Ruta de clasificación para esta fecha
        ruta_clas_fecha = fullfile(ruta_clasificacion, fecha_str);
        
        % Verifica que exista la clasificación
        if ~exist(fullfile(ruta_clas_fecha, 'clasificacion.png'), 'file')
            fprintf('No se encontró clasificación para %s\n', fecha_str);
            continue;
        end
        
        % Crea carpeta para filtrados de esta fecha
        ruta_filt_fecha = fullfile(ruta_filtrados, fecha_str);
        if ~exist(ruta_filt_fecha, 'dir')
            mkdir(ruta_filt_fecha);
        end
        
        % Aplica filtro y calcula área en HECTÁREAS
        [mapa_filtrado, area_filtrada] = aplicar_filtro_mediana(ruta_clas_fecha, ruta_filt_fecha);
        
        % Guarda resultados
        areas_filtradas(i) = area_filtrada;
        fechas{i} = fecha_str;
    end
    
    % Elimina entradas sin datos
    idx_validos = areas_filtradas > 0;
    areas_filtradas = areas_filtradas(idx_validos);
    fechas = fechas(idx_validos);
    
    % Carga resultados sin filtrar (en hectáreas)
    load(fullfile(ruta_clasificacion, 'resultados_area.mat'), 'areas_agua', 'fechas');
    
    % Guarda resultados filtrados
    save(fullfile(ruta_filtrados, 'resultados_filtrados.mat'), 'areas_filtradas', 'fechas');
    
    % Genera gráfica comparativa
    generar_grafica_comparativa(areas_agua, areas_filtradas, fechas, ruta_filtrados);
    
    fprintf('Filtrado completado.\n');
end

% Función para aplicar filtro de mediana (CORREGIDA)
function [mapa_filtrado, area_filtrada] = aplicar_filtro_mediana(ruta_origen, ruta_destino)
    % Carga mapa de clasificación
    mapa_clas = imread(fullfile(ruta_origen, 'clasificacion.png'));
    
    % Aplica filtro de mediana
    mapa_filtrado = fmediana(mapa_clas);
    
    % Calcula área de agua en píxeles
    num_pixeles_agua = sum(mapa_filtrado == 1, 'all');
    
    % Calcula el área total en píxeles
    [filas, columnas] = size(mapa_filtrado);
    numpixelestotal = filas * columnas;
    
    % Calcula área por píxel en HECTÁREAS (86.68 km² = 8668 hectáreas)
    area_por_pixel = 86.68 * 100 / numpixelestotal;
    
    % Calcula área filtrada en HECTÁREAS
    area_filtrada = num_pixeles_agua * area_por_pixel;
    
    % Guarda mapa filtrado
    imwrite(mapa_filtrado, fullfile(ruta_destino, 'clasificacion_filtrada.png'));
    
    % Genera mapa a color
    mapa_color = generar_mapa_color(mapa_filtrado);
    imwrite(mapa_color, fullfile(ruta_destino, 'clasificacion_filtrada_color.png'));
    
    % Guarda información de área (actualizado a hectáreas)
    fid = fopen(fullfile(ruta_destino, 'area_filtrada_info.txt'), 'w');
    fprintf(fid, 'Área de agua filtrada: %.4f hectáreas\n', area_filtrada);
    fprintf(fid, 'Número de píxeles de agua: %d\n', num_pixeles_agua);
    fprintf(fid, 'Área por píxel: %.4f ha / %.8f km²\n', area_por_pixel, area_por_pixel/100);
    fclose(fid);
end

% Función para generar gráfica comparativa (CORREGIDA)
function generar_grafica_comparativa(areas_orig, areas_filt, fechas, ruta_destino)
    % Crea figura
    fig = figure('Visible', 'off');
    
    % Convierte fechas a datetime
    fechas_dt = datetime(fechas, 'InputFormat', 'yyyy-MM');
    
    % Asegura misma longitud de arrays
    n = min([length(fechas_dt), length(areas_orig), length(areas_filt)]);
    fechas_dt = fechas_dt(1:n);
    areas_orig = areas_orig(1:n);
    areas_filt = areas_filt(1:n);
    
    % Ordena por fecha
    [fechas_dt, idx] = sort(fechas_dt);
    areas_orig = areas_orig(idx);
    areas_filt = areas_filt(idx);
    
    % Grafica comparativa
    hold on;
    plot(fechas_dt, areas_orig, '-o', 'LineWidth', 2, 'DisplayName', 'Sin filtrar');
    plot(fechas_dt, areas_filt, '-s', 'LineWidth', 2, 'DisplayName', 'Filtrado');
    hold off;
    
    % Configuración de ejes
    grid on;
    legend('Location', 'best');
    title('Comparación de Áreas de Agua - Con y Sin Filtrado');
    xlabel('Fecha');
    ylabel('Área (hectáreas)');
    ax = gca;
    ax.XTickLabelRotation = 45;
    datetick('x', 'yyyy-mm', 'keepticks');
    
    % Guarda gráfico
    saveas(fig, fullfile(ruta_destino, 'comparacion_filtrado.png'));
    close(fig);
    
    % Estadísticas de diferencia (en hectáreas)
    diferencias = abs(areas_filt - areas_orig);
    dif_porcentual = 100 * diferencias ./ areas_orig;
    
    fid = fopen(fullfile(ruta_destino, 'estadisticas_filtrado.txt'), 'w');
    fprintf(fid, 'Estadísticas de filtrado:\n');
    fprintf(fid, '- Diferencia media: %.2f hectáreas\n', mean(diferencias));
    fprintf(fid, '- Diferencia porcentual media: %.2f%%\n', mean(dif_porcentual));
    fprintf(fid, '- Diferencia máxima: %.2f hectáreas\n', max(diferencias));
    fprintf(fid, '- Diferencia mínima: %.2f hectáreas\n', min(diferencias));
    fclose(fid);
end

% Función para mapa de colores (sin cambios)
function mapa_color = generar_mapa_color(mapa_clas)
    [filas, cols] = size(mapa_clas);
    mapa_color = zeros(filas, cols, 3, 'uint8');
    mapa_color(:,:,3) = (mapa_clas == 1) * 255; % Azul para agua
    mapa_color(:,:,2) = (mapa_clas == 2) * 255; % Verde para no-agua
end
