% clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion05\';

list = dir([path 'LUT_camara*.png']);
fnames = {list.name};

set(0,'DefaultFigureVisible', 'off');

%%

% clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion05\';

list = dir([path 'LUT_camara*.png']);
fnames = {list.name};

set(0,'DefaultFigureVisible', 'off');

for i = 1:numel(fnames)
% for i = 1

    sprintf('Paso %d de %d', i, numel(fnames))
    
    filename = [path fnames{i}];
    
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
    
    % los buenos los guardo en \frames_utiles
    imwrite(frame, [path fig_name]);
    
end

%%

% ahora cargo solo los frames utiles, y de ahí descarto si hace falta
path = 'C:\Users\60069978\Documents\MATLAB\medicion05\frames_utiles\';
list = dir([path 'LUT_camara*.png']);
fnames = {list.name};

tiempo_restante = inf;
periodo_estadistica = [];

% for i = 100:numel(fnames)
for i = 1
    
    if i > 1
        
        periodo_estadistica = [periodo_estadistica periodo];
        tiempo_restante = (numel(fnames) - i)*mean(periodo_estadistica);
        
        porcentaje = i/numel(fnames);
    
        if tiempo_restante < 60
            fprintf('%.0f%% completado. Tiempo restante: %.0f segundos aprox.\n', 100*porcentaje, tiempo_restante)
        end

        if tiempo_restante > 60
            fprintf('%.0f%% completado. Tiempo restante: %.1f minutos aprox.\n', 100*porcentaje, tiempo_restante/60)
        end
    end
    
    tic

%     fprintf('Paso %d de %d\n', i, numel(fnames))
    
    filename = [path fnames{i}];
    
    % casos individuales
    filename = [path 'LUT_camara_2_frame_x_200_y_350.png'];
    
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
    
    % tiro puntos que están muy alejados del centroide (una std)
    % por ahora la condición la pongo sólo en y
%     for j = 1:3
%         
%         datos_x_temp = [];
%         datos_y_temp = [];
% 
%         for i = 1:numel(datos_x)
%             if datos_y(i) < median_y + std_y || datos_y(i) > median_y - std_y
%                 datos_x_temp = [datos_x_temp datos_x(i)];
%                 datos_y_temp = [datos_y_temp datos_y(i)];
%             end
%         end
% 
%         datos_x = datos_x_temp;
%         datos_y = datos_y_temp;
%         
%         % me anoto la std después de haber hecho una primera limpieza
%         if j == 1
%             tit = sprintf('std_x = %.2f    std_y = %.2f', std_x, std_y);
%         end
%         
%     end

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

%     datos_x = datos_x_temp;
%     datos_y = datos_y_temp;

    % me anoto la std después de haber hecho una primera limpieza
    tit = sprintf('std_x = %.2f    std_y = %.2f', std_x, std_y);
    
    set(0,'DefaultFigureVisible', 'on');
    
    close all
    h = figure(1);
    hold on
%     plot(perfil, '.-b')
%     plot(datos_x, datos_y, '.b')
    plot(datos_x_temp, datos_y_temp, '.b')
    plot(median_x, median_y, '.r')
%     plot([min(datos_x) max(datos_x)], [median_y-std_y median_y-std_y], '--r')
%     plot([min(datos_x) max(datos_x)], [median_y+std_y median_y+std_y], '--r')
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
    tit = sprintf('std_x = %.2f    std_y = %.2f', std_x, std_y);
    title(tit)
    ylim([172 179])

%     % tiro frames donde se vieron muy pocos puntos
%     if numel(datos_x) <= 10
%         fig_name = ['descartados\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         numel(datos_x);
%     end
    
    saveas(h, [path fig_name], 'png');
    saveas(h, [path fig_name]);
    
    periodo = toc;
    
end

%%

% casos individuales
