% chequeo calibracion con los stages
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan\';

%%

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
camara = setup_camara(102);

%%

% quiero elegir puntos y ver si la calibración es correcta
% acá yo quiero tomar por bueno el posicionamiento. Ie, usar el medido pero
% asumir que no hay dispersión. En la calibración espero un único
% resultado, así que voy a estar comparando pares de puntos.
% Puedo tomarlos al azar en el rango. Tomo 100. Rojos reales, azules
% interpolados.

% x_min = 290;
% x_max = 390;
% 
% y_min = 440;
% y_max = 570;

y_min = 440;
y_max = 570;

x_min = 370;
x_max = 470;

%%

% chequeo que el seteo de umbral sea bueno

[errorCode] = GroupMoveAbsolute(socketID, positioner_y, 600); 
[errorCode] = GroupMoveAbsolute(socketID, positioner_x, 500);

set(0,'DefaultFigureVisible', 'on');

frame = getsnapshot(camara);
perfil = median(frame);
perfil = double(perfil)/2^4;

figure(1)
plot(perfil)

%%

x_pedidos = [];
y_pedidos = [];

x_interpolados = [];
y_interpolados = [];

N = 100;

output_file = fopen( [path 'coord_pedidas_vs_medidas.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

tol = 1e-3;
pause on

for i = 1:N
    
    sprintf('Paso %d de %d', i, N)

    % estos dos números los elijo al azar
    x = randi([x_min, x_max]);
    y = randi([y_min, y_max]);

    mover_stage_2(socketID, group_x, positioner_x, x, tol);
    mover_stage_2(socketID, group_y, positioner_y, y, tol);
    
    pause(15)

    frame = getsnapshot(camara);

    [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
    [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
    
    fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
    imwrite(frame, [path 'frame_calibracion_stages_x_' num2str(x) '_y_' num2str(y) '.png'], 'PNG');

end

fclose all;
    
%%

% ahora cargo los frames anteriores y los analizo
% los cargo recorriendo la lista que anoté en el txt, así tengo la
% referencia a las coord medidas

datos = importdata([path 'coord_pedidas_vs_medidas.txt']);
datos = datos.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);
x_medido = datos(:, 3);
y_medido = datos(:, 4);

M = numel(x_pedido);

x_ccd = [];
y_ccd = [];

x_interpolado = [];
y_interpolado = [];

for i = 1:M
%for i = 1:7
    
%     % quiero omitir los puntos por debajo de x = 290 porque no los tabule
%     if x_pedido(i) < 290
%         x_pedido(i)
%         continue
%     end

    sprintf('Procesando archivo %d de %d', i, M)
   
    % asumo que no tuve la suerte de medir dos veces el mismo punto del
    % espacio
    filename = [path 'frame_calibracion_stages_x_' num2str(x_pedido(i)) '_y_' num2str(y_pedido(i)) '.png'];
    
    % detecto las coords de la punta y guardo el plot por si hay que
    % debuguear
    %frame = imread(filename);
    
    %X0 = 100;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % estimo el separador como el minimo
    
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    f = @(x)ajuste_punta_1_param_2(x, filename, 0);
    [x, fval] = fminsearch(f, X0);
    
    %[x_0, y_0] = punta_1_param(x, filename);
    [x_0, y_0] = coords_punta(x, filename, 1);
    
    x_ccd = [x_ccd x_0];
    y_ccd = [y_ccd y_0];
    
    lut = 'C:\Users\60069978\Documents\MATLAB\scan24\LUT_paso_5_mm.txt';
    [x_interpolado, y_interpolado] = convertir_a_unidades_reales(x_ccd, y_ccd, lut);
    
end


set(0,'DefaultFigureVisible', 'on');

close all
h = figure(1);
hold on
grid on
plot(x_pedido, y_pedido, '.r')
plot(x_interpolado, y_interpolado, '.b')

% saveas(h, [path 'calibracion_stages'], 'png');

%%

% ahora mido las distancias
% guardo los errores de cada medicion en un vector, sin importar por ahora
% qué error corresponde a qué punto

errores = [];

error_x = [];
error_y = [];

for i = 1:M
% ahora tengo menos puntos porque filtré los x<290
%for i = 1:94
%for i = 40
    
    % voy mirando de a pares de puntos
    % calculo la distancia
    % la funcion norma te pide que le des un vector con las coordenadas x y
    % otro con las coordenadas y. Inicialmente estaba pensado para medir
    % una recta de puntos mirando sus extremos, como en el trapecio
    
%     punto_pedido = [x_pedido(i), y_pedido(i)]
%     punto_interpolado = [x_interpolado(i), y_interpolado(i)]
    
    error_x = [error_x (x_interpolado(i) - x_pedido(i))];
    error_y = [error_y (y_interpolado(i) - y_pedido(i))];

    coords_x = [x_pedido(i), x_interpolado(i)];
    coords_y = [y_pedido(i), y_interpolado(i)];
    
    %error = norma(punto_pedido, punto_interpolado)
    error = norma(coords_x, coords_y);
    errores = [errores error];
    
end

% r = x_pedido;
% s = y_pedido;
% t = errores;
% 
% figure(1)
% plot(r, s)

%%

x = x_pedido;
y = y_pedido;
z = errores;

[X, Y] = meshgrid(x, y);
zq = griddata(x, y, z, X, Y);

set(0,'DefaultFigureVisible', 'on');

close all
figure(2)
grid on
hold on
plot3(x, y, z, '.b')
% plot3(x, y, zq, '.r')
%surf(X, Y, zq)
xlabel('x (mm)')
ylabel('y (mm)')
zlabel('distancia (mm)')
%alpha(.2)

figure(3)
grid on
hold on
plot3(x, y, error_x, '.b')
xlabel('x (mm)')
ylabel('y (mm)')
zlabel('error en x (mm)')

figure(4)
grid on
hold on
plot3(x, y, error_y, '.b')
xlabel('x (mm)')
ylabel('y (mm)')
zlabel('error en y (mm)')

%%


%%
% 
% % ordeno los datos?
% [x, indices] = sort(x);
% y = y(indices);
% z = z(indices);
% 
% x_unicos = unique(x);
% 
% y_sorted = [];
% z_sorted = [];
% 
% for i = 1:numel(x_unicos)
%     subset_y = [];
%     subset_z = [];
%     
%     for j = 1:numel(x)
%         if x(j) == x_unicos(i)
%             subset_y = [subset_y y(j)];
%             subset_z = [subset_z z(j)];
%         end
%     end
%     
%     y_sorted = [y_sorted subset_y];
%     z_sorted = [z_sorted subset_z];
%     
% end

%%

% [X, Y] = meshgrid(x_sorted, y_sorted);
% Z = griddata(x_sorted, y_sorted, z_sorted, X, Y);
% 
% figure(3)
% grid on
% hold on
% surf(X, Y, Z)
% xlabel('x (mm)')
% ylabel('y (mm)')
% zlabel('error (mm)')

%%

% Close connection
TCP_CloseSocket(socketID);