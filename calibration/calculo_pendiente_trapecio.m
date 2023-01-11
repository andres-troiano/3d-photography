clear variables

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

% necesito las rectas, como las guardé en la calibración del hexágono.
% Le agrego esa funcionalidad a calculateIntersectionsPath

load([path_datos 'intersections.mat']);
load([path_datos 'rectas.mat']);
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras.mat']);

filename = {'camara_1.mat', 'camara_2.mat'};

% para qué lado tomo el 2do punto para armar la recta
margen = [-50, -50];
idx = {[1,2], [1,2]}; % estos son los índices de los parámetros de la recta
% necesito en cada caso

PP={[],[]};
XX={[],[]};
YY={[],[]};

% for q=1:2
%     load([path_datos filename{q}]);
%     PP{q} = Profiles;
%     XX{q} = X;
%     YY{q} = Y;
% end

perfiles = {load(fullfile(path_datos, filename{1})), load(fullfile(path_datos, filename{2}))};
x_comunes = intersect(perfiles{1}.X, perfiles{2}.X);
y_comunes = intersect(perfiles{1}.Y, perfiles{2}.Y);

A = {nan(1500,1),nan(1500,1)}; % acá guardo las pendientes. Hay 1281 puntos

k=0;
for i = 1:numel(x_comunes)
    for j = 1:numel(y_comunes)
        k=k+1;
        
        fprintf('Paso %d de %d', k, numel(x_comunes)*numel(y_comunes))

        % recorro las cámaras
%         close all, figure, hold on, grid on
        for q = 1:2
    
%             ind_x = XX{q} == 95;
%             ind_y = YY{q} == 495;
            ind_x = perfiles{q}.X == x_comunes(i);
            ind_y = perfiles{q}.Y == y_comunes(j);
            ind_comun = ind_x & ind_y;

            n = find(ind_comun);
            
            pxe = C{q}(n,1);
            pye = C{q}(n,2);
            
            if isnan(pxe) == 1
%                 disp('### No se encontró la punta ###')
                continue
            end

            if numel(pxe) == 0
%                 disp('### numel = 0 ###')
                continue
            end
            
            px_recta = linspace(pxe, pxe+margen(q))';
            py_recta = polyval(R{q}(n,idx{q}), px_recta);

            py = perfiles{q}.Profiles(:, n);
            px = (1:size(py,1))';
            [px, py] = tiro_datos_nulos_perfil(px, py);

            py = 1088-py;

            % convierto todo
            x = polyval4XY(px2mmPol{q}(1), px, py);
            y = polyval4XY(px2mmPol{q}(2), px, py);
            xe = polyval4XY(px2mmPol{q}(1), pxe, pye);
            ye = polyval4XY(px2mmPol{q}(2), pxe, pye);
            x_recta = polyval4XY(px2mmPol{q}(1), px_recta, py_recta);
            y_recta = polyval4XY(px2mmPol{q}(2), px_recta, py_recta);

            % traslado todo
            if q == 2
                x = x-offset_fronteras(1);
                y = y-offset_fronteras(2);
                
                xe = xe-offset_fronteras(1);
                ye = ye-offset_fronteras(2);
                x_recta = x_recta-offset_fronteras(1);
                y_recta = y_recta-offset_fronteras(2);
            end

%             plot(x, y, '--')
%             plot(xe, ye, '*')
%             plot(x_recta, y_recta, '.')
            
%             plot(px,py, '--')
%             plot(pxe, pye, '*')
%             plot(px_recta, py_recta, '.')
            axis equal
            
            % calculo la inclinación del trapecio con cada cámara
            A{q}(k) = (max(y_recta) - min(y_recta))/(max(x_recta) - min(x_recta));
            
        end
    end
end

%% calculo el promedio y la dispersión de la pendiente en cada cámara, en grados

for q = 1:2
    ind = isnan(A{q});
    fprintf('Cámara %d: %.3fº +- %.3fº\n', q, atand(mean(A{q}(~ind))), atand(std(A{q}(~ind))))
end
