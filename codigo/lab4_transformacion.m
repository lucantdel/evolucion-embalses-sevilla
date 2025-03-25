% lab4_transformacion.m
% Funciones para calcular índices (especialmente NDWI)

% Función principal para calcular NDWI para todas las imágenes
function lab4_transformacion()
    % Carga rutas del proyecto
    load(fullfile(fileparts(pwd), 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    
    % Carpeta para imágenes procesadas
    ruta_procesadas = fullfile(rutas.datos, 'imagenes_procesadas');
    
    % Carpeta para resultados de índices
    ruta_indices = fullfile(rutas.resultados, 'indices');
    if ~exist(ruta_indices, 'dir')
        mkdir(ruta_indices);
    end
    
    % Procesa cada fecha
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Calculando índices: %s (%d/%d)\n', fecha_str, i, length(inventario));
        
        % Ruta de imágenes procesadas para esta fecha
        ruta_fecha = fullfile(ruta_procesadas, fecha_str);
        
        % Verifica que existan las imágenes procesadas
        if ~exist(ruta_fecha, 'dir')
            fprintf('No se encontraron imágenes procesadas para %s\n', fecha_str);
            continue;
        end
        
        % Crea carpeta para índices de esta fecha
        ruta_indices_fecha = fullfile(ruta_indices, fecha_str);
        if ~exist(ruta_indices_fecha, 'dir')
            mkdir(ruta_indices_fecha);
        end
        
        % Calcula y guarda NDWI
        calcular_ndwi(ruta_fecha, ruta_indices_fecha);
        
        % Aplica pseudocolor al NDWI para visualización
        aplicar_pseudocolor_ndwi(ruta_indices_fecha);
    end
    
    fprintf('Cálculo de índices completado.\n');
end

% Función para calcular NDWI
function calcular_ndwi(ruta_origen, ruta_destino)
    % Carga bandas (verde y NIR)
    verde = double(imread(fullfile(ruta_origen, 'verde.png')));
    nir = double(imread(fullfile(ruta_origen, 'nir.png')));
    
    % Máscara para ignorar píxeles con valor 0 (sin datos)
    mascara = (verde > 0) & (nir > 0);
    
    % Inicializa matriz para NDWI
    [filas, cols] = size(verde);
    ndwi_raw = zeros(filas, cols);
    
    % Calcula NDWI = (Verde - NIR) / (Verde + NIR)
    % Solo para píxeles con datos válidos
    for f = 1:filas
        for c = 1:cols
            if mascara(f, c)
                ndwi_raw(f, c) = (verde(f, c) - nir(f, c)) / (verde(f, c) + nir(f, c));
            end
        end
    end
    
    % Guarda NDWI en formato raw (valores entre -1 y 1)
    save(fullfile(ruta_destino, 'ndwi_raw.mat'), 'ndwi_raw', 'mascara');
    
    % Escala NDWI para visualización (1-255)
    ndwi_viz = uint8((ndwi_raw + 1) * 127.5);
    ndwi_viz(~mascara) = 0;  % Mantiene 0 en píxeles sin datos
    
    % Guarda NDWI para visualización
    imwrite(ndwi_viz, fullfile(ruta_destino, 'ndwi.png'));
end

% Función para aplicar pseudocolor al NDWI
function aplicar_pseudocolor_ndwi(ruta_indices)
    % Carga NDWI
    ndwi = imread(fullfile(ruta_indices, 'ndwi.png'));
    
    % Crea imagen en pseudocolor
    [filas, cols] = size(ndwi);
    ndwi_color = zeros(filas, cols, 3, 'uint8');
    
    % Asigna colores:
    % - Azul para agua (NDWI > 0, o valor escalado > 127)
    % - Verde para no-agua (NDWI <= 0, o valor escalado <= 127)
    for f = 1:filas
        for c = 1:cols
            if ndwi(f, c) > 0
                if ndwi(f, c) > 127
                    % Agua (azul)
                    ndwi_color(f, c, :) = [0, 0, 255];
                else
                    % No-agua (verde)
                    ndwi_color(f, c, :) = [0, 255, 0];
                end
            end
        end
    end
    
    % Guarda imagen en pseudocolor
    imwrite(ndwi_color, fullfile(ruta_indices, 'ndwi_color.png'));
end
