clear variables

path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_offset = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion43_base/';

% fronteras
load([path_calibracion 'fronteras.mat']);
load([path_calibracion 'FC.mat']);

% hace falta para convertir FC, que está en px
load([path_calibracion 'calibration.mat']);
load([path_offset 'offset.mat']);

%% las grafico juntas

% F está desplazado, y quiero ver cómo queda en relación a FC cuando está
% "anti-desplazado"
F = {[F{1}(:,1), F{1}(:,2)], [F{2}(:,1) + offset(1), F{2}(:,2) + offset(2)]};

% convierto FC a mm, porque está en px
for q = 1:2
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];
end

close all
figure, hold on, grid on

for q = 1:2
    
    plot(F{q}(:,1), F{q}(:,2), 'b--')
    plot(FC{q}(:,1), FC{q}(:,2), 'r--')
    
end
axis equal