% lab6_filtrado.m
% Funciones para aplicar filtros y obtener estadísticas finales

% Función principal para filtrar clasificaciones
function lab6_filtrado()
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
    
    % Vector para almacenar áreas por fecha (filtradas)
    areas_filtradas = zeros(length(inventario), 1);
    fechas = cell(length(inventario), 1);
    
    % Procesa cada fecha
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Filtrando: %s (%d/%d)\n', fecha_str, i, length(inventario));
        
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
        
        % Aplica filtro y calcula área
        [mapa_filtrado, area_filtrada] = aplicar_filtro_mediana(ruta_clas_fecha, ruta_filt_fecha);
        
        % Guarda resultados en vectores
        areas_filtradas(i) = area_filtrada;
        fechas{i} = fecha_str;
    end
    
    % Elimina entradas sin datos
    idx_validos = areas_filtradas > 0;
    areas_filtradas = areas_filtradas(idx_validos);
    fechas = fechas(idx_validos);
    
    % Carga resultados sin filtrar para comparación
    load(fullfile(ruta_clasificacion, 'resultados_area.mat'), 'areas_agua', 'fechas');
    
    % Guarda resultados filtrados
    save(fullfile(ruta_filtrados, 'resultados_filtrados.mat'), 'areas_filtradas', 'fechas');
    
    % Genera gráfica comparativa
    generar_grafica_comparativa(areas_agua, areas_filtradas, fechas, ruta_filtrados);
    
    fprintf('Filtrado completado.\n');
end

% Función para aplicar filtro de mediana
function [mapa_filtrado, area_filtrada] = aplicar_filtro_mediana(ruta_origen, ruta_destino)
    % Carga mapa de clasificación
    mapa_clas = imread(fullfile(ruta_origen, 'clasificacion.png'));
    
    % Inicializa mapa filtrado
    [filas, cols] = size(mapa_clas);
    mapa_filtrado = mapa_clas;  % Copia inicial
    
    % Aplica filtro de mediana a píxeles no bordes
    for f = 2:filas-1
        for c = 2:cols-1
            % Si el píxel central tiene datos
            if mapa_clas(f, c) > 0
                % Extrae ventana 3x3
                ventana = mapa_clas(f-1:f+1, c-1:c+1);
                ventana = ventana(:);  % Convierte a vector
                
                % Filtra valores 0 (sin datos)
                ventana = ventana(ventana > 0);
                
                % Solo aplica mediana si hay suficientes píxeles
                if length(ventana) >= 5
                    mapa_filtrado(f, c) = median(ventana);
                end
            end
        end
    end
    
    % Calcula área de agua (en píxeles)
    num_pixeles_agua = sum(mapa_filtrado(:) == 1);
    
    % Suponiendo resolución de 10m x 10m por píxel
    area_filtrada = num_pixeles_agua * 10 * 10 / 10000;  % Área en hectáreas
    
    % Guarda mapa filtrado
    imwrite(mapa_filtrado, fullfile(ruta_destino, 'clasificacion_filtrada.png'));
    
    % Genera mapa a color
    mapa_color = generar_mapa_color(mapa_filtrado);
    imwrite(mapa_color, fullfile(ruta_destino, 'clasificacion_filtrada_color.png'));
    
    % Guarda información de área
    fid = fopen(fullfile(ruta_destino, 'area_filtrada_info.txt'), 'w');
    fprintf(fid, 'Área de agua (filtrada): %.2f hectáreas\n', area_filtrada);
    fprintf(fid, 'Número de píxeles de agua: %d\n', num_pixeles_agua);
    fclose(fid);
end

% Función para generar mapa de clasificación a color (copia de lab5)
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

% Función para generar gráfica comparativa
function generar_grafica_comparativa(areas_orig, areas_filt, fechas, ruta_destino)
    % Crea figura
    fig = figure('Visible', 'off');
    
    % Convierte fechas de string a datetime
    fechas_dt = datetime(fechas, 'InputFormat', 'yyyy-MM');
    
    % Ordena datos por fecha
    [fechas_dt, idx] = sort(fechas_dt);
    areas_orig = areas_orig(idx);
    areas_filt = areas_filt(idx);
    
    % Grafica evolución temporal comparativa
    hold on;
    plot(fechas_dt, areas_orig, '-o', 'LineWidth', 2, 'DisplayName', 'Sin filtrar');
    plot(fechas_dt, areas_filt, '-s', 'LineWidth', 2, 'DisplayName', 'Filtrado');
    hold off;
    
    grid on;
    legend('Location', 'best');
    
    % Etiquetas y título
    title('Comparación de Áreas de Agua - Con y Sin Filtrado');
    xlabel('Fecha');
    ylabel('Área (hectáreas)');
    
    % Mejora formato de ejes
    ax = gca;
    ax.XTickLabelRotation = 45;
    ax.XTickFormat = 'yyyy-MM';
    
    % Guarda gráfico
    saveas(fig, fullfile(ruta_destino, 'comparacion_filtrado.png'));
    close(fig);
    
    % Calcula estadísticas de diferencia
    diferencias = abs(areas_filt - areas_orig);
    dif_porcentual = 100 * diferencias ./ areas_orig;
    
    % Guarda estadísticas
    fid = fopen(fullfile(ruta_destino, 'estadisticas_filtrado.txt'), 'w');
    fprintf(fid, 'Estadísticas de filtrado:\n');
    fprintf(fid, '- Diferencia media: %.2f hectáreas\n', mean(diferencias));
    fprintf(fid, '- Diferencia porcentual media: %.2f%%\n', mean(dif_porcentual));
    fprintf(fid, '- Diferencia máxima: %.2f hectáreas\n', max(diferencias));
    fprintf(fid, '- Diferencia mínima: %.2f hectáreas\n', min(diferencias));
    fclose(fid);
end
