% script para hacer una calibración con el HEXÁGONO

% clear variables
% path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';

%%

% % clasifico los datos, eliminando aquellas capturas en las que no se vio
% % nada
% creo_directorios_2_camaras(path_calibracion);
% separar_frames_utiles(path_calibracion, 1);
% separar_frames_utiles(path_calibracion, 2);
% % acá estaría bueno eliminar los archivos originales, para no tenerlos
% % duplicados
% convertFiles2DotMatPath(path_calibracion);

%%

% encuentro la posición de las esquinas del patrón
% calculateIntersections_hexagono(path_calibracion);
% load([path_calibracion 'intersections.mat']);
% % teniendo las coordenadas de cada esquina en mm y en pixels, calibro el
% % sistema
% calculateCalibration(C, path_calibracion);

%% 

% teniendo una primera calibración hay que:
% * usar el offset conocido del hexágono, pasando por el centro
% * calcular las fronteras propias de esta calibración
% * calibrar una segunda vez sólo en la zona de interés
% * medir los patrones

% 1er paso: calcular los ángulos. Para esto tengo rectas.mat, generado por
% calculateIntersections_hexagono
% ahora puedo cargar los x,y de las esquinas, más las rectas y así calcular
% xc,yc para cada punto.
% Para empezar no voy a calcular el ángulo, voy a usar el teórico (120).
% Para eso voy a usar sólo L1 y le sumo 60º

clear variables

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';

load([path_calibracion 'intersections.mat']);
load([path_calibracion 'rectas.mat']);
load([path_calibracion 'calibration.mat']);

r = 59.975/2;

close all
% coordenadas del centro del hexágono
centros = {[], []};
% acá guardo la pendiente de la cara izq, a la cual le resto 60º. Para ver
% qué dispersión tienen mis resultados, dado que el ángulo y el radio que
% uso son ctes.
pendientes = {[], []};
for q = 1%:2
    
    load([path_calibracion 'camara_' num2str(q) '.mat']);
    
    ind1=C{q}(:,6)>.4;
    ind2=C{q}(:,8)>.4;
    ind3=C{q}(:,7)<100;
    ind4=C{q}(:,9)<100;

    ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
    
    indices = 1:numel(ind1);
    indices = indices(ind1); % estos son los indices donde hay perfiles válidos
    N = numel(indices);
    
    centro_individual = nan(N, 4);
    pendiente_individual = nan(N, 1);
    
    for i = 1%:N
        fprintf('C%d - Paso %d de %d\n', q, i, N)
        n = indices(i);
        
        pxe = C{q}(n,1);
        pye = C{q}(n,2);
        
        px_recta = linspace(pxe-50, pxe)'; % tomo puntos en un entorno de la esquina
        py_recta = polyval(R{q}(n,1:2), px_recta); % me conviene usar la recta izquierda
        % porque la derecha es casi vertical en la cámara 1, con lo cual su
        % pendiente diverge
        
        % grafico el perfil
        py = 1088-(Profiles(:,n));
        px = (1:numel(py))';
        
        % convierto
        x = polyval4XY(px2mmPol{q}(1), px, py);
        y = polyval4XY(px2mmPol{q}(2), px, py);
        x_recta = polyval4XY(px2mmPol{q}(1), px_recta, py_recta);
        y_recta = polyval4XY(px2mmPol{q}(2), px_recta, py_recta);
        xe = polyval4XY(px2mmPol{q}(1), pxe, pye);
        ye = polyval4XY(px2mmPol{q}(2), pxe, pye);
        
%         t = (max(y_recta) - min(y_recta))/(max(x_recta) - min(x_recta)); % esto da siempre positivo para cualquier ángulo
        t=(y_recta(end) - y_recta(1))/(x_recta(end) - x_recta(1));
        a = tand(atand(t)-60); % le sumo 60º a la pendiente (por la orientación
        % que tiene el perfil es una resta)
        b = ye - a*xe;
        y_recta2 = polyval([a b], x_recta);
        
        % me muevo por esta dirección el radio
        offset_x = r*cos(atan(a));
        offset_y = r*sin(atan(a));
        
        centro_x = xe-offset_x;
        centro_y = ye-offset_y;
        
        close all, figure(3), hold on, grid on
        
        plot(x, y, '.-b')
        plot(x_recta,y_recta, '.r')
        plot(xe,ye,'*r')        
%         plot(x_recta,y_recta2,'.g')
        plot(centro_x, centro_y, '*m')
        
        axis equal
        title(sprintf('C%dX%dY%d', q, X(n), Y(n)))
        
        centro_individual(i,:) = [X(n), Y(n), centro_x, centro_y];
        pendiente_individual(i) = t;
    end
    centros{q} = centro_individual;
    pendientes{q} = pendiente_individual;
end
% save(fullfile(path_calibracion, 'centros'),'centros');
% save(fullfile(path_calibracion, 'pendientes'),'pendientes');

%%

% veo cómo es la distribución de centros

clear variables
r = 59.975/2;
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';
load([path_calibracion 'pendientes.mat']);

for q = 1:2
    fprintf('Pendiente C%d = %.3fº +- %.3fº\n', q, atand(mean(pendientes{q})), atand(std(pendientes{q})))
end

% esto no me dice nada, porque son pendientes de caras distintas