% lab3_realce.m - Funciones para generar histogramas y composiciones en color

% Función principal para procesar todas las fechas
function lab3_realce
    % Carga rutas del proyecto
    load(fullfile(pwd, 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    addpath(fullfile(pwd, 'codigo', 'codigo_labs'));
    
    % Carpeta para imágenes procesadas
    ruta_procesadas = fullfile(rutas.datos, 'imagenes_procesadas');
    
    % Carpeta para resultados de realce
    ruta_realce = fullfile(rutas.resultados, 'realce');
    if ~exist(ruta_realce, 'dir')
        mkdir(ruta_realce);
    end
    
    % Procesa cada fecha
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Procesando composiciones %s (%d/%d)...\n', fecha_str, i, length(inventario));
        
        % Ruta de imágenes procesadas para esta fecha
        ruta_fecha = fullfile(ruta_procesadas, fecha_str);
        
        % Verifica que existan las imágenes procesadas
        if ~exist(ruta_fecha, 'dir')
            fprintf('No se encontraron imágenes procesadas para %s\n', fecha_str);
            continue;
        end
        
        % Crea carpeta para realce de esta fecha
        ruta_realce_fecha = fullfile(ruta_realce, fecha_str);
        if ~exist(ruta_realce_fecha, 'dir')
            mkdir(ruta_realce_fecha);
        end
        
        % Genera histograma de NIR
        generar_histograma_nir(ruta_fecha, ruta_realce_fecha);
        
        % Genera composición true-color
        generar_true_color(ruta_fecha, ruta_realce_fecha);
        
        % Genera composición false-color
        generar_false_color(ruta_fecha, ruta_realce_fecha);
    end
    
    fprintf('Procesamiento de composiciones completado.\n');
end

% Función para generar histograma de la banda NIR
function generar_histograma_nir(ruta_origen, ruta_destino)
    % Carga banda NIR
    nir = imread(fullfile(ruta_origen, 'nir.png'));
    
    % Calcula histograma usando función de codigo_labs
    h = histo_v(nir);
    
    % Crea figura
    fig = figure('Visible', 'off');
    
    % Utiliza la función pintahisto de codigo_labs
    pintahisto(h);
    
    % Guarda figura
    saveas(fig, fullfile(ruta_destino, 'histograma_nir.png'));
    close(fig);
end

% Función para generar composición en color verdadero (RGB: B04-B03-B02)
function generar_true_color(ruta_origen, ruta_destino)
    % Carga bandas RGB
    rojo = imread(fullfile(ruta_origen, 'rojo.png'));
    verde = imread(fullfile(ruta_origen, 'verde.png'));
    azul = imread(fullfile(ruta_origen, 'azul.png'));
    
    % Crear composición RGB usando función de codigo_labs
    true_color = combina(rojo, verde, azul);
    
    % Guardar imagen
    imwrite(true_color, fullfile(ruta_destino, 'true_color.png'));
end

% Función para generar composición en falso color NIR-R-G
function generar_false_color(ruta_origen, ruta_destino)
    % Carga bandas
    nir = imread(fullfile(ruta_origen, 'nir.png'));
    rojo = imread(fullfile(ruta_origen, 'rojo.png'));
    verde = imread(fullfile(ruta_origen, 'verde.png'));
    
    % Crear composición falso color NIR-R-G usando función de codigo_labs
    false_color = combina(nir, rojo, verde);
    
    % Guardar imagen
    imwrite(false_color, fullfile(ruta_destino, 'false_color.png'));
end
