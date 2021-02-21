
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion17\';
camara = '2';
dir_camara = ['camara_' camara '\'];

set(0,'DefaultFigureVisible', 'on');

x = 160;
y = 400;

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



% [datos_x_parcial, datos_y_parcial] = tiro_mitad_datos(datos_x, datos_y, camara);

J = 0;
if camara == '1'
    J = 2;
elseif camara == '2'
    J = 2;
end


    
% si veo el trapecio entero, lo parto a la mitad y miro la izquierda
% asumo que el perfil ocupa aprox 500 pixels en x
if datos_x(end) - datos_x(1) > 850
    disp('corté')
    [datos_x, datos_y] = tiro_mitad_datos(datos_x, datos_y, camara);
end





for j = 1:J
    
    [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_trapecio(datos_x, datos_y, camara);
    
    % coordenadas de la punta en pixels
    punta_px = (b2 - b1)/(a1 - a2);
    punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

%     numel(datos_x)

    % acá chequeo si tengo que redefinir los dominios y volver a correr
    [datos_x, datos_y] = redefino_dominio(perfil_x, perfil, datos_x, datos_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_px, punta_py, a1, a2, camara);
    
end



% close all
% figure
% hold on
% grid on
% 
% plot(perfil, '.-k')
% plot(datos_x, datos_y, '.b')
% plot(datos_x_1, datos_y_1, '.-g')
% plot(datos_x_2, datos_y_2, '.-y')
% plot(punta_px, punta_py, '*r')




% ojo a ver si quiero guardar esto en variables aparte o no

% [datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_px, punta_py] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
[datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);







% close all
% figure
% hold on
% grid on
% 
% plot(datos_x, datos_y, '.r')

% 
% plot(perfil, '.-k')
% plot(datos_x_1, datos_y_1, '.-g')
% plot(datos_x_2, datos_y_2, '.-y')
% plot(punta_px, punta_py, '*r')



%%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

param_rectas = [a1, b1, a2, b2];
[punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

[fig_name, flag_descarte] = descarte_perfil_invalido_trapecio(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);

flag_descarte



% % numel(datos_x_1) + numel(datos_x_2)
% numel(datos_x_1)
% numel(datos_x_2)

close all
h = figure(1);
hold on
plot(perfil, '.-k')

plot(datos_x_1, datos_y_1, '.g')
plot(datos_x_2, datos_y_2, '.y')

plot(punta_px, punta_py, '*r')

grid on
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
