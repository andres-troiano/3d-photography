% clear variables

path = '/home/andres/Documents/MATLAB/medicion05/';

list = dir([path 'LUT_camara*.png']);
fnames = {list.name};

% set(0,'DefaultFigureVisible', 'off');

%%

% clear variables

% path = '/home/andres/Documents/MATLAB/medicion05/';
% 
% list = dir([path 'LUT_camara*.png']);
% fnames = {list.name};
% 
% set(0,'DefaultFigureVisible', 'off');
% 
% for i = 1:numel(fnames)
% % for i = 1
% 
%     sprintf('Paso %d de %d', i, numel(fnames))
%     
%     filename = [path fnames{i}];
%     
%     % identificaci�n del frame
%     tag = strsplit(filename, '.');
%     tag = tag{1};
%     tag = strsplit(tag, 'camara_');
%     tag = tag{2};
%     tag = strsplit(tag, '_');
%     camara = tag{1};
%     tag_x = tag{4};
%     tag_y = tag{6};
%     
%     frame = imread(filename);
% 
%     perfil = median(frame);
%     perfil = double(perfil)/2^4;
%     
%     datos_x = [];
%     datos_y = [];
% 
%     for i = 1:numel(perfil)
%         if perfil(i) ~= 0
%             datos_x = [datos_x i];
%             datos_y = [datos_y perfil(i)];
%         end
%     end
%     
%     fig_name = ['frames_utiles\LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];
%     
%     % tiro frames donde no se vio nada
%     if numel(datos_x) == 0
%         continue
%     end
%     
%     % los buenos los guardo en \frames_utiles
%     imwrite(frame, [path fig_name]);
%     
% end
% 
% set(0,'DefaultFigureVisible', 'on');

%%

% GRAFICO LA DESVIACION STD EN X,Y DE LA AGUJA EN EL PLANO

% ahora cargo solo los frames utiles, y de ahí descarto si hace falta
path = '/home/andres/Documents/MATLAB/medicion05/frames_utiles/';
list = dir([path 'LUT_camara*.png']);
fnames = {list.name};

tiempo_restante = inf;
periodo_estadistica = [];

STD_X = [];
STD_Y = [];

M = nan(numel(fnames), 4);

% for i = 100:numel(fnames)
% for i = 1
for i = 1:numel(fnames)
    
    i

%     fprintf('Paso %d de %d\n', i, numel(fnames))
    
    filename = [path fnames{i}];
    
    % casos individuales
%     filename = [path 'LUT_camara_2_frame_x_200_y_350.png'];
    
    % identificación del frame
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'camara_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    camara = tag{1};
    tag_x = tag{4};
    tag_y = tag{6};
    
    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;
    
    datos_x = [];
    datos_y = [];

    for j = 1:numel(perfil)
        if perfil(j) ~= 0
            datos_x = [datos_x j];
            datos_y = [datos_y perfil(j)];
        end
    end
    
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    % tiro frames donde no se vio nada
    if numel(datos_x) == 0
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         continue
    end
    
    % calculo un centroide con la mediana
    median_x = median(datos_x);
    median_y = median(datos_y);

    std_x = std(datos_x);
    std_y = std(datos_y);

    datos_x_temp = [];
    datos_y_temp = [];

    for j = 1:numel(datos_x)
        cota_inferior = median_y - std_y;
        cota_superior = median_y + std_y;
        if datos_y(j) < cota_superior && datos_y(j) > cota_inferior
            datos_x_temp = [datos_x_temp datos_x(j)];
            datos_y_temp = [datos_y_temp datos_y(j)];
        end
    end

    % me anoto la std después de haber hecho una primera limpieza
%     tit = sprintf('std_x = %.2f    std_y = %.2f', std_x, std_y);
    
    % guardo los std
    STD_X = [STD_X, std_x];
    STD_Y = [STD_Y, std_y];
    
    M(i, 1) = str2num(tag_x);
    M(i, 2) = str2num(tag_y);
    M(i, 3) = std_x;
    M(i, 4) = std_y;
    
%     set(0,'DefaultFigureVisible', 'on');
%     
%     close all
%     h = figure(1);
%     hold on
% %     plot(perfil, '.-b')
% %     plot(datos_x, datos_y, '.b')
%     plot(datos_x_temp, datos_y_temp, '.b')
%     plot(median_x, median_y, '.r')
% %     plot([min(datos_x) max(datos_x)], [median_y-std_y median_y-std_y], '--r')
% %     plot([min(datos_x) max(datos_x)], [median_y+std_y median_y+std_y], '--r')
%     grid on
%     xlabel('pixel x')
%     ylabel('pixel y')
%     tit = sprintf('std_x = %.2f    std_y = %.2f', std_x, std_y);
%     title(tit)
%     ylim([172 179])
%     
%     saveas(h, [path fig_name], 'png');
%     saveas(h, [path fig_name]);
    
end

%%

% filtro en Y
umbral_sup = median(M(:, 4)) + std(M(:, 4));
umbral_inf = median(M(:, 4)) - std(M(:, 4));
ind = M(:, 4) < umbral_sup & M(:, 4) > umbral_inf;

close all

h1 = figure();
hold on
grid on
plot3(M(:, 1), M(:, 2), M(:, 3), '.')
% plot3(M(ind, 1), M(ind, 2), M(ind, 3), '.')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('std en X (pixels)')
view(38,8)
title('Desviación estándar en X')
saveas(h1, [path 'aguja_std_x.png']);

% P1 = [0, 300, 300]; % todas las coordenadas X
% P2 = [200, 200, 600]; % todas las coordenadas Y
% P3 = [umbral_sup, umbral_sup, umbral_sup]; % todas las coordenadas Z
% 
% Q1 = [0, 300, 300]; % todas las coordenadas X
% Q2 = [200, 200, 600]; % todas las coordenadas Y
% Q3 = [umbral_inf, umbral_inf, umbral_inf]; % todas las coordenadas Z

h2 = figure();
hold on
grid on
% plot3(M(:, 1), M(:, 2), M(:, 4), '.')
plot3(M(ind, 1), M(ind, 2), M(ind, 4), '.')
% fill3(P1, P2, P3,'r')
% fill3(Q1, Q2, Q3,'g')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('std en Y (pixels)')
view(38,8)
title('Desviación estándar en Y')
saveas(h2, [path 'aguja_std_y.png']);

%%

% GRAFICO UN PERFIL DE AGUJA A MODO DE EJEMPLO

path = '/home/andres/Documents/MATLAB/medicion05/frames_utiles/';

list = dir([path 'LUT_camara*.png']);
fnames = {list.name};

for i = 1
    
    filename = [path fnames{i}];
    
    % identificaci�n del frame
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'camara_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    camara = tag{1};
    tag_x = tag{4};
    tag_y = tag{6};
    
    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;
    
    datos_x = [];
    datos_y = [];

    for i = 1:numel(perfil)
        if perfil(i) ~= 0
            datos_x = [datos_x i];
            datos_y = [datos_y perfil(i)];
        end
    end
    
    fig_name = ['frames_utiles\LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];
    
    % tiro frames donde no se vio nada
    if numel(datos_x) == 0
        continue
    end
    
    close all
    
    h1 = figure();
    hold on
    grid on
    plot(perfil, '.-')
    axis equal
    xlabel('X (pixel)')
    ylabel('Y (pixel)')
    title('Perfil de aguja')
    saveas(h1, [path 'perfil_aguja.png']);

    h2 = figure();
    hold on
    grid on
    plot(perfil, '.-')
    axis equal
    xlabel('X (pixel)')
    ylabel('Y (pixel)')
    title('Perfil de aguja (detalle)')
    xlim([623, 634])
    ylim([823, 832])
    saveas(h2, [path 'perfil_aguja_zoom.png']);
    
end