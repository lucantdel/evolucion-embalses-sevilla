% ejecutar_todo.m - Script principal que ejecuta todo el flujo de procesamiento

% Configura entorno
disp('0/6 - Configurando entorno...');
run('lab1_configuracion');
lab1_configuracion();

% Genera inventario
disp('1/6 - Generando inventario de imágenes...');
run('lab1_inventario');
inventario = lab1_inventario();

% Procesa imágenes (escalado)
disp('2/6 - Procesando imágenes (escalado)...');
run('lab2_escalado');
lab2_escalado();

% Realce y composiciones en color
disp('3/6 - Generando composiciones en color...');
run('lab3_realce');
lab3_realce();

% Cálculo de índices
disp('4/6 - Calculando índices (NDWI)...');
run('lab4_transformacion');
lab4_transformacion();

% Clasificación
disp('5/6 - Clasificando imágenes...');
run('lab5_clasificacion');
lab5_clasificacion();

% Filtrado
disp('6/6 - Aplicando filtros y generando estadísticas...');
run('lab6_filtrado');
lab6_filtrado();

disp('¡Procesamiento completado! Revisa los resultados en la carpeta correspondiente.');
