% lab2_escalado.m
% Funciones para carga, recorte y redimensionado de imágenes

% Función principal que procesa todas las imágenes del inventario
function lab2_escalado()
    % Carga inventario y rutas
    load(fullfile(fileparts(pwd), 'codigo', 'rutas_proyecto.mat'), 'rutas');
    load(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
    
    % Crea carpeta para imágenes procesadas si no existe
    ruta_procesadas = fullfile(rutas.datos, 'imagenes_procesadas');
    if ~exist(ruta_procesadas, 'dir')
        mkdir(ruta_procesadas);
    end
    
    % Procesa cada fecha del inventario
    for i = 1:length(inventario)
        fecha_str = datestr(inventario(i).fecha, 'yyyy-mm');
        fprintf('Procesando: %s (%d/%d)\n', fecha_str, i, length(inventario));
        
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
    patrones = {'B03', 'B08', 'B11', 'B12'};
    nombres_salida = {'verde.png', 'nir.png', 'swir1.png', 'swir2.png'};
    
    % Procesar cada banda
    for i = 1:length(patrones)
        patron = patrones{i};
        nombre_salida = nombres_salida{i};
        
        % Buscar archivos con este patrón
        archivos = dir(fullfile(ruta_origen, ['*' patron '*.png']));
        
        if isempty(archivos)
            fprintf('Banda %s no encontrada en %s\n', patron, ruta_origen);
            continue;
        end
        
        % Cargar la primera imagen que coincida
        ruta_completa = fullfile(ruta_origen, archivos(1).name);
        img = imread(ruta_completa);
        
        % Recortar ROI (embalse)
        img_recortada = recortar_embalse(img);
        
        % Reducir dimensiones para procesamiento más eficiente
        img_reducida = redimensionar_imagen(img_recortada);
        
        % Guardar imagen procesada
        imwrite(img_reducida, fullfile(ruta_destino, nombre_salida));
    end
end

% Función para recortar el área del embalse
function img_recortada = recortar_embalse(img)
    % Coordenadas aproximadas del embalse (ajustar según tus datos)
    % Estas coordenadas son ejemplos y deben ajustarse al embalse real
    fila_inicio = 300;
    fila_fin = 600;
    col_inicio = 450;
    col_fin = 850;
    
    % Verificar dimensiones de la imagen
    [filas, cols] = size(img);
    
    % Ajustar coordenadas si exceden los límites
    fila_fin = min(fila_fin, filas);
    col_fin = min(col_fin, cols);
    
    % Recortar imagen
    img_recortada = img(fila_inicio:fila_fin, col_inicio:col_fin);
end

% Función para reducir las dimensiones de la imagen
function img_reducida = redimensionar_imagen(img)
    % Para imágenes de 868x1599 píxeles, reducimos a aproximadamente 500x900
    % usando diezmado (conservando 1 de cada 2 píxeles)
    [filas, cols] = size(img);
    
    % Usar diezmado solo si la imagen es grande
    if filas > 500 || cols > 900
        img_reducida = img(1:2:end, 1:2:end);
    else
        img_reducida = img;
    end
end
