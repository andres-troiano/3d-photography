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

% clear variables
% set(0,'DefaultFigureVisible', 'off');
% path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';
% 
% load([path_calibracion 'intersections.mat']);
% load([path_calibracion 'rectas.mat']);
% load([path_calibracion 'calibration.mat']);
% 
% r = 59.975/2;
% 
% close all
% % coordenadas del centro del hexágono
% centros = {[], []};
% % acá guardo la pendiente de la cara izq, a la cual le resto 60º. Para ver
% % qué dispersión tienen mis resultados, dado que el ángulo y el radio que
% % uso son ctes.
% pendientes = {[], []};
% for q = 2%:2
%     
%     load([path_calibracion 'camara_' num2str(q) '.mat']);
%     
%     ind1=C{q}(:,6)>.4;
%     ind2=C{q}(:,8)>.4;
%     ind3=C{q}(:,7)<100;
%     ind4=C{q}(:,9)<100;
% 
%     ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
%     
%     indices = 1:numel(ind1);
%     indices = indices(ind1); % estos son los indices donde hay perfiles válidos
%     N = numel(indices);
%     
%     centro_individual = nan(N, 4);
%     pendiente_individual = nan(N, 1);
%     
%     for i = 1:N
%         fprintf('C%d - Paso %d de %d\n', q, i, N)
%         n = indices(i);
%         
%         pxe = C{q}(n,1);
%         pye = C{q}(n,2);
%         
%         px_recta = linspace(pxe-50, pxe)'; % tomo puntos en un entorno de la esquina
%         py_recta = polyval(R{q}(n,1:2), px_recta); % me conviene usar la recta izquierda
%         % porque la derecha es casi vertical en la cámara 1, con lo cual su
%         % pendiente diverge
%         
%         % grafico el perfil
%         py = 1088-(Profiles(:,n));
%         px = (1:numel(py))';
%         
%         % convierto
%         x = polyval4XY(px2mmPol{q}(1), px, py);
%         y = polyval4XY(px2mmPol{q}(2), px, py);
%         x_recta = polyval4XY(px2mmPol{q}(1), px_recta, py_recta);
%         y_recta = polyval4XY(px2mmPol{q}(2), px_recta, py_recta);
%         xe = polyval4XY(px2mmPol{q}(1), pxe, pye);
%         ye = polyval4XY(px2mmPol{q}(2), pxe, pye);
%         
% %         t = (max(y_recta) - min(y_recta))/(max(x_recta) - min(x_recta)); % esto da siempre positivo para cualquier ángulo
%         t=(y_recta(end) - y_recta(1))/(x_recta(end) - x_recta(1));
%         a = tand(atand(t)-60); % le sumo 60º a la pendiente (por la orientación
%         % que tiene el perfil es una resta)
%         b = ye - a*xe;
%         y_recta2 = polyval([a b], x_recta);
%         
%         % me muevo por esta dirección el radio
%         offset_x = r*cos(atan(a));
%         offset_y = r*sin(atan(a));
%         
%         centro_x = xe-offset_x;
%         centro_y = ye-offset_y;
%         
%         close all, f=figure(3); hold on, grid on
%         
%         plot(x, y, '.-b')
%         plot(x_recta,y_recta, '.r')
%         plot(xe,ye,'*r')        
% %         plot(x_recta,y_recta2,'.g')
%         plot(centro_x, centro_y, '*m')
%         
%         axis equal
%         title(sprintf('C%dX%dY%d', q, X(n), Y(n)))
%         margen=45;
%         xlim([xe-margen, xe+margen])
%         ylim([ye-margen, ye+margen])
%         saveas(f, [path_calibracion 'graficos_centros\camara_' num2str(q) '\C' num2str(q) 'X' num2str(X(n)) 'Y' num2str(Y(n)) '.png'])
%         
%         centro_individual(i,:) = [X(n), Y(n), centro_x, centro_y];
%         pendiente_individual(i) = t;
%     end
%     centros{q} = centro_individual;
%     pendientes{q} = pendiente_individual;
% end
% % save(fullfile(path_calibracion, 'centros'),'centros');
% % save(fullfile(path_calibracion, 'pendientes'),'pendientes');
% set(0,'DefaultFigureVisible', 'on');

%%

% hasta acá le estoy asignando la misma estiqueta a esquinas que en cada
% cámara son distintas. El promedio del offset entre los centros calculados
% con una cámara y otra es la traslación que le tengo que aplicar a una de
% las 2 cámaras. Igual me va a quedar una dispersión.

clear variables
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';
load([path_calibracion 'centros.mat']);

% para cuantificar el error entre los centros hay que encontrar los x,y
% para los que hubo detección en ambas cámaras

x_comunes = intersect(centros{1}(:,1), centros{2}(:,1));
y_comunes = intersect(centros{1}(:,2), centros{2}(:,2));

error = nan(numel(x_comunes)*numel(y_comunes), 4); % x, y, error_x, error_y
k=0;
for i = 1:numel(x_comunes)
    for j = 1:numel(y_comunes)
        N=nan(2,1); % indices que busco en cada camara
        k=k+1;
        for q = 1:2
            ind_x = centros{q}(:,1) == x_comunes(i);
            ind_y = centros{q}(:,2) == y_comunes(j);
            ind_comun = ind_x & ind_y;
            n=find(ind_comun);
            if numel(n)==0
                continue
            end
            N(q) = n;
        end
        if any(isnan(N))
            continue
        end
        error(k,:) = [x_comunes(i), y_comunes(j), centros{1}(N(1),3)-centros{2}(N(2),3), centros{1}(N(1),4)-centros{2}(N(2),4)];
    end
end

% hay que tirar los nan antes de promediar
ind = ~isnan(error(:,1));

% offset_x, offset_y, error_offset_x, error_offset_y
% le pongo un - adelante para que tenga el mismo signo que el offset del
% trapecio
offset_hexagono = [-mean(error(ind,3)), -mean(error(ind,4)), std(error(ind,3)), std(error(ind,4))];

save(fullfile(path_calibracion, 'offset_hexagono'),'offset_hexagono');

close all
f1=figure; hold on, grid on
plot3(error(:,1), error(:,2), error(:,3) + offset_hexagono(1),'.')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Error en offset X (mm)')
view(28,26)
saveas(f1, [path_calibracion 'graficos_centros\offset_en_X.png'])

f2=figure; hold on, grid on
plot3(error(:,1), error(:,2), error(:,4) + offset_hexagono(2),'.')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Error en offset Y (mm)')
view(30,24)
saveas(f2, [path_calibracion 'graficos_centros\offset_en_Y.png'])

fprintf('Std del offset en X: %.3f mm\nStd del offset en Y: %.3f mm\n', offset_hexagono(3), offset_hexagono(4))

%% genero las FC
fronteraZonaEfectiva(path_calibracion);

%% genero la F
% ejecuto "fronteras_region_valida_con_hexagono"

%% mido cilindros

clear variables, clc

% para trabajar con datos nuevos:
path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';

load([path_calibracion 'calibration.mat']);
load([path_calibracion 'offset_hexagono.mat']);
% load([path_calibracion 'fronteras.mat']);
load([path_calibracion 'FC.mat']);

frame_cilindro = {'patron_34700530', 'patron_34700630', 'patron_34700730'};
id_cilindro = {'34700530', '34700630', '34700730'};
nominales = [139.707, 168.310, 177.805];

frames_cilindro = {[], []};

for f = 1:3
    close all
    for q = 1:2
        % ojo: le estoy pasando 2 veces FC, porque quiero medir antes de
        % calcular el +-35
        frames_cilindro{q} = [path_datos frame_cilindro{f} '_camara_' num2str(q) '.png'];
    end
    [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron(frames_cilindro, id_cilindro{f}, px2mmPol, offset_hexagono, FC, FC, path_datos); % con las fronteras en el offset
    fprintf([id_cilindro{f} '\nError 2 cámaras: %.3f mm\nError C1: %.3f mm, Error C2: %.3f mm\nCentro global: (%.3f, %.3f)\nCentro C1: (%.3f, %.3f)\nCentro C2: (%.3f, %.3f)\n\n'], 2*r_teorico - nominales(f), 2*r_individual(1) - nominales(f), 2*r_individual(2) - nominales(f), centro_x, centro_y, centro_individual{1}(1), centro_individual{1}(2), centro_individual{2}(1), centro_individual{2}(2))
end
