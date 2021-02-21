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
    
    paso_y = diff(datos_y);
    paso_y_negativo = paso_y(paso_y < 0);
    paso_y_positivo = paso_y(paso_y > 0);
    
    % las coordenadas x de cada parte, la positiva y la negativa
    paso_y_x = datos_x(1:end-1);
    paso_y_negativo_x = paso_y_x(paso_y < 0);
    paso_y_positivo_x = paso_y_x(paso_y > 0);
    
    for j = 1:2
        
        mediana_paso_positivo = median(paso_y_positivo);
        std_paso_positivo = std(paso_y_positivo);

        mediana_paso_negativo = median(paso_y_negativo);
        std_paso_negativo = std(paso_y_negativo);

        umbral_positivo = mediana_paso_positivo + 3*std_paso_positivo;
        umbral_negativo = mediana_paso_negativo - 3*std_paso_negativo;

        filtro_positivo = paso_y_positivo < umbral_positivo;
        filtro_negativo = paso_y_negativo > umbral_negativo;

        % aca debería recalcular la mediana y dispersión, e iterar
        paso_y_positivo = paso_y_positivo()
        paso_y_negativo
        
    end
    
    %%%%%%%%%%%% grafico %%%%%%%%%%%%

    margen = 25;
    
    close all
    
    figure(1)
    
    ax(1) = subplot(2, 1, 1);
    hold on
%     plot(perfil, '.-k')
    plot(datos_x, datos_y, '.b')
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
% %     xlim([min(datos_x)-margen max(datos_x)+margen])
% %     ylim([min(datos_y)-margen max(datos_y)+margen])

    ax(2) = subplot(2, 1, 2);
    hold on
    grid on
    plot(paso_y_x, paso_y, '.-k')
    plot(paso_y_negativo_x(filtro_negativo), paso_y_negativo(filtro_negativo), 'g.')
    plot(paso_y_positivo_x(filtro_positivo), paso_y_positivo(filtro_positivo), 'y.')
    
    margen = 20;
    
%     xlim([min(paso_y_negativo(filtro_negativo))-margen max(paso_y_negativo(filtro_negativo))+margen])
    ylim([min(paso_y_negativo(filtro_negativo))-margen max(paso_y_positivo(filtro_negativo))+margen])
%     
    linkaxes(ax,'x');
    
end