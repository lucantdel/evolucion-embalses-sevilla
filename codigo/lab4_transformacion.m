% lab4_transformacion.m - Funciones para calcular índices (especialmente NDWI)

% Función principal para calcular NDWI para todas las imágenes
function lab4_transformacion
    % Carga rutas del proyecto
    load(fullfile(pwd, 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    addpath(fullfile(pwd, 'codigo', 'codigo_labs'));
    
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
        fprintf('Calculando índices %s (%d/%d)...\n', fecha_str, i, length(inventario));
        
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
    % Carga bandas verde y NIR
    verde = imread(fullfile(ruta_origen, 'verde.png'));
    nir = imread(fullfile(ruta_origen, 'nir.png'));
    
    % Calcula NDWI utilizando la función ndwi_v de codigo_labs
    % La función ndwi_v devuelve valores entre 1-255, con 128 como el valor neutral (NDWI=0)
    ndwi_viz = ndwi_v(verde, nir);
    
    % Máscara para mantener los píxeles sin datos como 0
    mascara = (verde > 0) & (nir > 0);
    ndwi_viz(~mascara) = 0;
    
    % Guardar NDWI para visualización
    imwrite(ndwi_viz, fullfile(ruta_destino, 'ndwi.png'));
    
    % Calcular NDWI raw (valores entre -1 y 1) para análisis numérico
    % Convertir de rango [1-255] a [-1,1]
    ndwi_raw = double(ndwi_viz);
    ndwi_raw = (ndwi_raw - 128) / 127;
    ndwi_raw(~mascara) = 0;
    
    % Guardar NDWI en formato raw
    save(fullfile(ruta_destino, 'ndwi_raw.mat'), 'ndwi_raw', 'mascara');
end

% Función para aplicar pseudocolor al NDWI
function aplicar_pseudocolor_ndwi(ruta_indices)
    % Carga NDWI
    ndwi = imread(fullfile(ruta_indices, 'ndwi.png'));
    
    % Usa la función seudo_v de codigo_labs para aplicar pseudocolor
    % El umbral 128 marca el límite entre agua (NDWI>0) y no-agua (NDWI<0)
    ndwi_color = seudo_v(ndwi);
    
    % Guardar imagen en pseudocolor
    imwrite(ndwi_color, fullfile(ruta_indices, 'ndwi_color.png'));
end
