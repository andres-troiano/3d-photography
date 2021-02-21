% script para chequear de manera rápida si una calibración sigue teniendo
% validez.
% El input es la medición de una misma punta con las dos cámaras

clear variables

% hay que unificar estos dos criterios
path_datos_1 = 'C:\Users\60069978\Documents\MATLAB\medicion38\intento_simple\';
path_datos_2 = 'C:\Users\60069978\Documents\MATLAB\medicion38\';
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion39\';
path_offset = 'C:\Users\60069978\Documents\MATLAB\medicion40\';

load([path_calibracion 'calibration.mat']);

% convertir los .png a .mat usando "ConvertFiles2DotMatCorona.m"

filename = {'misma_punta_c1.png', 'misma_punta_c2.png'};

load([path_offset 'deltas.mat']);
delta_x = deltas(1);
delta_y = deltas(2);
% delta_x = 51.763;
% delta_y = 30.463;

% cargo las coordenadas de las esquinas en pixels, calculadas en
% "puesta_en_comun_2_camaras.m"
load([path_datos_2 'puntas.mat']);

punta_mm = {[], []};

close all
figure, hold on, grid on
for q = 1:2
    
    fd = filename{q};
	frame = imread(fullfile(path_datos_1, fd));
    
    perfil = median(frame);
    perfil = double(perfil)/2^4;
    
    px = 1:numel(perfil);
    py = 1088 - perfil;
%     py = perfil;
    
    px = px.';
    py = py.';
    
    % convertir a mm y comparar
    x = polyval4XY(px2mmPol{q}(1), px, py);
    y = polyval4XY(px2mmPol{q}(2), px, py);
    
    punta_x = polyval4XY(px2mmPol{q}(1), puntas{q}(1), puntas{q}(2));
    punta_y = polyval4XY(px2mmPol{q}(2), puntas{q}(1), puntas{q}(2));
    
    if q == 2
        x = x - delta_x;
        y = y - delta_y;
        
        punta_x = punta_x - delta_x;
        punta_y = punta_y - delta_y;
        
    end
    
%     figure, hold on, grid on
    
%     plot(perfil, '.-')
%     plot(px, py, '.r')
    
    plot(x, y, '.-')
    plot(punta_x, punta_y, '*')
    
    punta_mm{q} = [punta_x, punta_y];

end

axis equal

% calculo el error en um
error = 1e3*(punta_mm{1} - punta_mm{2});
fprintf('Error en X = %.0f um\nError en Y = %.0f um\n', error(1), error(2))