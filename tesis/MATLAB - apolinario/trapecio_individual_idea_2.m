
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion17\';
camara = '2';
dir_camara = ['camara_' camara '\'];

set(0,'DefaultFigureVisible', 'on');

x = 110;
y = 430;

tag_x = num2str(x);
tag_y = num2str(y);

filename = [path dir_camara 'LUT_camara_' camara '_frame_x_' num2str(x) '_y_' num2str(y) '.png'];

frame = imread(filename);

y = median(frame);
y = double(y)/2^4;

x = 1:1:numel(y);

[x, y] = tiro_datos_nulos_perfil(x, y);

[datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(y, x, -1, 3);
[datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);

datos_x = datos_x(3:end-2);
datos_y = datos_y(3:end-2);

[datos_x, datos_y] = tiro_base_trapecio(datos_x, datos_y, camara);

if datos_x(end) - datos_x(1) > 600
    [datos_x, datos_y] = tiro_mitad_datos(datos_x, datos_y, camara);
end

% close all
% figure
% hold on
% grid on
% 
% plot(x, y, '.-b')
% plot(datos_x, datos_y, '.r')



for j = 1:2
    
    [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_trapecio(datos_x, datos_y, camara);
    [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

    % acá chequeo si tengo que redefinir los dominios y volver a correr
    [datos_x, datos_y] = redefino_dominio(x, y, datos_x, datos_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_px, punta_py, a1, a2, camara);
    
end

[datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(x, y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
[punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

%%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param_rectas = [a1, b1, a2, b2];

[fig_name, flag_descarte] = descarte_perfil_invalido_trapecio(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);

flag_descarte

% % numel(datos_x_1) + numel(datos_x_2)
% numel(datos_x_1)
% numel(datos_x_2)

close all
h = figure(1);
hold on
grid on

plot(x, y, '.-k')
plot(datos_x, datos_y, '.b')
plot(datos_x_1, datos_y_1, '.g')
plot(datos_x_2, datos_y_2, '.y')
plot(punta_px, punta_py, '*r')

xlabel('pixel x')
ylabel('pixel y')

margen = 100;

datos_x = [datos_x_1, datos_x_2];
datos_y = [datos_y_1, datos_y_2];

if numel(datos_x) > 0
    xlim([min(datos_x)-margen max(datos_x)+margen])
    ylim([min(datos_y)-margen max(datos_y)+margen])
end


% xlim([min([datos_x_1, datos_x_2])-margen max([datos_x_1, datos_x_2])+margen])
% ylim([min([datos_y_1, datos_y_2])-margen max([datos_y_1, datos_y_2])+margen])
