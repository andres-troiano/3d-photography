
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion11\';
camara = '1';
dir_camara = ['camara_' camara '\'];

set(0,'DefaultFigureVisible', 'on');

x = 285;
y = 380;

tag_x = num2str(x);
tag_y = num2str(y);

filename = [path dir_camara 'LUT_camara_' camara '_frame_x_' num2str(x) '_y_' num2str(y) '.png'];

frame = imread(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perfil = median(frame);
perfil = double(perfil)/2^4;

perfil_x = 1:1:numel(perfil);

indices_no_nulos = perfil ~= 0;
datos_y = perfil(indices_no_nulos);
datos_x = perfil_x(indices_no_nulos);

% plot(datos_x, datos_y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%% receta %%%%%%%%%%%%%%%%%%%%%%%%%%%%

[datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = receta_limpieza_datos_2(datos_x, datos_y, camara);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% margen = 25;
% 
% close all
% figure
% hold on
% grid on
% plot(perfil, '.-k')
% plot(datos_x, datos_y, '.b')
% % plot(aux_x, aux_y, '.r')
% xlim([min(datos_x)-margen max(datos_x)+margen])
% ylim([min(datos_y)-margen max(datos_y)+margen])
% 

% coordenadas de la punta en pixels
punta_px = (b2 - b1)/(a1 - a2);
punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% antes de descartar tomo todos los datos válidos
datos_total_x_1 = perfil_x(perfil_x < punta_px);
datos_total_y_1 = perfil(perfil_x < punta_px);

datos_total_x_2 = perfil_x(perfil_x > punta_px);
datos_total_y_2 = perfil(perfil_x > punta_px);

% ahora tiro los que se apartan de la banda dada por el ajuste final, y lo
% que queda lo ajusto y redefino la punta. Y a partir de ese resultado
% decido lo que descarto



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% median(datos_y_1)
% std(datos_y_1)


param_rectas = [a1, b1, a2, b2];
[fig_name, flag_descarte] = descarte_perfil_invalido(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);

flag_descarte

% numel(datos_x_1) + numel(datos_x_2)
numel(datos_x_1)
numel(datos_x_2)

close all
h = figure(1);
hold on
plot(perfil, '.-k')

% plot(datos_x_1, datos_y_1, '.g')
% plot(datos_x_2, datos_y_2, '.y')
% 
% plot(datos_x_1, recta_1, '--b')
% plot(datos_x_2, recta_2, '--r')
% 
% plot(punta_px, punta_py, '*r')

plot(datos_total_x_1, datos_total_y_1, '.g')
plot(datos_total_x_2, datos_total_y_2, '.y')

margen = 25;

grid on
xlabel('pixel x')
ylabel('pixel y')
% xlim([min(datos_x)-margen max(datos_x)+margen])
% ylim([min(datos_y)-margen max(datos_y)+margen])