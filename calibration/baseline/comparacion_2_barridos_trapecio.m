clear variables

path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_offset = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion43_base/';

% intersecciones del barrido de calibracion
load([path_calibracion 'intersections.mat']);
C_cal = C;
clear C

% intersecciones del barrido de offset
load([path_offset 'intersections.mat']);
C_off = C;
clear C

% fronteras
load([path_calibracion 'fronteras_con_fronteras.mat']);

% para comparar puedo usar cualquier calibración con tal que sea la misma
% en los 2 casos. Puede ser con o sin fronteras
load([path_calibracion 'calibration.mat']);

load([path_offset 'offset.mat']);

%% grafico las 3 cosas juntas

% lo único que puedo comparar de los 2 barridos es su conversión a mm

% me armo un offset "O" que sirva para las 2 cámaras (en la cámara 1 tiene
% desplazamiento 0)
% O = {zeros(1,4), offset};

% para no usar offset
O = {zeros(1,4), zeros(1,4)};

% para reproducir las fronteras que uso en el cálculo de offset con
% fronteras
F = {[F{1}(:,1), F{1}(:,2)], [F{2}(:,1) + 51.5158, F{2}(:,2) + 30.7054]};

close all
figure, hold on, grid on

% tener en cuenta que F por construcción ya está centrado respecto del
% cilindro, mientras que los barridos no.
% La cámara que hay que desplazar es la 2

for q = 1:2
    
    % convierto las esquinas de los 2 barridos a mm
    x_cal_mm = polyval4XY(px2mmPol{q}(1), C_cal{q}(:,1), C_cal{q}(:,2));
    y_cal_mm = polyval4XY(px2mmPol{q}(2), C_cal{q}(:,1), C_cal{q}(:,2));
    
    x_off_mm = polyval4XY(px2mmPol{q}(1), C_off{q}(:,1), C_off{q}(:,2));
    y_off_mm = polyval4XY(px2mmPol{q}(2), C_off{q}(:,1), C_off{q}(:,2));
    
%     plot(x_cal_mm - O{q}(1), y_cal_mm - O{q}(2), 
    plot(x_off_mm - O{q}(1), y_off_mm - O{q}(2), '.')
    plot(F{q}(:,1), F{q}(:,2), '--')
    
end
axis equal