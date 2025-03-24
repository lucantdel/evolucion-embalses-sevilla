% lab3_realce.m
% Funciones para generar histogramas y composiciones en color

% Función principal para procesar todas las fechas
function lab3_realce()
    % Carga rutas del proyecto
    load(fullfile(pwd, 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    
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
        fprintf('Procesando composiciones: %s (%d/%d)\n', fecha_str, i, length(inventario));
        
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
    
    % Calcula histograma (solo valores entre 1-255, ignorando 0)
    h = zeros(1, 255);
    for i = 1:255
        h(i) = sum(sum(nir == i));
    end
    
    % Crea figura
    fig = figure('Visible', 'off');
    bar(1:255, h, 'FaceColor', [0.4 0.4 0.8]);
    title('Histograma Banda NIR');
    xlabel('Nivel Digital');
    ylabel('Frecuencia');
    grid on;
    
    % Guarda figura
    saveas(fig, fullfile(ruta_destino, 'histograma_nir.png'));
    close(fig);
end

% Función para generar composición en color verdadero
function generar_true_color(ruta_origen, ruta_destino)
    % En Sentinel-2, true color es RGB = B04-B03-B02
    % Pero como solo tenemos B03, usaremos una aproximación
    verde = imread(fullfile(ruta_origen, 'verde.png'));
    
    % Para simular true-color con solo verde:
    % - Usamos verde como canal G
    % - Simulamos R como verde ligeramente más oscuro
    % - Simulamos B como verde ligeramente más claro
    rojo_sim = uint8(double(verde) * 0.9);
    azul_sim = uint8(double(verde) * 1.1);
    azul_sim(azul_sim > 255) = 255;  % Evitar desbordamiento
    
    % Crear composición RGB
    true_color = cat(3, rojo_sim, verde, azul_sim);
    
    % Guardar imagen
    imwrite(true_color, fullfile(ruta_destino, 'true_color.png'));
end

% Función para generar composición en falso color (NIR-G-B)
function generar_false_color(ruta_origen, ruta_destino)
    % Carga bandas
    nir = imread(fullfile(ruta_origen, 'nir.png'));
    verde = imread(fullfile(ruta_origen, 'verde.png'));
    
    % Para falso color NIR-G-B:
    % - NIR en canal rojo
    % - Verde en canal verde
    % - Simulamos azul como verde ajustado
    azul_sim = uint8(double(verde) * 0.8);
    
    % Crear composición
    false_color = cat(3, nir, verde, azul_sim);
    
    % Guardar imagen
    imwrite(false_color, fullfile(ruta_destino, 'false_color.png'));
end
