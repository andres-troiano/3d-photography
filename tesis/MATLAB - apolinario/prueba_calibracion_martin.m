basepath = 'C:\Users\60069978\Documents\MATLAB\medicion22\';

% cámara 1
load([basepath 'camara_1.mat']);

perfiles_1 = Profiles;
x_1 = X;
y_1 = Y;

% cámara 2
load([basepath 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

% x_pedido = 150;
x_pedido = 122;
y_pedido = 340;

% encuentro el índice de la cámara 1
filtro_x = x_1 == x_pedido;
filtro_y = y_1 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n1 = find(filtro);

% encuentro el índice de la cámara 2
filtro_x = x_2 == x_pedido;
filtro_y = y_2 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n2 = find(filtro);

% está usando (140, 340), (122.5, 340) para las cámaras 1 y 2 resp
% el problema es que ni 122 ni 123 existen, porque voy de a 5
% n1 = 1;
% n2 = 1;

pixel_y_camara_1 = 1088 - perfiles_1;
pixel_y_camara_1 = pixel_y_camara_1(:, n1);
pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
pixel_x_camara_1 = pixel_x_camara_1.';


pixel_y_camara_2 = 1088 - perfiles_2;
pixel_y_camara_2 = pixel_y_camara_2(:, n2);
pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
pixel_x_camara_2 = pixel_x_camara_2.';

close all
figure(1)
hold on
grid on

plot(pixel_x_camara_1, pixel_y_camara_1, '.-b')
plot(pixel_x_camara_2, pixel_y_camara_2, '.-r')