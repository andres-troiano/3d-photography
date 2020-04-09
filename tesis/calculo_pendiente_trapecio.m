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
margen = [50, -50];
idx = {[3,4], [1,2]}; % estos son los índices de los parámetros de la recta
% necesito en cada caso

PP={[],[]};
XX={[],[]};
YY={[],[]};

for q=1:2
    load([path_datos filename{q}]);
    PP{q} = Profiles;
    XX{q} = X;
    YY{q} = Y;
end

k=0;
for i = 20%:numel(x_comunes)
    for j = 20%:numel(y_comunes)
        k=k+1;

        % recorro las cámaras
        close all, figure, hold on, grid on
        for q = 1:2
    
            ind_x = XX{q} == 95;
            ind_y = YY{q} == 495;
            ind_comun = ind_x & ind_y;

            n = find(ind_comun);

            py = PP{q}(:, n);
            px = (1:size(py,1))';
            [px, py] = tiro_datos_nulos_perfil(px, py);

            py = 1088-py;

            x = polyval4XY(px2mmPol{q}(1), px, py);
            y = polyval4XY(px2mmPol{q}(2), px, py);

            if q == 2
                x = x-offset_fronteras(1);
                y = y-offset_fronteras(2);
            end

            plot(x, y, '.-')
            axis equal

        end
    end
end