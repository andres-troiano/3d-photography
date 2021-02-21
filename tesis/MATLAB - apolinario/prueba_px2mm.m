clear variables

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

load([path_datos 'intersections.mat']);
load([path_datos 'rectas.mat']);
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras.mat']);

filename = {'camara_1.mat', 'camara_2.mat'};

close all, figure, hold on, grid on
for q = 1:2

    load([path_datos filename{q}]);
    
    ind_x = X == 95;
    ind_y = Y == 495;
    ind_comun = ind_x & ind_y;

    n = find(ind_comun);

    py = Profiles(:, n);
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