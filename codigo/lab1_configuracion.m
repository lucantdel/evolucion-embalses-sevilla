% lab1_configuracion.m - Configura las rutas y verifica el entorno de trabajo

% Definir rutas principales del proyecto
function lab1_configuracion()
    % Detecta la ruta base del proyecto (directorio superior a pwd)
    ruta_base = pwd;
    
    % Define rutas para datos, código y resultados
    rutas.datos = fullfile(ruta_base, 'datos');
    rutas.imagenes = fullfile(rutas.datos, 'imagenes_crudas');
    rutas.codigo = fullfile(ruta_base, 'codigo');
    rutas.resultados = fullfile(ruta_base, 'resultados');
    
    % Crea carpetas si no existen
    if ~exist(rutas.resultados, 'dir')
        mkdir(rutas.resultados);
        fprintf('Carpeta de resultados creada en: %s\n', rutas.resultados);
    end
    
    % Guarda estructura de rutas para uso posterior
    save(fullfile(rutas.codigo, 'rutas_proyecto.mat'), 'rutas');
    
    fprintf('Configuración completada. Rutas guardadas en rutas_proyecto.mat\n');
end
