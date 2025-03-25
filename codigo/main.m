% Ruta base de las imágenes
ruta_base = 'D:\TrabajoT\evolucion-embalses-sevilla\datos\imagenes_crudas\';

% Verificar si la ruta existe
if ~exist(ruta_base, 'dir')
    error(['La ruta no existe: ', ruta_base]);
end

% Obtener carpetas que comienzan con '202'
carpetas = dir(fullfile(ruta_base, '202*'));

% Verificar si se encontraron carpetas
if isempty(carpetas)
    error('No se encontraron carpetas con imágenes');
end

% Inicializar arreglos
num_fechas = length(carpetas);
porcentajes_agua = zeros(1, num_fechas);
porcentajes_agua_mndwi = zeros(1, num_fechas);
fechas = datetime.empty(num_fechas, 0);

for k = 1:num_fechas
    nombre_fecha = carpetas(k).name;
    ruta_fecha = fullfile(ruta_base, nombre_fecha);
    
    % Leer bandas
    verde = double(imread(fullfile(ruta_fecha, dir(fullfile(ruta_fecha, '*B03*.jpg')).name)));
    nir = double(imread(fullfile(ruta_fecha, dir(fullfile(ruta_fecha, '*B08*.jpg')).name)));
    swir1 = double(imread(fullfile(ruta_fecha, dir(fullfile(ruta_fecha, '*B11*.jpg')).name)));
    swir2 = double(imread(fullfile(ruta_fecha, dir(fullfile(ruta_fecha, '*B12*.jpg')).name)));
    
    % NDWI clásico
    ndwi = (verde - nir) ./ (verde + nir);
    agua_ndwi = ndwi > 0.2;

    % MNDWI
    mndwi = (verde - swir1) ./ (verde + swir1);
    agua_mndwi = mndwi > 0.2;
    
    % Porcentaje de agua
    porcentajes_agua(k) = sum(agua_ndwi(:)==1) / numel(agua_ndwi) * 100;
    porcentajes_agua_mndwi(k) = sum(agua_mndwi(:)==1) / numel(agua_mndwi) * 100;

    % Fecha
    fechas(k) = datetime(nombre_fecha, 'InputFormat', 'yyyy-MM');

    % Información
    fprintf('Fecha: %s - Agua (NDWI): %.2f%% - Agua (MNDWI): %.2f%%\n', nombre_fecha, porcentajes_agua(k), porcentajes_agua_mndwi(k));
end

% Ordenar cronológicamente
[fechas, orden] = sort(fechas);
porcentajes_agua = porcentajes_agua(orden);
porcentajes_agua_mndwi = porcentajes_agua_mndwi(orden);

% Graficar
figure;
plot(fechas, porcentajes_agua, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'b'); hold on;
plot(fechas, porcentajes_agua_mndwi, '-s', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'g');

xlabel('Fecha', 'FontSize', 12);
ylabel('Porcentaje de superficie cubierta por agua (%)', 'FontSize', 12);
title('Evolución temporal del área cubierta por agua (NDWI vs MNDWI)', 'FontSize', 14);
legend('NDWI (B03,B08)','MNDWI (B03,B11)','Location','best');
grid on;

% Formato del eje X
ax = gca;
ax.XTickLabelRotation = 45;
datetick(ax, 'x', 'mmm yyyy', 'keepticks');
