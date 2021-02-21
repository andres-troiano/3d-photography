clear variables

% ahora cargo solo los frames utiles, y analizo
path = 'C:\Users\60069978\Documents\MATLAB\medicion06\camara_2\';
% list = dir([path 'LUT_camara*.png']);
list = dir([path 'LUT_camara_2_frame_x_125_y_400.png']);
fnames = {list.name};

tiempo_restante = inf;
periodo_estadistica = [];
periodo = nan;

set(0,'DefaultFigureVisible', 'on');

for i = 1:numel(fnames)
    
    filename = [path fnames{i}];
%     filename = [path 'LUT_camara_2_frame_x_200_y_425.png'];
    
    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    perfil_x = 1:1:numel(perfil);
    
    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);
    
    %%%%%%%% me conviene antes tirar puntos alejados, porque cuando hay
    %%%%%%%% clusters de outliers, no los detectás mirando diff
    
    median_y = median(datos_y);
    std_y = std(datos_y);
    
    umbral_superior = median_y + 3*std_y;
    umbral_inferior = median_y - 3*std_y;
    
    filtrado_y = datos_y < umbral_superior & datos_y > umbral_inferior;
    
    datos_limpios_x = datos_x(filtrado_y);
    datos_limpios_y = datos_y(filtrado_y);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    incrementos_y = diff(datos_limpios_y);
    incrementos_x = datos_limpios_x(1:end-1);
    
    indice_positivo = incrementos_y > 0;
    
    incrementos_1_x = incrementos_x(~indice_positivo);
    incrementos_1_y = incrementos_y(~indice_positivo);
    
    incrementos_2_x = incrementos_x(indice_positivo);
    incrementos_2_y = incrementos_y(indice_positivo);
    
    datos_x_1 = datos_limpios_x(~indice_positivo);
    datos_y_1 = datos_limpios_y(~indice_positivo);
    
    datos_x_2 = datos_limpios_x(indice_positivo);
    datos_y_2 = datos_limpios_y(indice_positivo);
    
    filtrados_1 = true(size(incrementos_1_x));
    filtrados_2 = true(size(incrementos_2_x));
    
    for j = 1:3
    
        % variables a filtrar
        x_1 = incrementos_1_x(filtrados_1);
        y_1 = incrementos_1_y(filtrados_1);
        x_2 = incrementos_2_x(filtrados_2);
        y_2 = incrementos_2_y(filtrados_2);
    
        median_incrementos_1 = median(y_1);
        std_incrementos_1 = std(y_1);
        umbral_1 = median_incrementos_1 - 3*std_incrementos_1;
        filtrados_1 = y_1 > umbral_1;

        median_incrementos_2 = median(y_2);
        std_incrementos_2 = std(y_2);
        umbral_2 = median_incrementos_2 + 3*std_incrementos_2;
        filtrados_2 = y_2 < umbral_2;
        
    end
    
    %%%%%%%%%%%% grafico %%%%%%%%%%%%

    margen = 25;
    
    close all
    
    figure(1)
    
    ax(1) = subplot(2, 1, 1);
    hold on
    grid on
%     plot(perfil, '.-k')
    plot(datos_x, datos_y, '.k')
    plot(datos_limpios_x, datos_limpios_y, '.b')
    plot(datos_x_1(filtrados_1), datos_y_1(filtrados_1), '.g')
    plot(datos_x_2(filtrados_2), datos_y_2(filtrados_2), '.y')
    ylim([0 200])

    ax(2) = subplot(2, 1, 2);
    hold on
    grid on
    plot(incrementos_x, incrementos_y, '.-b')
    plot(incrementos_1_x(filtrados_1), incrementos_1_y(filtrados_1), '.g')
    plot(incrementos_2_x(filtrados_2), incrementos_2_y(filtrados_2), '.y')
    ylim([-25, 25])
    
    linkaxes(ax,'x');
    
end