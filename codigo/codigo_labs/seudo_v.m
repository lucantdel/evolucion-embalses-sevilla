% Seudocolor de una banda con píxeles sin datos en verde
% (Version vectorizada modificada)

function z = seudo_v(x)

  UMBRAL = 128;

  % Crear máscaras
  mask_sin_datos = (x == 0);
  mask_datos = (x > 0);

  % Inicializar matriz de salida
  [F, C] = size(x);
  z = zeros(F, C, 3, 'uint8');

  % Asignar colores según condiciones
  z(:,:,2) = uint8(mask_sin_datos)*255;               % Verde para píxeles sin datos
  z(:,:,2) = z(:,:,2) + uint8(x >= UMBRAL & mask_datos)*255; % Verde si >= UMBRAL
  z(:,:,3) = uint8(x < UMBRAL & mask_datos)*255;      % Azul si < UMBRAL

end
