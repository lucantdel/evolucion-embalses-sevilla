% lab1_inventario.m
% Genera un inventario de las imágenes disponibles

function inventario = lab1_inventario()
    % Carga rutas del proyecto
    load(fullfile(pwd, 'codigo', 'rutas_proyecto.mat'), 'rutas');
    
    % Lista todas las carpetas de fechas
    carpetas_fechas = dir(fullfile(rutas.imagenes, '20*'));
    carpetas_fechas = carpetas_fechas([carpetas_fechas.isdir]);
    
    % Inicializa estructura para almacenar el inventario
    inventario = struct('fecha', {}, 'bandas', {}, 'ruta', {});
    
    % Recorre cada carpeta de fecha
    for i = 1:length(carpetas_fechas)
        fecha_str = carpetas_fechas(i).name;
        ruta_fecha = fullfile(rutas.imagenes, fecha_str);
        
        % Lista archivos en la carpeta
        archivos = dir(fullfile(ruta_fecha, '*'));
        archivos = {archivos(~[archivos.isdir]).name};
        
        % Identifica bandas disponibles
        bandas_disponibles = {};
        if any(contains(archivos, 'B03'))
            bandas_disponibles{end+1} = 'B03';
        end
        if any(contains(archivos, 'B08'))
            bandas_disponibles{end+1} = 'B08';
        end
        if any(contains(archivos, 'B11'))
            bandas_disponibles{end+1} = 'B11';
        end
        if any(contains(archivos, 'B12'))
            bandas_disponibles{end+1} = 'B12';
        end
        
        % Solo agrega al inventario si existen las bandas necesarias para NDWI (B03 y B08)
        if ismember('B03', bandas_disponibles) && ismember('B08', bandas_disponibles)
            entrada = struct();
            entrada.fecha = datetime(fecha_str, 'InputFormat', 'yyyy-MM');
            entrada.bandas = bandas_disponibles;
            entrada.ruta = ruta_fecha;
            
            inventario(end+1) = entrada;
        end
    end
    
    % Ordena por fecha
    [~, idx] = sort([inventario.fecha]);
    inventario = inventario(idx);
    
    % Muestra resumen
    fprintf('Inventario completado:\n');
    fprintf('- Total de fechas disponibles: %d\n', length(inventario));
    fprintf('- Rango de fechas: %s a %s\n', ...
        datestr(inventario(1).fecha, 'mmm yyyy'), ...
        datestr(inventario(end).fecha, 'mmm yyyy'));
    
    % Guarda inventario
    save(fullfile(rutas.codigo, 'inventario_imagenes.mat'), 'inventario');
end
