clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion19\';

creo_directorios_2_camaras(path);

separar_frames_utiles(path, 1);
separar_frames_utiles(path, 2);

%%

% creo que este script lo único que hace es graficar los perfiles, sin
% procesamiento

camara = '2';

dir_camara = ['camara_' camara '\'];
list = dir([path dir_camara 'LUT_camara*.png']);
fnames = {list.name};

%%%%%%%%%%%%%%%%%%%

% cargo el txt que tiene las coords medidas
datos = importdata([path 'coord_pedidas_vs_medidas.txt'], '\t', 1);
datos = datos.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);
x_medido = datos(:, 3);
y_medido = datos(:, 4);

set(0,'DefaultFigureVisible', 'off');

N = numel(x_pedido);

for i = 1:N
    
    tic

    sprintf('Paso %d de %d', i, numel(x_pedido))

    tag_x = num2str(x_pedido(i));
    tag_y = num2str(y_pedido(i));
    
    filename = dir([path dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png']);
    filename = {filename.name};
    
    if numel(filename) == 0
        continue
    end
    
    filename = filename{1};
    filename = [path dir_camara filename];
    
%     filename = [path dir_camara '\LUT_camara_' camara '_frame_x_125_y_450.png'];

    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    perfil_x = 1:1:numel(perfil);
    
    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);
    
    %%%%%%%% grafico %%%%%%%%
    
    close all
    h = figure(1);
    hold on
    
    plot(datos_x, datos_y, '.-b')
    
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
    
    %%%%%%%% guardo los gráficos %%%%%%%%
    
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    saveas(h, [path dir_camara fig_name], 'png');
    
end