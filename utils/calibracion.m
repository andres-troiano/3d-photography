% script para hacer una calibración, tomando como input los datos generados
% por el script "medicion.m" de la carpeta "barrido"

% clear variables
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion39\';

% clasifico los datos, eliminando aquellas capturas en las que no se vio
% nada
creo_directorios_2_camaras(path_calibracion);
separar_frames_utiles(path_calibracion, 1);
separar_frames_utiles(path_calibracion, 2);
% acá estaría bueno eliminar los archivos originales, para no tenerlos
% duplicados
convertFiles2DotMatPath(path_calibracion);

%%

% encuentro la posición de las esquinas del patrón
calculateIntersectionsPath(path_calibracion);
load([path_calibracion 'intersections.mat']);
% teniendo las coordenadas de cada esquina en mm y en pixels, calibro el
% sistema
calculateCalibration(C, path_calibracion);

%% 

% posterior a haber calibrado (con el trapecio) hay que hacer un nuevo 
% barrido con el trapecio puesto horizontal, para determinar la distancia
% que hay entre las dos esquinas del trapecio (le voy a aplicar ese offset 
% a la cámara 2)

% hecho el 2do barrido para calcular el offset, encuentro las esquinas

path_offset = 'C:\Users\60069978\Documents\MATLAB\medicion40\';

creo_directorios_2_camaras(path_offset);
separar_frames_utiles(path_offset, 1);
separar_frames_utiles(path_offset, 2);
convertFiles2DotMatPath(path_offset);

% acá hay que señalar: para la cam1, la esquina izquierda, y para la cam2
% la derecha
calculateIntersectionsPath(path_offset);

% ahora a partir de los datos tengo que calcular el offset
offset = calculo_offset(path_datos, path_calibracion);