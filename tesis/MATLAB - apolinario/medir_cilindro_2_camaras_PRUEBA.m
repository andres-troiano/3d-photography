% clear variables
% 
% patron = '34700030';
% 
% % path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion24\';
% path_datos = ['C:\Users\60069978\Documents\MATLAB\medicion26\' patron '\'];
% path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion23\';
% 
% % load([path_datos 'intersections.mat']);
% load([path_calibracion 'calibration.mat']);
% 
% % cámara 1
% load([path_datos 'camara_1.mat']);
% 
% perfiles_1 = Profiles;
% x_1 = X;
% y_1 = Y;
% 
% % cámara 2
% load([path_datos 'camara_2.mat']);
% 
% perfiles_2 = Profiles;
% x_2 = X;
% y_2 = Y;
% 
% % C1 = C{1};
% % C2 = C{2};
% 
% polinomio_x_camara_1 = px2mmPol{1}(1);
% polinomio_y_camara_1 = px2mmPol{1}(2);
% 
% polinomio_x_camara_2 = px2mmPol{2}(1);
% polinomio_y_camara_2 = px2mmPol{2}(2);
% 
% x_pedido = 175;
% y_pedido = 475;
% 
% filtro_x = x_1 == x_pedido;
% filtro_y = y_1 == y_pedido;
% filtro = filtro_x == 1 & filtro_y == 1;
% 
% n1 = find(filtro);
% 
% % encuentro el índice de la cámara 2
% filtro_x = x_2 == x_pedido;
% filtro_y = y_2 == y_pedido;
% filtro = filtro_x == 1 & filtro_y == 1;
% 
% n2 = find(filtro);
% 
% if numel(n1) == 0
%     disp('Punto no medido CAM 1')
% end
% 
% if numel(n2) == 0
%     disp('Punto no medido CAM 2')
% end
% 
% % punta_px_1 = C1(n1, 1);
% % punta_py_1 = C1(n1, 2);
% % punta_px_2 = C2(n2, 1);
% % punta_py_2 = C2(n2, 2);
% 
% pixel_y_camara_1 = 1088 - perfiles_1;
% pixel_y_camara_1 = pixel_y_camara_1(:, n1);
% pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
% pixel_x_camara_1 = pixel_x_camara_1.';
% 
% pixel_y_camara_2 = 1088 - perfiles_2;
% pixel_y_camara_2 = pixel_y_camara_2(:, n2);
% pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
% pixel_x_camara_2 = pixel_x_camara_2.';
% 
% % convierto las puntas a mm
% % punta_mm_x_1 = polyval4XY(polinomio_x_camara_1, punta_px_1, punta_py_1);
% % punta_mm_y_1 = polyval4XY(polinomio_y_camara_1, punta_px_1, punta_py_1);
% % 
% % % cámara 2
% % punta_mm_x_2 = polyval4XY(polinomio_x_camara_2, punta_px_2, punta_py_2);
% % punta_mm_y_2 = polyval4XY(polinomio_y_camara_2, punta_px_2, punta_py_2);
% 
% mm_x_camara_1 = polyval4XY(polinomio_x_camara_1, pixel_x_camara_1, pixel_y_camara_1);
% mm_y_camara_1 = polyval4XY(polinomio_y_camara_1, pixel_x_camara_1, pixel_y_camara_1);
% 
% % cámara 2
% mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
% mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);
% 
% 
% offset_x = -0.0144;
% offset_y = 0.0324;
% 
% delta_x = 51.986 + offset_x;
% delta_y = 29.924 + offset_y;
% % 
% % punta_mm_x_2_trasladado = punta_mm_x_2 - delta_x;
% % punta_mm_y_2_trasladado = punta_mm_y_2 - delta_y;
% 
% mm_x_camara_2_trasladado = mm_x_camara_2 - delta_x;
% mm_y_camara_2_trasladado = mm_y_camara_2 - delta_y;
% 
% % error_x = punta_mm_x_2_trasladado - punta_mm_x_1;
% % error_y = punta_mm_y_2_trasladado - punta_mm_y_1;
% 
% close all
% figure(1)
% hold on
% grid on
% 
% plot(mm_x_camara_1, mm_y_camara_1, '.-b')
% plot(mm_x_camara_2_trasladado, mm_y_camara_2_trasladado, '.-r')
% 
% plot(punta_mm_x_1, punta_mm_y_1, '*g')
% plot(punta_mm_x_2_trasladado, punta_mm_y_2_trasladado, 'oy')

%%

clear variables
path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion30\34700030\';

patron = '34700030';
% path_datos = ['C:\Users\60069978\Documents\MATLAB\medicion26\' patron '\'];
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion27\';

% load([path_datos 'intersections.mat']);
load([path_calibracion 'calibration.mat']);

% cámara 1
load([path_datos 'camara_1.mat']);

perfiles_1 = Profiles;
x_1 = X;
y_1 = Y;

% cámara 2
load([path_datos 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

x_pedido = 200;
y_pedido = 500;

filtro_x = x_1 == x_pedido;
filtro_y = y_1 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n1 = find(filtro);

% encuentro el índice de la cámara 2
filtro_x = x_2 == x_pedido;
filtro_y = y_2 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n2 = find(filtro);

pixel_y_camara_1 = 1088 - perfiles_1;
pixel_y_camara_1 = pixel_y_camara_1(:, n1);
pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
pixel_x_camara_1 = pixel_x_camara_1.';

pixel_y_camara_2 = 1088 - perfiles_2;
pixel_y_camara_2 = pixel_y_camara_2(:, n2);
pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
pixel_x_camara_2 = pixel_x_camara_2.';

mm_x_camara_1 = polyval4XY(polinomio_x_camara_1, pixel_x_camara_1, pixel_y_camara_1);
mm_y_camara_1 = polyval4XY(polinomio_y_camara_1, pixel_x_camara_1, pixel_y_camara_1);

% cámara 2
mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);

delta_x = 51.763;
delta_y = 30.463;

mm_x_camara_2_trasladado = mm_x_camara_2 - delta_x;
mm_y_camara_2_trasladado = mm_y_camara_2 - delta_y;
% 
close all
figure(3)
hold on
grid on

% plot(pixel_x_camara_1, pixel_y_camara_1, '.-b')
% plot(pixel_x_camara_2, pixel_y_camara_2, '.-r')

plot(mm_x_camara_1, mm_y_camara_1, '.-b')
% % plot(mm_x_camara_2, mm_y_camara_2, '.-r')
% 
plot(mm_x_camara_2_trasladado, mm_y_camara_2_trasladado, '.-r')