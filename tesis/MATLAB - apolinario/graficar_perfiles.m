clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan19\';
    
% list = dir([path 'LUT_frame_*.png']);
% fnames = {list.name};

% Las coordenadas de la punta en pixels, en las diferentes posiciones
x_ccd = [];
y_ccd = [];

x_stage = [];
y_stage = [];

%N = 4;
% N = numel(fnames);

% cargo el txt que tiene las coords medidas
archivo = [path 'coord_pedidas_vs_medidas.txt'];
datos = importdata(archivo, '\t', 1);
datos = datos.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);
x_medido = datos(:, 3);
y_medido = datos(:, 4);

N = numel(x_pedido);

for i=1:N
%for i = 123
%for i = 1:4
    sprintf('Procesando frame %d de %d', i, N)
    
    % me salteo los que tienen y = 430 xq no se alcanza a ver la punta
    if y_pedido(i) == 430
        continue
    end
    
    filename = [path 'LUT_frame_x_' num2str(x_pedido(i)) '_y_' num2str(y_pedido(i)) '.png'];
    
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
    
    p = strsplit(filename, '\');
    path = [p{1}, '\', p{2}, '\', p{3}, '\', p{4}, '\', p{5}, '\', p{6}, '\'];

    close all
    h = figure(1);
    grid on
    plot(datos_x, datos_y, '.b')
    
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'LUT_frame_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    
    fig_name = ['perfil_x_' tag{2} '_y_' tag{4}];
    saveas(h, [path fig_name], 'png');

end