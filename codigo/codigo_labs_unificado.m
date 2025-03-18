% Archivo combinado con 38 funciones

% --- [1] amplia.m ---
% Amplia una banda

function z = amplia(x)

  [F, C] = size(x);
  x = double(x);

  z = zeros(2*F, 2*C);

  for f = 1:F
    for c = 1:C
      z(2*f-1, 2*c-1) = x(f, c);
    end
    f
  end

  for f = 2:2:2*F-1
    z(f, :) = (z(f-1, :) + z(f+1, :)) / 2;
  end

  for c = 2:2:2*C-1
    z(:, c) = (z(:, c-1) + z(:, c+1)) / 2;
  end

  z = uint8(z);

end


% --- [2] carga.m ---
% Carga una imagen

r  = imread('msi04red.png'  );
g  = imread('msi03green.png');
b  = imread('msi02blue.png' );
n  = imread('msi08nir.png'  );


% --- [3] codigo_labs.m ---
% Archivo combinado con 37 funciones

% --- [1] amplia.m ---
% Amplia una banda

function z = amplia(x)

  [F, C] = size(x);
  x = double(x);

  z = zeros(2*F, 2*C);

  for f = 1:F
    for c = 1:C
      z(2*f-1, 2*c-1) = x(f, c);
    end
    f
  end

  for f = 2:2:2*F-1
    z(f, :) = (z(f-1, :) + z(f+1, :)) / 2;
  end

  for c = 2:2:2*C-1
    z(:, c) = (z(:, c-1) + z(:, c+1)) / 2;
  end

  z = uint8(z);

end


% --- [2] carga.m ---
% Carga una imagen

r  = imread('msi04red.png'  );
g  = imread('msi03green.png');
b  = imread('msi02blue.png' );
n  = imread('msi08nir.png'  );


% --- [3] combina.m ---
% Realiza una composicion a color

function z = combina(r, g, b)

  z = r;
  z(:, :, 2) = g;
  z(:, :, 3) = b;

end


% --- [4] corte.m ---
% Corte de colas de una banda

function z = corte(x, p)

  [F, C] = size(x);

  h = histo(x);
  N = sum(h) * p;
  m = 1;
  s = h(m);
  while s < N
    m = m + 1;
    s = s + h(m);
  end
  M = 255;
  s = h(M);
  while s < N
    M = M - 1;
    s = s + h(M);
  end
  m
  M
  z = expan(x, m, M);

end


% --- [5] corte_v.m ---
% Corte de colas de una banda
% (Version vectorizada)

function z = corte_v(x, p)

  s = cumsum(histo_v(x));
  [N, m, M] = [s(255), min(find(s >= p * N)), max(find(s <= (1 - p) * N))]
  z = expan_v(x, m, M);

end


% --- [6] cortehsv.m ---
% Corte de colas en Saturacion de una imagen True-color

function z = cortehsv(x, p)

  b = 2;
  z = rgb2hsv(x);
  z = uint8(z * 255);
  z(:, :, b) = corte(z(:, :, b), p);
  z = double(z) / 255;
  z = hsv2rgb(z);
  z = uint8(z * 255);

end


% --- [7] diezma.m ---
% Diezma una banda

function z = diezma(x)

  [F, C] = size(x);
  x = double(x);

  z = x(1:2:F, 1:2:C);

  z = uint8(z);

end


% --- [8] expan.m ---
% Expansion lineal de una banda

function z = expan(x, m, M)

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      nd = x(f, c);
      if nd > 0
        ndp = ((nd - m) * 254) / (M - m) + 1;
        if ndp < 1
          ndp = 1;
        end
        if ndp > 255
          ndp = 255;
        end
        z(f, c) = ndp;
      end
    end
    f
  end

  z = uint8(z);

end


% --- [9] expan_v.m ---
% Expansion lineal de una banda
% (Version vectorizada)

function z = expan_v(x, m, M)

  b = x > 0;
  x = double(x);
  z = max(1, ((x - m) * 254) / (M - m) + 1);
  z = z .* b;
  z = uint8(z);

end


% --- [10] fmedia.m ---
% Filtro de media de una banda

function z = fmedia(x)

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 2:F-1
    for c = 2:C-1
      nd = x(f, c);
      if nd > 0
        en = x(f-1:f+1, c-1:c+1);
        ndp = sum(sum(en)) / 9;
      else
        ndp = 0;
      end
      z(f, c) = ndp;
    end
    f
  end

  z = uint8(z);

end


% --- [11] fmediana.m ---
% Filtro de mediana de una banda

function z = fmediana(x)

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 2:F-1
    for c = 2:C-1
      nd = x(f, c);
      en = x(f-1:f+1, c-1:c+1);
      en = reshape(en, 1, 9);
      ndp = median(en);
      z(f, c) = ndp;
    end
    f
  end

  z = uint8(z);

end


% --- [12] fmediana_v.m ---
% Filtro de mediana de una banda
% (Version vectorizada)

function z = fmediana_v(x)

  x = double(x);
  [F, C, B] = size(x);

  z = zeros(F, C);

  y(1, :) = reshape(x(1:F-2, 1:C-2), 1, (F-2)*(C-2));
  y(2, :) = reshape(x(1:F-2, 2:C-1), 1, (F-2)*(C-2));
  y(3, :) = reshape(x(1:F-2, 3:C  ), 1, (F-2)*(C-2));
  y(4, :) = reshape(x(2:F-1, 1:C-2), 1, (F-2)*(C-2));
  y(5, :) = reshape(x(2:F-1, 2:C-1), 1, (F-2)*(C-2));
  y(6, :) = reshape(x(2:F-1, 3:C  ), 1, (F-2)*(C-2));
  y(7, :) = reshape(x(3:F,   1:C-2), 1, (F-2)*(C-2));
  y(8, :) = reshape(x(3:F,   2:C-1), 1, (F-2)*(C-2));
  y(9, :) = reshape(x(3:F,   3:C  ), 1, (F-2)*(C-2));
  z(2:F-1, 2:C-1) = reshape(median(y), F-2, C-2);

  z = uint8(z);

end


% --- [13] histo.m ---
% Histograma de una banda

function h = histo(x)

  [F, C] = size(x);

  h = zeros(1, 255);

  for f = 1:F
    for c = 1:C
      nd = x(f, c);
      if nd > 0
        h(nd) = h(nd) + 1;
      end
    end
    f
  end

end


% --- [14] histo_v.m ---
% Histograma de una banda
% (Version vectorizada)

function h = histo_v(x)

  h = histc(reshape(x, 1, []), 1:255);

end


% --- [15] isodata.m ---
% Clasifica una imagen mediante ISODATA

function z = isodata_v(x)

  N      = 5  ; % Numero de categorias
  MAX    = 10 ; % Maximo de iteraciones
  RANDOM = 0  ; % Asignacion aleatoria de centroides (0/1)

  x = double(x);
  [F, C, B] = size(x);

  % Posicion inicial de centroides:

  if (RANDOM == 1) % Asignacion aleatoria
    display('Posicion inicial de centroides: Asignacion aleatoria');
    v = [];
    nd = zeros(1, B);
    for n = 1:N
      q = 0;
      while q == 0
        f = round(rand * F);
        c = round(rand * C);
        for b = 1:B
          nd(b) = x(f, c, b);
        end
        if min(nd) > 0
          q = 1;
        end
      end
      v = [v ; nd];
    end
  else % Asignacion centrada
    display('Posicion inicial de centroides: Asignacion centrada');
    v = [];
    for n = 1:N    
      for b = 1:B
        m = mean([min(min(x(:, :, b))), max(max(x(:, :, b)))]);
        a = min([m, 255 - m]);
        nd(1, b) = m - a / 2 + (n - 1) * a / N;
      end
      v = [v ; nd];
    end
  end

  display('Centroides iniciales:');
  v

  z = ones(F, C);

  % Clasificacion:

  Iteracion = 0;
  q = 1;
  while q == 1 && Iteracion < MAX
    Iteracion = Iteracion + 1
    q = 0;
    for f = 1:F
      for c = 1:C
        for b = 1:B
          nd(b) = x(f, c, b);
        end
        if min(nd) > 0
          v0 = z(f, c);
          d0 = sqrt(sum((nd - v(v0, :)) .^ 2));
          for n = 1:N
            d = sqrt(sum((nd - v(n, :)) .^ 2));
            if d < d0 && n ~= v0
              z(f, c) = n;
              q = 1;
            end
          end
        else
          z(f, c) = 0;
        end
      end
    end

    pintanubepuntos(Iteracion, x, v);

    if q == 1 % Si se ha reclasificado agun pixel reposicionar centroides:
      disp('Reposicionando centroides...');
      for n = 1:N
        s = zeros(1, B);
        T = 0;
        for f = 1:F
          for c = 1:C
            v0 = z(f, c);
            if v0 == n
              for b = 1:B
                nd(b) = x(f, c, b);
              end
              s = s + nd;
              T = T + 1;
            end
          end
        end
        if T > 0
          s = s ./ T;
          v(n, :) = s; % Centroide reposicionado
        end
      end
      v
    end
  end
  
  z = uint8(z);

end

function pintanubepuntos(Iteracion, x, v);
  [F, C, B] = size(x);
  x = reshape(x, F*C, 1, B);
  plot(x(:, 1, 1), x(:, 1, 2), '.y');
  grid on;
  hold on;
  plot(v(:, 1), v(:, 2), '.b', 'markersize', 20);
  title(strcat('Iteracion=', num2str(Iteracion)));
  hold off;
  pause(0.01);
end


% --- [16] isodata_v.m ---
% Clasifica una imagen mediante ISODATA
% (Version vectorizada)

function z = isodata_v2(x)

  N      = 5    ; % Numero de categorias
  MAX    = 1000 ; % Maximo de iteraciones
  RANDOM = 0    ; % Asignacion aleatoria de centroides (0/1)

  [F, C, B] = size(x);

  % Mascara de pixeles validos:

  vnd = true(F, C);
  for m = 1:B
    vnd = vnd & (x(:, :, m) > 0);
  end

  % Conversion de imagen a celdas:

  x = num2cell(double(x), [1 2]);
  
  % Posicion inicial de centroides:

  if (RANDOM == 1) % Asignacion aleatoria
    display('Posicion inicial de centroides: Asignacion aleatoria');
    v = cell(N, 1);
    for n = 1:N
      b = 0;
      while b == 0
        f = round(rand * (F - 1) + 1);
        c = round(rand * (C - 1) + 1);
        for m = 1:B
          w(m) = x{m}(f, c);
        end
        b = all(w);
      end
      v(n) = w;
    end
  else % Asignacion centrada
    display('Posicion inicial de centroides: Asignacion centrada');
    v = cell(N, 1);
    for n = 1:N    
      for b = 1:B
        m = mean([min(min(x{b}(:, :))), max(max(x{b}(:, :)))]);
        a = min([m, 255 - m]);
        w(1, b) = m - a / 2 + (n - 1) * a / N;
      end
      v(n) = w;
    end
  end

  display('Centroides iniciales:');
  celldisp(v)

  % Clasificacion:

  z = zeros(F, C);
  dmin = ones(F, C) * sqrt(255^2 * N);
  d = cell(1, N);
  Iteracion = 0;
  b = 1;
  while b == 1 && Iteracion < MAX
    display('Clasificando...');
    Iteracion = Iteracion + 1
    b = 0;
    for n = 1:N
      d{n} = zeros(F, C);
      for m = 1:B
        d{n} = d{n} + (x{m} - v{n}(m)) .^ 2;
      end
      d{n} = sqrt(d{n});
      t = (d{n} < dmin) & vnd;
      b = any(any(t));
      z(t) = n;
      dmin = min(dmin, d{n});
    end
    pintanubepuntos(Iteracion, x, v, F, C, N);
    if b == 1 % Si se ha reclasificado algun pixel reposicionar centroides:
      display('Reposicionando centroides...');
      for n = 1:N
        for m = 1:B
          v{n}(m) = mean(mean(x{m}(z == n)));
        end
      end
      display('Centroides actuales:');
      celldisp(v)
    end
  end
  display('Total iteraciones:');
  Iteracion
  display('Centroides finales:');
  celldisp(v)

  z = uint8(z);

end

function pintanubepuntos2(Iteracion, x, v, F, C, N);
  px = reshape(x{1}(:, :), F*C, 1);
  py = reshape(x{2}(:, :), F*C, 1);
  plot(px, py, '.y');
  grid on;
  hold on;
  for n = 1:N
    plot(v{n}(1), v{n}(2), '.b', 'markersize', 20);
  end
  title(strcat('Iteracion=', num2str(Iteracion)));
  hold off;
  pause(0.5);
end


% --- [17] mapa.m ---
% Genera un mapa de clasificacion a color de
% una imagen clasificada de hasta 7 categorias

function z = mapa(x)

  RGB = [  0,   0, 255  ;  % AZUL
           0, 255,   0  ;  % VERDE
         255,   0,   0  ;  % ROJO
         255, 255,   0  ;  % AMARILLO
         255,   0, 255  ;  % VIOLETA
         255, 166,   0  ;  % NARANJA
           0, 255, 255 ];  % CELESTE

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      nd = double(x(f, c));
      if nd > 0
        z(f, c, :) = RGB(nd, :);
      end
    end
    f
  end

  z = uint8(z);

end


% --- [18] mapa_v.m ---
% Genera un mapa de clasificacion a color de
% una imagen clasificada de hasta 7 categorias

function z = mapa_v(x)

  RGB = [  0,   0, 255  ;  % AZUL
           0, 255,   0  ;  % VERDE
         255,   0,   0  ;  % ROJO
         255, 255,   0  ;  % AMARILLO
         255,   0, 255  ;  % VIOLETA
         255, 166,   0  ;  % NARANJA
           0, 255, 255 ];  % CELESTE

  [F, C] = size(x);

  z = zeros(F, C, 3);

  b = x > 0;
  for n = 1:7
    v = x == n;
    w          = v * RGB(n, 1);
    w(:, :, 2) = v * RGB(n, 2);
    w(:, :, 3) = v * RGB(n, 3);
    z = z + w;
  end
  z = z .* b;

  z = uint8(z);

end


% --- [19] ndsi.m ---
% NDSI a partir de bandas G y SWIR 1.6um
% (Llevado a rango [1, 255])

function z = ndsi(x, y)

  [F, C] = size(x);
  x = double(x) / 255;
  y = double(y) / 255;

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      g = x(f, c);
      s = y(f, c);
      if g > 0 && s > 0
        ix = (g - s) / (g + s);
        ndp = (ix + 1) * 254 / 2 + 1;
        z(f, c) = ndp;
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [20] ndsi_v.m ---
% NDSI a partir de bandas G y SWIR 1.6um
% (Llevado a rango [1, 255])
% (Version vectorizada)

function z = ndsi_v(x, y)

  b = x > 0 & y > 0;
  g = double(x) / 255; % GREEN
  s = double(y) / 255; % SWIR 1.6um
  z = (g - s) ./ (g + s);
  z = (z + 1) * 254 / 2 + 1;
  z = z .* b;
  z = uint8(z);

end


% --- [21] ndvi.m ---
% NDVI a partir de bandas R y NIR
% (Llevado a rango [1, 255])

function z = ndvi(x, y)

  [F, C] = size(x);
  x = double(x) / 255; % RED
  y = double(y) / 255; % NIR

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      r = x(f, c);
      n = y(f, c);
      if r > 0 && n > 0
        ix = (n - r) / (n + r);
        ndp = (ix + 1) * 254 / 2 + 1;
        z(f, c) = ndp;
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [22] ndvi_v.m ---
% NDVI a partir de bandas R y NIR
% (Llevado a rango [1, 255])
% (Version vectorizada)

function z = ndvi_v(x, y)

  b = x > 0 & y > 0;
  r = double(x) / 255; % RED
  n = double(y) / 255; % NIR
  z = (n - r) ./ (n + r);
  z = (z + 1) * 254 / 2 + 1;
  z = z .* b;
  z = uint8(z);

end


% --- [23] ndwi.m ---
% NDWI a partir de bandas G y NIR
% (Llevado a rango [1, 255])

function z = ndwi(x, y)

  [F, C] = size(x);
  x = double(x) / 255; % G
  y = double(y) / 255; % NIR

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      g = x(f, c);
      n = y(f, c);
      if g > 0 && n > 0
        ix = (g - n) / (g + n);
        ndp = (ix + 1) * 254 / 2 + 1;
        z(f, c) = ndp;
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [24] ndwi_v.m ---
% NDWI a partir de bandas G y NIR
% (Llevado a rango [1, 255])
% (Version vectorizada)

function z = ndwi_v(x, y)

  b = x > 0 & y > 0;
  g = double(x) / 255; % G
  n = double(y) / 255; % NIR
  z = (g - n) ./ (g + n);
  z = (z + 1) * 254 / 2 + 1;
  z = z .* b;
  z = uint8(z);

end


% --- [25] no2.m ---
% Concentracion de NO2 a partir de visualizacion (Copernicus)
% (Version vectorizada)

function z = no2(x, a)

  x = double(x); % Datos
  a = a == 255;  % Alpha
  z = rgb2hsv(x / 255);
  z = abs(1 - z(:, :, 1));
  z = 128 + (z * 3 - 1) / 2 * 127;
  z = z .* a;
  z = uint8(z);

end


% --- [26] pintahisto.m ---
% Pinta un histograma

function pintahisto(h)

  bar(1:255, h);
  grid on;
  axis([1 255 0 inf]);
  title('Histograma');
  xlabel('ND');
  ylabel('h');

end


% --- [27] reduce.m ---
% Reduce una imagen

dir = 'gaza';
N = 8; % Factor de diezmado

disp('');
disp('Reduciendo imagen Sentinel-1...');
try
  vh = imread(strcat(dir, '/sar_vh.png'));
  vv = imread(strcat(dir, '/sar_vv.png'));
  [F, C] = size(vh);
  vh = vh(1:N:F, 1:N:C);
  vv = vv(1:N:F, 1:N:C);
  imwrite(vh, strcat('sar_vh.png'));
  imwrite(vv, strcat('sar_vv.png'));
  disp('OK: imagen Sentinel-1 reducida');
catch
  disp('Warning: imagen Sentinel-1 no encontrada');
end

disp('');
disp('Reduciendo imagen Sentinel-2...');
try
  br  = imread(strcat(dir, '/msi04red.png'));
  bg  = imread(strcat(dir, '/msi03green.png'));
  bb  = imread(strcat(dir, '/msi02blue.png'));
  bn  = imread(strcat(dir, '/msi08nir.png'));
  %bs1 = imread(strcat(dir, '/msi11swir1.png'));
  %bs2 = imread(strcat(dir, '/msi12swir2.png'));
  [F, C] = size(br);
  br  = br(1:N:F, 1:N:C);
  bg  = bg(1:N:F, 1:N:C);
  bb  = bb(1:N:F, 1:N:C);
  bn  = bn(1:N:F, 1:N:C);
  %bs1 = bs1(1:N:F, 1:N:C);
  %bs2 = bs2(1:N:F, 1:N:C);
  imwrite(br, strcat('msi04red.png'));
  imwrite(bg, strcat('msi03green.png'));
  imwrite(bb, strcat('msi02blue.png'));
  imwrite(bn, strcat('msi08nir.png'));
  %imwrite(bs1, strcat('msi11swir1.png'));
  %imwrite(bs2, strcat('msi12swir2.png'));
  disp('OK: imagen Sentinel-2 reducida');
catch
  disp('Warning: imagen Sentinel-2 no encontrada');
end

disp('');


% --- [28] segmenta.m ---
% Segmentacion de una banda

function z = segmenta(x)

  N = 7; % MAXIMO = 7
  MIN = 128;
  MAX = 255;
  UMBRAL = [MIN];
  for n = 1:N
    UMBRAL = [UMBRAL, MIN + (n * (MAX - MIN)) / N];
  end
  UMBRAL

  RGB = [ 64,  64,  64  ;  % GRIS OSCURO
         255,   0, 255  ;  % VIOLETA
           0,   0, 255  ;  % AZUL
           0, 255, 255  ;  % CELESTE
           0, 255,   0  ;  % VERDE
         255, 255,   0  ;  % AMARILLO
         255, 166,   0  ;  % NARANJA
         255,   0,   0 ];  % ROJO

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      nd = double(x(f, c));
      if nd > 0
        z(f, c, :) = RGB(1);
        for n = 1:N
          if nd > UMBRAL(n) && nd <= UMBRAL(n + 1)
            z(f, c, :) = RGB(n + 1, :);
          end
        end
      end
    end
    f
  end

  z = uint8(z);

end


% --- [29] segmenta_v.m ---
% Segmentacion de una banda
% (Version vectorizada)

function z = segmenta_v(x)

  N = 7; % MAXIMO = 7
  MIN = 128;
  MAX = 255;
  UMBRAL = [MIN];
  for n = 1:N
    UMBRAL = [UMBRAL, MIN + (n * (MAX - MIN)) / N];
  end
  UMBRAL

  RGB = [ 64,  64,  64  ;  % GRIS OSCURO
         255,   0, 255  ;  % VIOLETA
           0,   0, 255  ;  % AZUL
           0, 255, 255  ;  % CELESTE
           0, 255,   0  ;  % VERDE
         255, 255,   0  ;  % AMARILLO
         255, 166,   0  ;  % NARANJA
         255,   0,   0 ];  % ROJO

  b = x > 0;
  [F, C] = size(x);
  x = double(x);

  z = ones(F, C, 3) .* RGB(1);
  for n = 1:7
    v = (x > UMBRAL(n)) & (x <= UMBRAL(n + 1));
    w          = v * RGB(n + 1, 1);
    w(:, :, 2) = v * RGB(n + 1, 2);
    w(:, :, 3) = v * RGB(n + 1, 3);
    z = z + w;
  end
  z = z .* b;

  z = uint8(z);

end


% --- [30] seudo.m ---
% Seudocolor de una banda

function z = seudo(x)

  UMBRAL = 128;

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      nd = x(f, c);
      if nd > 0
        if nd < UMBRAL
          z(f, c, :) = [0 0 255];
        else
          z(f, c, :) = [0 255 0];
        end
      end
    end
    f
  end

  z = uint8(z);

end


% --- [31] seudo_v.m ---
% Seudocolor de una banda
% (Version vectorizada)

function z = seudo_v(x)

  UMBRAL = 128;

  b = x > 0;
  F = size(x, 1);
  C = size(x, 2);
  z = zeros(F, C);
  z(:, :, 2) = (x >= UMBRAL) * 255;
  z(:, :, 3) = (x <  UMBRAL) * 255;
  z = z .* b;
  z = uint8(z);

end


% --- [32] supervis.m ---
% Clasifica una imagen mediante metodo supervisado

function z = supervis(x)

  x = double(x);
  [F, C, B] = size(x);

  % Campos de entrenamiento:

  %%% Coordenadas:

  k1a = [118,  70, 170, 110];
  k1b = [113, 153, 152, 179];
  k2a = [ 51, 130,  91, 174];
  k2b = [230,  25, 283,  83];

  %%% Dimensiones:

  L1a = tamano(k1a);
  L1b = tamano(k1b);
  L2a = tamano(k2a);
  L2b = tamano(k2b);

  %%% Dibujo:

  y = cortehsv(uint8(x(:, :, 1:3)), 0.01);
  y = rectangulo(y, 2, k1a);
  y = rectangulo(y, 2, k1b);
  y = rectangulo(y, 3, k2a);
  y = rectangulo(y, 3, k2b);
  figure(1);
  imshow(y);
  imwrite(y, 'fields.png');

  %%% Calculo de centroides:

  k1 = [reshape(x(k1a(2):k1a(4), k1a(1):k1a(3), :), 1, L1a, B), reshape(x(k1b(2):k1b(4), k1b(1):k1b(3), :), 1, L1b, B)];
  k2 = [reshape(x(k2a(2):k2a(4), k2a(1):k2a(3), :), 1, L2a, B), reshape(x(k2b(2):k2b(4), k2b(1):k2b(3), :), 1, L2b, B)];
  for b = 1:B
    v1(1, 1, b) = sum(k1(:, :, b)) ./ (L1a + L1b);
    v2(1, 1, b) = sum(k2(:, :, b)) ./ (L2a + L2b);
  end
  v1
  v2

  % Clasificacion:

  z = zeros(F, C);
  for f = 1:F
    for c = 1:C
      px = x(f, c, :);
      if prod(px) > 0
        d1 = sqrt(sum(px - v1) .^ 2);
        d2 = sqrt(sum(px - v2) .^ 2);
        if d1 < d2
          z(f, c) = 1;
        else
          z(f, c) = 2;
        end
      end
    end
    f
  end

  z = uint8(z);

end

function z = rectangulo(x, b, k)
  x = double(x);
  d = 0;
  x(k(2)-d:k(4)+d, k(1)-d:k(1)+d, b) = 255;
  x(k(2)-d:k(4)+d, k(3)-d:k(3)+d, b) = 255;
  x(k(2)-d:k(2)+d, k(1)-d:k(3)+d, b) = 255;
  x(k(4)-d:k(4)+d, k(1)-d:k(3)+d, b) = 255;
  z = uint8(x);
end

function z = tamano(x)
  z = (x(3) - x(1) + 1) * (x(4) - x(2) + 1);
end



% --- [33] umbraliza.m ---
% Clasifica una banda mediante umbralizacion

function z = umbraliza(x)

  UMBRAL = [0, 154, 182, 255];

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      nd = double(x(f, c));
      if nd > 0
        ndp = 0;
        for u = 1:3
          if nd > UMBRAL(u) && nd <= UMBRAL(u + 1)
            ndp = u;
          end
        end
        z(f, c) = ndp;
      end
    end
    f
  end

  z = uint8(z);

end


% --- [34] urbanindex.m ---
% Indice urbano a partir de SAR Urbano (Copernicus)

function z = urbanindex(x, y)

  [F, C] = size(x);
  x = double(x) / 255; % VH
  y = double(y) / 255; % VV

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      vh = x(f, c);
      vv = y(f, c);
      if vh > 0 && vv > 0
        z(f, c) = 255 * (vh + vv);
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [35] urbanindex_v.m ---
% Indice urbano a partir de SAR Urbano (Copernicus)
% (Version vectorizada)

function z = urbanindex_v(x, y)

  b = x > 0 & y > 0;
  x = double(x) / 255; % VH
  y = double(y) / 255; % VV
  z = 255 * (x + y);
  z = z .* b;
  z = uint8(z);

end


% --- [36] urbano.m ---
% SAR Urbano (Copernicus)

function z = ndvi2(x, y)

  [F, C] = size(x);
  x = double(x) / 255; % VH
  y = double(y) / 255; % VV

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      vh = x(f, c);
      vv = y(f, c);
      r = 255 * double((5.5 * vh) > 0.5);
      g = 255 * vv;
      b = 255 * 8 * vh;
      z(f, c, :) = [r, g, b];
    end
    f
  end
  
  z = uint8(z);

end


% --- [37] urbano_v.m ---
% SAR Urbano (Copernicus)
% (Version vectorizada)

function z = urbano_v(x, y)

  x = double(x) / 255; % VH
  y = double(y) / 255; % VV
  z = double((5.5 * x) > 0.5);
  z(:, :, 2) = y;
  z(:, :, 3) = x * 8;
  z = z * 255;
  z = uint8(z);

end




% --- [4] combina.m ---
% Realiza una composicion a color

function z = combina(r, g, b)

  z = r;
  z(:, :, 2) = g;
  z(:, :, 3) = b;

end


% --- [5] corte.m ---
% Corte de colas de una banda

function z = corte(x, p)

  [F, C] = size(x);

  h = histo(x);
  N = sum(h) * p;
  m = 1;
  s = h(m);
  while s < N
    m = m + 1;
    s = s + h(m);
  end
  M = 255;
  s = h(M);
  while s < N
    M = M - 1;
    s = s + h(M);
  end
  m
  M
  z = expan(x, m, M);

end


% --- [6] corte_v.m ---
% Corte de colas de una banda
% (Version vectorizada)

function z = corte_v(x, p)

  s = cumsum(histo_v(x));
  [N, m, M] = [s(255), min(find(s >= p * N)), max(find(s <= (1 - p) * N))]
  z = expan_v(x, m, M);

end


% --- [7] cortehsv.m ---
% Corte de colas en Saturacion de una imagen True-color

function z = cortehsv(x, p)

  b = 2;
  z = rgb2hsv(x);
  z = uint8(z * 255);
  z(:, :, b) = corte(z(:, :, b), p);
  z = double(z) / 255;
  z = hsv2rgb(z);
  z = uint8(z * 255);

end


% --- [8] diezma.m ---
% Diezma una banda

function z = diezma(x)

  [F, C] = size(x);
  x = double(x);

  z = x(1:2:F, 1:2:C);

  z = uint8(z);

end


% --- [9] expan.m ---
% Expansion lineal de una banda

function z = expan(x, m, M)

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      nd = x(f, c);
      if nd > 0
        ndp = ((nd - m) * 254) / (M - m) + 1;
        if ndp < 1
          ndp = 1;
        end
        if ndp > 255
          ndp = 255;
        end
        z(f, c) = ndp;
      end
    end
    f
  end

  z = uint8(z);

end


% --- [10] expan_v.m ---
% Expansion lineal de una banda
% (Version vectorizada)

function z = expan_v(x, m, M)

  b = x > 0;
  x = double(x);
  z = max(1, ((x - m) * 254) / (M - m) + 1);
  z = z .* b;
  z = uint8(z);

end


% --- [11] fmedia.m ---
% Filtro de media de una banda

function z = fmedia(x)

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 2:F-1
    for c = 2:C-1
      nd = x(f, c);
      if nd > 0
        en = x(f-1:f+1, c-1:c+1);
        ndp = sum(sum(en)) / 9;
      else
        ndp = 0;
      end
      z(f, c) = ndp;
    end
    f
  end

  z = uint8(z);

end


% --- [12] fmediana.m ---
% Filtro de mediana de una banda

function z = fmediana(x)

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 2:F-1
    for c = 2:C-1
      nd = x(f, c);
      en = x(f-1:f+1, c-1:c+1);
      en = reshape(en, 1, 9);
      ndp = median(en);
      z(f, c) = ndp;
    end
    f
  end

  z = uint8(z);

end


% --- [13] fmediana_v.m ---
% Filtro de mediana de una banda
% (Version vectorizada)

function z = fmediana_v(x)

  x = double(x);
  [F, C, B] = size(x);

  z = zeros(F, C);

  y(1, :) = reshape(x(1:F-2, 1:C-2), 1, (F-2)*(C-2));
  y(2, :) = reshape(x(1:F-2, 2:C-1), 1, (F-2)*(C-2));
  y(3, :) = reshape(x(1:F-2, 3:C  ), 1, (F-2)*(C-2));
  y(4, :) = reshape(x(2:F-1, 1:C-2), 1, (F-2)*(C-2));
  y(5, :) = reshape(x(2:F-1, 2:C-1), 1, (F-2)*(C-2));
  y(6, :) = reshape(x(2:F-1, 3:C  ), 1, (F-2)*(C-2));
  y(7, :) = reshape(x(3:F,   1:C-2), 1, (F-2)*(C-2));
  y(8, :) = reshape(x(3:F,   2:C-1), 1, (F-2)*(C-2));
  y(9, :) = reshape(x(3:F,   3:C  ), 1, (F-2)*(C-2));
  z(2:F-1, 2:C-1) = reshape(median(y), F-2, C-2);

  z = uint8(z);

end


% --- [14] histo.m ---
% Histograma de una banda

function h = histo(x)

  [F, C] = size(x);

  h = zeros(1, 255);

  for f = 1:F
    for c = 1:C
      nd = x(f, c);
      if nd > 0
        h(nd) = h(nd) + 1;
      end
    end
    f
  end

end


% --- [15] histo_v.m ---
% Histograma de una banda
% (Version vectorizada)

function h = histo_v(x)

  h = histc(reshape(x, 1, []), 1:255);

end


% --- [16] isodata.m ---
% Clasifica una imagen mediante ISODATA

function z = isodata_v(x)

  N      = 5  ; % Numero de categorias
  MAX    = 10 ; % Maximo de iteraciones
  RANDOM = 0  ; % Asignacion aleatoria de centroides (0/1)

  x = double(x);
  [F, C, B] = size(x);

  % Posicion inicial de centroides:

  if (RANDOM == 1) % Asignacion aleatoria
    display('Posicion inicial de centroides: Asignacion aleatoria');
    v = [];
    nd = zeros(1, B);
    for n = 1:N
      q = 0;
      while q == 0
        f = round(rand * F);
        c = round(rand * C);
        for b = 1:B
          nd(b) = x(f, c, b);
        end
        if min(nd) > 0
          q = 1;
        end
      end
      v = [v ; nd];
    end
  else % Asignacion centrada
    display('Posicion inicial de centroides: Asignacion centrada');
    v = [];
    for n = 1:N    
      for b = 1:B
        m = mean([min(min(x(:, :, b))), max(max(x(:, :, b)))]);
        a = min([m, 255 - m]);
        nd(1, b) = m - a / 2 + (n - 1) * a / N;
      end
      v = [v ; nd];
    end
  end

  display('Centroides iniciales:');
  v

  z = ones(F, C);

  % Clasificacion:

  Iteracion = 0;
  q = 1;
  while q == 1 && Iteracion < MAX
    Iteracion = Iteracion + 1
    q = 0;
    for f = 1:F
      for c = 1:C
        for b = 1:B
          nd(b) = x(f, c, b);
        end
        if min(nd) > 0
          v0 = z(f, c);
          d0 = sqrt(sum((nd - v(v0, :)) .^ 2));
          for n = 1:N
            d = sqrt(sum((nd - v(n, :)) .^ 2));
            if d < d0 && n ~= v0
              z(f, c) = n;
              q = 1;
            end
          end
        else
          z(f, c) = 0;
        end
      end
    end

    pintanubepuntos(Iteracion, x, v);

    if q == 1 % Si se ha reclasificado agun pixel reposicionar centroides:
      disp('Reposicionando centroides...');
      for n = 1:N
        s = zeros(1, B);
        T = 0;
        for f = 1:F
          for c = 1:C
            v0 = z(f, c);
            if v0 == n
              for b = 1:B
                nd(b) = x(f, c, b);
              end
              s = s + nd;
              T = T + 1;
            end
          end
        end
        if T > 0
          s = s ./ T;
          v(n, :) = s; % Centroide reposicionado
        end
      end
      v
    end
  end
  
  z = uint8(z);

end

function pintanubepuntos(Iteracion, x, v);
  [F, C, B] = size(x);
  x = reshape(x, F*C, 1, B);
  plot(x(:, 1, 1), x(:, 1, 2), '.y');
  grid on;
  hold on;
  plot(v(:, 1), v(:, 2), '.b', 'markersize', 20);
  title(strcat('Iteracion=', num2str(Iteracion)));
  hold off;
  pause(0.01);
end


% --- [17] isodata_v.m ---
% Clasifica una imagen mediante ISODATA
% (Version vectorizada)

function z = isodata_v(x)

  N      = 5    ; % Numero de categorias
  MAX    = 1000 ; % Maximo de iteraciones
  RANDOM = 0    ; % Asignacion aleatoria de centroides (0/1)

  [F, C, B] = size(x);

  % Mascara de pixeles validos:

  vnd = true(F, C);
  for m = 1:B
    vnd = vnd & (x(:, :, m) > 0);
  end

  % Conversion de imagen a celdas:

  x = num2cell(double(x), [1 2]);
  
  % Posicion inicial de centroides:

  if (RANDOM == 1) % Asignacion aleatoria
    display('Posicion inicial de centroides: Asignacion aleatoria');
    v = cell(N, 1);
    for n = 1:N
      b = 0;
      while b == 0
        f = round(rand * (F - 1) + 1);
        c = round(rand * (C - 1) + 1);
        for m = 1:B
          w(m) = x{m}(f, c);
        end
        b = all(w);
      end
      v(n) = w;
    end
  else % Asignacion centrada
    display('Posicion inicial de centroides: Asignacion centrada');
    v = cell(N, 1);
    for n = 1:N    
      for b = 1:B
        m = mean([min(min(x{b}(:, :))), max(max(x{b}(:, :)))]);
        a = min([m, 255 - m]);
        w(1, b) = m - a / 2 + (n - 1) * a / N;
      end
      v(n) = w;
    end
  end

  display('Centroides iniciales:');
  celldisp(v)

  % Clasificacion:

  z = zeros(F, C);
  dmin = ones(F, C) * sqrt(255^2 * N);
  d = cell(1, N);
  Iteracion = 0;
  b = 1;
  while b == 1 && Iteracion < MAX
    display('Clasificando...');
    Iteracion = Iteracion + 1
    b = 0;
    for n = 1:N
      d{n} = zeros(F, C);
      for m = 1:B
        d{n} = d{n} + (x{m} - v{n}(m)) .^ 2;
      end
      d{n} = sqrt(d{n});
      t = (d{n} < dmin) & vnd;
      b = any(any(t));
      z(t) = n;
      dmin = min(dmin, d{n});
    end
    pintanubepuntos(Iteracion, x, v, F, C, N);
    if b == 1 % Si se ha reclasificado algun pixel reposicionar centroides:
      display('Reposicionando centroides...');
      for n = 1:N
        for m = 1:B
          v{n}(m) = mean(mean(x{m}(z == n)));
        endfor
      endfor
      display('Centroides actuales:');
      celldisp(v)
    endif
  endwhile
  display('Total iteraciones:');
  Iteracion
  display('Centroides finales:');
  celldisp(v)

  z = uint8(z);

end

function pintanubepuntos(Iteracion, x, v, F, C, N);
  px = reshape(x{1}(:, :), F*C, 1);
  py = reshape(x{2}(:, :), F*C, 1);
  plot(px, py, '.y');
  grid on;
  hold on;
  for n = 1:N
    plot(v{n}(1), v{n}(2), '.b', 'markersize', 20);
  end
  title(strcat('Iteracion=', num2str(Iteracion)));
  hold off;
  pause(0.5);
end


% --- [18] mapa.m ---
% Genera un mapa de clasificacion a color de
% una imagen clasificada de hasta 7 categorias

function z = mapa(x)

  RGB = [  0,   0, 255  ;  % AZUL
           0, 255,   0  ;  % VERDE
         255,   0,   0  ;  % ROJO
         255, 255,   0  ;  % AMARILLO
         255,   0, 255  ;  % VIOLETA
         255, 166,   0  ;  % NARANJA
           0, 255, 255 ];  % CELESTE

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      nd = double(x(f, c));
      if nd > 0
        z(f, c, :) = RGB(nd, :);
      end
    end
    f
  end

  z = uint8(z);

end


% --- [19] mapa_v.m ---
% Genera un mapa de clasificacion a color de
% una imagen clasificada de hasta 7 categorias

function z = mapa_v(x)

  RGB = [  0,   0, 255  ;  % AZUL
           0, 255,   0  ;  % VERDE
         255,   0,   0  ;  % ROJO
         255, 255,   0  ;  % AMARILLO
         255,   0, 255  ;  % VIOLETA
         255, 166,   0  ;  % NARANJA
           0, 255, 255 ];  % CELESTE

  [F, C] = size(x);

  z = zeros(F, C, 3);

  b = x > 0;
  for n = 1:7
    v = x == n;
    w          = v * RGB(n, 1);
    w(:, :, 2) = v * RGB(n, 2);
    w(:, :, 3) = v * RGB(n, 3);
    z = z + w;
  end
  z = z .* b;

  z = uint8(z);

end


% --- [20] ndsi.m ---
% NDSI a partir de bandas G y SWIR 1.6um
% (Llevado a rango [1, 255])

function z = ndsi(x, y)

  [F, C] = size(x);
  x = double(x) / 255;
  y = double(y) / 255;

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      g = x(f, c);
      s = y(f, c);
      if g > 0 && s > 0
        ix = (g - s) / (g + s);
        ndp = (ix + 1) * 254 / 2 + 1;
        z(f, c) = ndp;
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [21] ndsi_v.m ---
% NDSI a partir de bandas G y SWIR 1.6um
% (Llevado a rango [1, 255])
% (Version vectorizada)

function z = ndsi_v(x, y)

  b = x > 0 & y > 0;
  g = double(x) / 255; # GREEN
  s = double(y) / 255; # SWIR 1.6um
  z = (g - s) ./ (g + s);
  z = (z + 1) * 254 / 2 + 1;
  z = z .* b;
  z = uint8(z);

end


% --- [22] ndvi.m ---
% NDVI a partir de bandas R y NIR
% (Llevado a rango [1, 255])

function z = ndvi(x, y)

  [F, C] = size(x);
  x = double(x) / 255; # RED
  y = double(y) / 255; # NIR

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      r = x(f, c);
      n = y(f, c);
      if r > 0 && n > 0
        ix = (n - r) / (n + r);
        ndp = (ix + 1) * 254 / 2 + 1;
        z(f, c) = ndp;
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [23] ndvi_v.m ---
% NDVI a partir de bandas R y NIR
% (Llevado a rango [1, 255])
% (Version vectorizada)

function z = ndvi_v(x, y)

  b = x > 0 & y > 0;
  r = double(x) / 255; # RED
  n = double(y) / 255; # NIR
  z = (n - r) ./ (n + r);
  z = (z + 1) * 254 / 2 + 1;
  z = z .* b;
  z = uint8(z);

end


% --- [24] ndwi.m ---
% NDWI a partir de bandas G y NIR
% (Llevado a rango [1, 255])

function z = ndwi(x, y)

  [F, C] = size(x);
  x = double(x) / 255; # G
  y = double(y) / 255; # NIR

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      g = x(f, c);
      n = y(f, c);
      if g > 0 && n > 0
        ix = (g - n) / (g + n);
        ndp = (ix + 1) * 254 / 2 + 1;
        z(f, c) = ndp;
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [25] ndwi_v.m ---
% NDWI a partir de bandas G y NIR
% (Llevado a rango [1, 255])
% (Version vectorizada)

function z = ndwi_v(x, y)

  b = x > 0 & y > 0;
  g = double(x) / 255; # G
  n = double(y) / 255; # NIR
  z = (g - n) ./ (g + n);
  z = (z + 1) * 254 / 2 + 1;
  z = z .* b;
  z = uint8(z);

end


% --- [26] no2.m ---
% Concentracion de NO2 a partir de visualizacion (Copernicus)
% (Version vectorizada)

function z = no2(x, a)

  x = double(x); # Datos
  a = a == 255;  # Alpha
  z = rgb2hsv(x / 255);
  z = abs(1 - z(:, :, 1));
  z = 128 + (z * 3 - 1) / 2 * 127;
  z = z .* a;
  z = uint8(z);

end


% --- [27] pintahisto.m ---
% Pinta un histograma

function pintahisto(h)

  bar(1:255, h);
  grid on;
  axis([1 255 0 inf]);
  title('Histograma');
  xlabel('ND');
  ylabel('h');

end


% --- [28] reduce.m ---
% Reduce una imagen

dir = 'gaza';
N = 8; % Factor de diezmado

disp('');
disp('Reduciendo imagen Sentinel-1...');
try
  vh = imread(strcat(dir, '/sar_vh.png'));
  vv = imread(strcat(dir, '/sar_vv.png'));
  [F, C] = size(vh);
  vh = vh(1:N:F, 1:N:C);
  vv = vv(1:N:F, 1:N:C);
  imwrite(vh, strcat('sar_vh.png'));
  imwrite(vv, strcat('sar_vv.png'));
  disp('OK: imagen Sentinel-1 reducida');
catch
  disp('Warning: imagen Sentinel-1 no encontrada');
end_try_catch

disp('');
disp('Reduciendo imagen Sentinel-2...');
try
  br  = imread(strcat(dir, '/msi04red.png'));
  bg  = imread(strcat(dir, '/msi03green.png'));
  bb  = imread(strcat(dir, '/msi02blue.png'));
  bn  = imread(strcat(dir, '/msi08nir.png'));
  %bs1 = imread(strcat(dir, '/msi11swir1.png'));
  %bs2 = imread(strcat(dir, '/msi12swir2.png'));
  [F, C] = size(br);
  br  = br(1:N:F, 1:N:C);
  bg  = bg(1:N:F, 1:N:C);
  bb  = bb(1:N:F, 1:N:C);
  bn  = bn(1:N:F, 1:N:C);
  %bs1 = bs1(1:N:F, 1:N:C);
  %bs2 = bs2(1:N:F, 1:N:C);
  imwrite(br, strcat('msi04red.png'));
  imwrite(bg, strcat('msi03green.png'));
  imwrite(bb, strcat('msi02blue.png'));
  imwrite(bn, strcat('msi08nir.png'));
  %imwrite(bs1, strcat('msi11swir1.png'));
  %imwrite(bs2, strcat('msi12swir2.png'));
  disp('OK: imagen Sentinel-2 reducida');
catch
  disp('Warning: imagen Sentinel-2 no encontrada');
end_try_catch

disp('');


% --- [29] segmenta.m ---
% Segmentacion de una banda

function z = segmenta(x)

  N = 7; # MAXIMO = 7
  MIN = 128;
  MAX = 255;
  UMBRAL = [MIN];
  for n = 1:N
    UMBRAL = [UMBRAL, MIN + (n * (MAX - MIN)) / N];
  end
  UMBRAL

  RGB = [ 64,  64,  64  ;  % GRIS OSCURO
         255,   0, 255  ;  % VIOLETA
           0,   0, 255  ;  % AZUL
           0, 255, 255  ;  % CELESTE
           0, 255,   0  ;  % VERDE
         255, 255,   0  ;  % AMARILLO
         255, 166,   0  ;  % NARANJA
         255,   0,   0 ];  % ROJO

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      nd = double(x(f, c));
      if nd > 0
        z(f, c, :) = RGB(1);
        for n = 1:N
          if nd > UMBRAL(n) && nd <= UMBRAL(n + 1)
            z(f, c, :) = RGB(n + 1, :);
          end
        end
      end
    end
    f
  end

  z = uint8(z);

end


% --- [30] segmenta_v.m ---
% Segmentacion de una banda
% (Version vectorizada)

function z = segmenta_v(x)

  N = 7; # MAXIMO = 7
  MIN = 128;
  MAX = 255;
  UMBRAL = [MIN];
  for n = 1:N
    UMBRAL = [UMBRAL, MIN + (n * (MAX - MIN)) / N];
  end
  UMBRAL

  RGB = [ 64,  64,  64  ;  % GRIS OSCURO
         255,   0, 255  ;  % VIOLETA
           0,   0, 255  ;  % AZUL
           0, 255, 255  ;  % CELESTE
           0, 255,   0  ;  % VERDE
         255, 255,   0  ;  % AMARILLO
         255, 166,   0  ;  % NARANJA
         255,   0,   0 ];  % ROJO

  b = x > 0;
  [F, C] = size(x);
  x = double(x);

  z = ones(F, C, 3) .* RGB(1);
  for n = 1:7
    v = (x > UMBRAL(n)) & (x <= UMBRAL(n + 1));
    w          = v * RGB(n + 1, 1);
    w(:, :, 2) = v * RGB(n + 1, 2);
    w(:, :, 3) = v * RGB(n + 1, 3);
    z = z + w;
  end
  z = z .* b;

  z = uint8(z);

end


% --- [31] seudo.m ---
% Seudocolor de una banda

function z = seudo(x)

  UMBRAL = 128;

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      nd = x(f, c);
      if nd > 0
        if nd < UMBRAL
          z(f, c, :) = [0 0 255];
        else
          z(f, c, :) = [0 255 0];
        end
      end
    end
    f
  end

  z = uint8(z);

end


% --- [32] seudo_v.m ---
% Seudocolor de una banda
% (Version vectorizada)

function z = seudo_v(x)

  UMBRAL = 128;

  b = x > 0;
  F = size(x, 1);
  C = size(x, 2);
  z = zeros(F, C);
  z(:, :, 2) = (x >= UMBRAL) * 255;
  z(:, :, 3) = (x <  UMBRAL) * 255;
  z = z .* b;
  z = uint8(z);

end


% --- [33] supervis.m ---
% Clasifica una imagen mediante metodo supervisado

function z = supervis(x)

  x = double(x);
  [F, C, B] = size(x);

  % Campos de entrenamiento:

  %%% Coordenadas:

  k1a = [118,  70, 170, 110];
  k1b = [113, 153, 152, 179];
  k2a = [ 51, 130,  91, 174];
  k2b = [230,  25, 283,  83];

  %%% Dimensiones:

  L1a = tamano(k1a);
  L1b = tamano(k1b);
  L2a = tamano(k2a);
  L2b = tamano(k2b);

  %%% Dibujo:

  y = cortehsv(uint8(x(:, :, 1:3)), 0.01);
  y = rectangulo(y, 2, k1a);
  y = rectangulo(y, 2, k1b);
  y = rectangulo(y, 3, k2a);
  y = rectangulo(y, 3, k2b);
  figure(1);
  imshow(y);
  imwrite(y, 'fields.png');

  %%% Calculo de centroides:

  k1 = [reshape(x(k1a(2):k1a(4), k1a(1):k1a(3), :), 1, L1a, B), reshape(x(k1b(2):k1b(4), k1b(1):k1b(3), :), 1, L1b, B)];
  k2 = [reshape(x(k2a(2):k2a(4), k2a(1):k2a(3), :), 1, L2a, B), reshape(x(k2b(2):k2b(4), k2b(1):k2b(3), :), 1, L2b, B)];
  for b = 1:B
    v1(1, 1, b) = sum(k1(:, :, b)) ./ (L1a + L1b);
    v2(1, 1, b) = sum(k2(:, :, b)) ./ (L2a + L2b);
  end
  v1
  v2

  % Clasificacion:

  z = zeros(F, C);
  for f = 1:F
    for c = 1:C
      px = x(f, c, :);
      if prod(px) > 0
        d1 = sqrt(sum(px - v1) .^ 2);
        d2 = sqrt(sum(px - v2) .^ 2);
        if d1 < d2
          z(f, c) = 1;
        else
          z(f, c) = 2;
        end
      end
    end
    f
  end

  z = uint8(z);

end

function z = rectangulo(x, b, k)
  x = double(x);
  d = 0;
  x(k(2)-d:k(4)+d, k(1)-d:k(1)+d, b) = 255;
  x(k(2)-d:k(4)+d, k(3)-d:k(3)+d, b) = 255;
  x(k(2)-d:k(2)+d, k(1)-d:k(3)+d, b) = 255;
  x(k(4)-d:k(4)+d, k(1)-d:k(3)+d, b) = 255;
  z = uint8(x);
end

function z = tamano(x)
  z = (x(3) - x(1) + 1) * (x(4) - x(2) + 1);
end



% --- [34] umbraliza.m ---
% Clasifica una banda mediante umbralizacion

function z = umbraliza(x)

  UMBRAL = [0, 154, 182, 255];

  [F, C] = size(x);
  x = double(x);

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      nd = double(x(f, c));
      if nd > 0
        ndp = 0;
        for u = 1:3
          if nd > UMBRAL(u) && nd <= UMBRAL(u + 1)
            ndp = u;
          end
        end
        z(f, c) = ndp;
      end
    end
    f
  end

  z = uint8(z);

end


% --- [35] urbanindex.m ---
% Indice urbano a partir de SAR Urbano (Copernicus)

function z = urbanindex(x, y)

  [F, C] = size(x);
  x = double(x) / 255; # VH
  y = double(y) / 255; # VV

  z = zeros(F, C);

  for f = 1:F
    for c = 1:C
      vh = x(f, c);
      vv = y(f, c);
      if vh > 0 && vv > 0
        z(f, c) = 255 * (vh + vv);
      end
    end
    f
  end
  
  z = uint8(z);

end


% --- [36] urbanindex_v.m ---
% Indice urbano a partir de SAR Urbano (Copernicus)
% (Version vectorizada)

function z = urbanindex_v(x, y)

  b = x > 0 & y > 0;
  x = double(x) / 255; # VH
  y = double(y) / 255; # VV
  z = 255 * (x + y);
  z = z .* b;
  z = uint8(z);

end


% --- [37] urbano.m ---
% SAR Urbano (Copernicus)

function z = ndvi(x, y)

  [F, C] = size(x);
  x = double(x) / 255; # VH
  y = double(y) / 255; # VV

  z = zeros(F, C, 3);

  for f = 1:F
    for c = 1:C
      vh = x(f, c);
      vv = y(f, c);
      r = 255 * double((5.5 * vh) > 0.5);
      g = 255 * vv;
      b = 255 * 8 * vh;
      z(f, c, :) = [r, g, b];
    end
    f
  end
  
  z = uint8(z);

end


% --- [38] urbano_v.m ---
% SAR Urbano (Copernicus)
% (Version vectorizada)

function z = urbano_v(x, y)

  x = double(x) / 255; # VH
  y = double(y) / 255; # VV
  z = double((5.5 * x) > 0.5);
  z(:, :, 2) = y;
  z(:, :, 3) = x * 8;
  z = z * 255;
  z = uint8(z);

end


