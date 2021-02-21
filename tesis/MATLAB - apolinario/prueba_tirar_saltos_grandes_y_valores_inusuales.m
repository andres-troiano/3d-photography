clear variables

set(0,'DefaultFigureVisible', 'on');
path = 'C:\Users\60069978\Documents\MATLAB\medicion07\';
camara = '2';

dir_camara = ['camara_' camara '\'];

filename = [path dir_camara '\LUT_camara_' camara '_frame_x_125_y_450.png'];
frame = imread(filename);

perfil = median(frame);
perfil = double(perfil)/2^4;

perfil_x = 1:1:numel(perfil);

indices_no_nulos = perfil ~= 0;
datos_y = perfil(indices_no_nulos);
datos_x = perfil_x(indices_no_nulos);
% 
[aux_y_1, aux_x_1] = filtro_saltos_grandes(datos_y, datos_x, 1);
[aux_x_2, aux_y_2] = filtro_saltos_grandes(aux_x_1, aux_y_1, 1);

[aux_x_3, aux_y_3] = filtro_valores_inusuales(aux_x_2, aux_y_2, 1, 3);
[aux_y_4, aux_x_4] = filtro_valores_inusuales(aux_y_3, aux_x_3, 1, 1);
[aux_y_5, aux_x_5] = filtro_valores_inusuales(aux_y_4, aux_x_4, -1, 1);

[aux_y_6, aux_x_6] = filtro_saltos_grandes(aux_y_5, aux_x_5, 1);

[aux_x_7, aux_y_7] = filtro_valores_inusuales(aux_x_6, aux_y_6, -1, 3);

aux_x = aux_x_7;
aux_y = aux_y_7;

close all
figure(1)
hold on
grid on
plot(datos_x, datos_y, '.-b')
plot(aux_x, aux_y, '.r')
% plot(aux_x_1, aux_y_1, '.r')
% plot(aux_x_2, aux_y_2, '.g')
% plot(aux_x_3, aux_y_3, '.c')
% plot(aux_x_4, aux_y_4, '.m')
% plot(aux_x_5, aux_y_5, '.y')