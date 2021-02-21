% se corre 2 veces, una por cada cámara

clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion\';
archivo = [path 'coord_pedidas_vs_medidas_camara_1.txt'];

% Las coordenadas de la punta en pixels, en las diferentes posiciones
x_ccd = [];
y_ccd = [];

x_stage = [];
y_stage = [];

%N = 4;
% N = numel(fnames);

% cargo el txt que tiene las coords medidas
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
    %disp(filename)
    
    % del filename obtengo las coordenadas del stage
%     tag = strsplit(filename, '.');
%     tag = tag{1};
%     tag = strsplit(tag, 'frame_');
%     tag = tag{2};
%     tag = strsplit(tag, '_');
    
    %[x_0, y_0] = deteccion_punta_funcion(filename);
    
    %frame = imread(filename);
    
    %%%%%%%%%%%%%%
    % estimo el separador como la mitad de los datos
    % o como el minimo
    
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

    datos_x_temp = [];
    datos_y_temp = [];

    % tiro unos pocos puntos al final, que pertenecen al flanco que va del
    % trapecio a la mesa
    % Podría verlos al ppio también
    datos_x = datos_x(1:end-3);
    datos_y = datos_y(1:end-3);

    datos_x = datos_x(3:end);
    datos_y = datos_y(3:end);
    
    [y_min, indice_min] = min(datos_y);
    x_min = datos_x(indice_min);
    
    %X0 = datos_x(end) - datos_x(1);
    X0 = x_min;
    
    %%%%%%%%%%%%%%
    
    %X0 = 500;
    %f = @(x)ajuste_punta_1_param(x, frame);
    f = @(x)ajuste_punta_1_param_2(x, filename, 0);
    [x, fval] = fminsearch(f, X0);
    
    %[x_0, y_0] = punta_1_param(x, filename);
    [x_0, y_0] = coords_punta(x, filename, 1);
    
    x_ccd = [x_ccd x_0];
    y_ccd = [y_ccd y_0];
    
    x_stage = [x_stage x_medido(i)];
    y_stage = [y_stage y_medido(i)];

end

set(0,'DefaultFigureVisible', 'off');

%%

close all
h = figure(2);
plot(x_ccd, y_ccd, '.')
xlabel('x');
ylabel('y');
grid on
saveas(h, [path 'grilla'], 'png');

output_file = fopen( [path 'LUT.txt'], 'wt' );
fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\n');

for i = 1:numel(x_ccd)
    fprintf(output_file, '%f\t%f\t%f\t%f\n', x_stage(i), y_stage(i), x_ccd(i), y_ccd(i));
end

fclose all;
clear output_file;