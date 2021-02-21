clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion\';

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
    
    % tiro frames donde no se vio nada
    if numel(datos_x) == 0
        continue
    end
    
    close all
    h = figure(1);
    hold on
    plot(perfil, '.-b')
    plot(datos_x, datos_y, '.r')
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
    
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    % tiro frames donde hay demasiado pocos puntos
%     if camara == '1'
%         if numel(datos_x) <= 188
% %             continue
%             fig_name = ['descartados\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         end
%     end
%     
%     if camara == '2'
%         if numel(datos_x) <= 79
% %             continue
%             fig_name = ['descartados\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         end
%     end

    % tiro frames donde se vieron muy pocos puntos
    if numel(datos_x) <= 10
        fig_name = ['descartados\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        numel(datos_x);
    end
    
    saveas(h, [path fig_name], 'png');
    
end

%%

%     filename = [path 'LUT_camara_1_frame_x_100_y_325.png'];
%     filename = [path 'LUT_camara_2_frame_x_50_y_300.png'];
%     filename = [path 'LUT_camara_2_frame_x_275_y_550.png'];
% filename = [path 'LUT_camara_2_frame_x_75_y_600.png'];
filename = [path 'LUT_camara_2_frame_x_75_y_500.png'];
    
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

x_diff = diff(datos_x);
incremento = x_diff(1);
y_derivada = diff(datos_y)/incremento;

set(0,'DefaultFigureVisible', 'on');

close all

figure(1);
hold on
plot(datos_x, datos_y, '.-b')
grid on
xlabel('pixel x')
ylabel('pixel y')

figure(2);
hold on
plot(datos_x(1:end-1), y_derivada, '.-b')
grid on
xlabel('pixel x')
ylabel('pixel y')