% chequeo calibracion con los stages

path = 'C:\Users\60069978\Documents\MATLAB\scan13\';

[socketID, positioner_x, positioner_y] = setup_stages();
camara = setup_camara(102);

%%

% quiero elegir puntos y ver si la calibración es correcta
% acá yo quiero tomar por bueno el posicionamiento. Ie, usar el medido pero
% asumir que no hay dispersión. En la calibración espero un único
% resultado, así que voy a estar comparando pares de puntos.
% Puedo tomarlos al azar en el rango. Tomo 100. Rojos reales, azules
% interpolados.

x_min = 280;
x_max = 390;

y_min = 440;
y_max = 570;

x_pedidos = [];
y_pedidos = [];

x_interpolados = [];
y_interpolados = [];

N = 100;

output_file = fopen( [path 'coord_pedidas_vs_medidas.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

for i = 1:N
    
    sprintf('Paso %d de %d', i, N)

    % estos dos números los elijo al azar
    x = randi([x_min, x_max]);
    y = randi([y_min, y_max]);

    [errorCode] = GroupMoveAbsolute(socketID, positioner_x, x);
    [errorCode] = GroupMoveAbsolute(socketID, positioner_y, y);

    frame = getsnapshot(camara);
    
%     x_pedidos = [x_pedidos x];
%     y_pedidos = [y_pedidos y];
%     
%     x_interpolados = [x_interpolados x_0];
%     y_interpolados = [y_interpolados y_0];

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
%for i = 1

    sprintf('Procesando archivo %d de %d', i, M)
   
    % asumo que no tuve la suerte de medir dos veces el mismo punto del
    % espacio
    filename = [path 'frame_calibracion_stages_x_' num2str(x_pedido(i)) '_y_' num2str(y_pedido(i)) '.png'];
    
    % detecto las coords de la punta y guardo el plot por si hay que
    % debuguear
    frame = imread(filename);
    
    X0 = 100;
    f = @(x)ajuste_punta_1_param(x, frame);
    [x, fval] = fminsearch(f, X0);
    
    [x_0, y_0] = punta_1_param(x, filename);
    
    x_ccd = [x_ccd x_0];
    y_ccd = [y_ccd y_0];
    
    [x_interpolado, y_interpolado] = convertir_a_unidades_reales(x_ccd, y_ccd);
    
end


%set(0,'DefaultFigureVisible', 'on');

close all
h = figure(1);
hold on
grid on
plot(x_pedido, y_pedido, '.r')
plot(x_interpolado, y_interpolado, '.b')

%saveas(h, [path 'calibracion_stages'], 'png');

%%

% ahora mido las distancias
% guardo los errores de cada medicion en un vector, sin importar por ahora
% qué error corresponde a qué punto

errores = [];

error_x = [];
error_y = [];

for i = 1:M
%for i = 40
    
    % voy mirando de a pares de puntos
    % calculo la distancia
    % la funcion norma te pide que le des un vector con las coordenadas x y
    % otro con las coordenadas y. Inicialmente estaba pensado para medir
    % una recta de puntos mirando sus extremos, como en el trapecio
    
%     punto_pedido = [x_pedido(i), y_pedido(i)]
%     punto_interpolado = [x_interpolado(i), y_interpolado(i)]
    
    error_x = [];
    error_y = [];

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
% 
% [X, Y] = meshgrid(x, y);
% zq = griddata(x, y, z, X, Y);
% 
% close all
% figure(2)
% grid on
% hold on
% % plot3(x, y, z, 'ob')
% % plot3(x, y, zq, '.r')
% surf(X, Y, zq)
% xlabel('x (mm)')
% ylabel('y (mm)')
% zlabel('error (mm)')
% 
% %%
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

[X, Y] = meshgrid(x_sorted, y_sorted);
Z = griddata(x_sorted, y_sorted, z_sorted, X, Y);

figure(3)
grid on
hold on
surf(X, Y, Z)
xlabel('x (mm)')
ylabel('y (mm)')
zlabel('error (mm)')

%%

% Close connection
TCP_CloseSocket(socketID);