% lab2_escalado.m - Funciones para carga, recorte y redimensionado de imágenes

% Función principal que procesa todas las imágenes del inventario
function lab2_escalado
    % Carga inventario y rutas
    load(fullfile(pwd, 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    addpath(fullfile(pwd, 'codigo', 'codigo_labs'));
    
    % Crea carpeta para imágenes procesadas si no existe
    ruta_procesadas = fullfile(rutas.datos, 'imagenes_procesadas');
    if ~exist(ruta_procesadas, 'dir')
        mkdir(ruta_procesadas);
    end
    
    % Procesa cada fecha del inventario
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Procesando %s (%d/%d)...\n', fecha_str, i, length(inventario));
        
        % Crea carpeta para esta fecha si no existe
        ruta_salida = fullfile(ruta_procesadas, fecha_str);
        if ~exist(ruta_salida, 'dir')
            mkdir(ruta_salida);
        end
        
        % Carga y procesa bandas
        cargar_y_procesar_bandas(inventario(i).ruta, ruta_salida);
    end
    
    fprintf('Procesamiento completado para todas las fechas.\n');
end

% Función para cargar y procesar bandas específicas
function cargar_y_procesar_bandas(ruta_origen, ruta_destino)
    % Definir patrones de búsqueda para cada banda
    patrones = {'B02', 'B03', 'B04', 'B08'};
    nombres_salida = {'azul.png', 'verde.png', 'rojo.png', 'nir.png'};
    
    % Procesar cada banda
    for i = 1:length(patrones)
        patron = patrones{i};
        nombre_salida = nombres_salida{i};
        
        % Buscar archivos con este patrón
        archivos = dir(fullfile(ruta_origen, ['*' patron '*.jpg']));
        if isempty(archivos)
            fprintf('Banda %s no encontrada en %s\n', patron, ruta_origen);
            continue;
        end
        
        % Cargar la primera imagen que coincida
        ruta_completa = fullfile(ruta_origen, archivos(1).name);
        img = imread(ruta_completa);
        
        % Reducir dimensiones para procesamiento más eficiente
        img_reducida = diezma(img);
        
        % Guardar imagen procesada
        imwrite(img_reducida, fullfile(ruta_destino, nombre_salida));
    end
end
