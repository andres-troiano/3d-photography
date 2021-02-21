
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion14\';
camara = '2';
dir_camara = ['camara_' camara '\'];

set(0,'DefaultFigureVisible', 'on');

x = 100;
y = 370;

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

close all
figure
plot(perfil)

%%


% [datos_x_parcial, datos_y_parcial] = tiro_mitad_datos(datos_x, datos_y, camara);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% receta %%%%%%%%%%%%%%%%%%%%%%%%%%%%

[datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_tuerca_inclinada(datos_x, datos_y, camara);

% plot(datos_x_1, datos_y_1)

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

[x_definitivo_1, y_definitivo_1, x_definitivo_2, y_definitivo_2, punta_definitiva_px, punta_definitiva_py] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_x_2, recta_1, recta_2, delta_1, delta_2, punta_px, a1, a2, b1, b2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % antes de descartar tomo todos los datos válidos
% datos_total_x_1 = perfil_x(perfil_x < punta_px);
% datos_total_y_1 = perfil(perfil_x < punta_px);
% 
% datos_total_x_2 = perfil_x(perfil_x > punta_px);
% datos_total_y_2 = perfil(perfil_x > punta_px);
% 
% % ahora tiro los que se apartan de la banda dada por el ajuste final, y lo
% % que queda lo ajusto y redefino la punta. Y a partir de ese resultado
% % decido lo que descarto
% 
% % calculo la banda a partir de S_1, S_2 y los parámetros de los polinomios:
% 
% % calculo los parámetros de las 6 rectas, para definir las 2 bandas
% % ya tengo a,b de las 2 rectas, me faltan de las deltas
% cant_sigmas = 12;
% 
% [a_sup_1, b_sup_1] = calculo_parametros_recta(datos_x_1, recta_1 + cant_sigmas*delta_1);
% [a_inf_1, b_inf_1] = calculo_parametros_recta(datos_x_1, recta_1 - cant_sigmas*delta_1);
% 
% [a_sup_2, b_sup_2] = calculo_parametros_recta(datos_x_2, recta_2 + cant_sigmas*delta_2);
% [a_inf_2, b_inf_2] = calculo_parametros_recta(datos_x_2, recta_2 - cant_sigmas*delta_2);
% 
% % []
% 
% % ahora que tengo los parámetros defino las bandas
% % el orden de los parámetros para polyval es de mayor orden a menor
% % es decir a,b
% 
% x_recta_izq = datos_total_x_1;
% 
% y_recta_izq = polyval([a1, b1], x_recta_izq);
% y_sup_izq = polyval([a_sup_1, b_sup_1], x_recta_izq);
% y_inf_izq = polyval([a_inf_1, b_inf_1], x_recta_izq);
% 
% % ahora selecciono los datos que cumplen la condición
% filtro = datos_total_y_1 < y_sup_izq & datos_total_y_1 > y_inf_izq;
% 
% x_definitivo_1 = datos_total_x_1(filtro);
% y_definitivo_1 = datos_total_y_1(filtro);
% 
% for j = 1:3
%     [x_definitivo_1, y_definitivo_1, recta_definitivo_1, a1_definitivo, b1_definitivo] = filtro_banda(x_definitivo_1, y_definitivo_1, 2);
% end
% 
% % calculo la punta definitiva
% a1 = a1_definitivo;
% b1 = b1_definitivo;
% 
% punta_definitiva_px = (b2 - b1)/(a1 - a2);
% punta_definitiva_py = a1*(b2 - b1)/(a1 - a2) + b1;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% median(datos_y_1)
% std(datos_y_1)


% param_rectas = [a1, b1, a2, b2];
% [fig_name, flag_descarte] = descarte_perfil_invalido(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);
% 
% flag_descarte
% 
% % numel(datos_x_1) + numel(datos_x_2)
% numel(datos_x_1)
% numel(datos_x_2)

close all
h = figure(1);
hold on
plot(perfil, '.-k')

plot(datos_x_1, datos_y_1, '.b')
plot(datos_x_2, datos_y_2, '.r')

plot(datos_x_1, recta_1, '--b')
plot(datos_x_2, recta_2, '--r')

% plot(datos_x_1, recta_1 + delta_1, '--c')
% plot(datos_x_1, recta_1 - delta_1, '--c')
% plot(datos_x_2, recta_2 + delta_2, '--m')
% plot(datos_x_2, recta_2 - delta_2, '--m')

% plot(x_recta_izq, y_recta_izq, '--r')
% plot(x_recta_izq, y_sup_izq, '--c')
% plot(x_recta_izq, y_inf_izq, '--g')

% plot(punta_px, punta_py, '*g')

% plot(datos_total_x_1, datos_total_y_1, '.g')
% plot(datos_total_x_2, datos_total_y_2, '.y')

% plot(datos_total_x_1(filtro), datos_total_y_1(filtro), '.r')
plot(x_definitivo_1, y_definitivo_1, '.g')
plot(x_definitivo_2, y_definitivo_2, '.y')

plot(punta_definitiva_px, punta_definitiva_py, '*r')

margen = 25;

grid on
xlabel('pixel x')
ylabel('pixel y')
xlim([min(datos_x)-margen max(datos_x)+margen])
ylim([min(datos_y)-margen max(datos_y)+margen])