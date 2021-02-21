% en este script uso el laburo de Martín

path = 'C:\Users\60069978\Documents\MATLAB\medicion34\';

creo_directorios_2_camaras(path);

separar_frames_utiles(path, 1);
separar_frames_utiles(path, 2);

%%

% clear variables
basepath = 'C:\Users\60069978\Documents\MATLAB\medicion32\';

load([basepath 'intersections.mat']);

calculateCalibration(C,basepath)

%%

close all

load([basepath 'calibration.mat']);



% POLINOMIOS

% cámara 1
polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

indices_x_1 = polinomio_x_camara_1.ind;
indices_y_1 = polinomio_y_camara_1.ind;

indices_calibrados_1 = indices_x_1 == 1 & indices_y_1 == 1;


% cámara 2
polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

indices_x_2 = polinomio_x_camara_2.ind;
indices_y_2 = polinomio_y_camara_2.ind;

indices_calibrados_2 = indices_x_2 == 1 & indices_y_2 == 1;


% tomo 1 perfil de cada cámara y los grafico en px y en mm

% PIXELS
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

x_pedido = 150;
% x_pedido = 125;
y_pedido = 500;

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


pixel_y_camara_1 = 1088 - perfiles_1;
pixel_y_camara_1 = pixel_y_camara_1(:, n1);
pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
pixel_x_camara_1 = pixel_x_camara_1.';


pixel_y_camara_2 = 1088 - perfiles_2;
pixel_y_camara_2 = pixel_y_camara_2(:, n2);
pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
pixel_x_camara_2 = pixel_x_camara_2.';

C1 = C{1};
C2 = C{2};

punta_px_1 = C1(n1, 1);
punta_py_1 = C1(n1, 2);
punta_px_2 = C2(n2, 1);
punta_py_2 = C2(n2, 2);

% MILÍMETROS
% cámara 1
mm_x_camara_1 = polyval4XY(polinomio_x_camara_1, pixel_x_camara_1, pixel_y_camara_1);
mm_y_camara_1 = polyval4XY(polinomio_y_camara_1, pixel_x_camara_1, pixel_y_camara_1);

% cámara 2
mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);

% convierto las puntas a mm
punta_mm_x_1 = polyval4XY(polinomio_x_camara_1, punta_px_1, punta_py_1);
punta_mm_y_1 = polyval4XY(polinomio_y_camara_1, punta_px_1, punta_py_1);

% cámara 2
punta_mm_x_2 = polyval4XY(polinomio_x_camara_2, punta_px_2, punta_py_2);
punta_mm_y_2 = polyval4XY(polinomio_y_camara_2, punta_px_2, punta_py_2);



% [punta_px_2, punta_py_2]



% muevo la cámara 2 sobre su propia recta
% filtro = mm_x_camara_2 > 125 & mm_x_camara_2 < 148;
filtro = mm_x_camara_2 > 150 & mm_x_camara_2 < 180;

datos_x = mm_x_camara_2(filtro);
datos_y = mm_y_camara_2(filtro);


filtro = true(1, numel(datos_x));

for i = 1:3
    [pol, S] = polyfit(datos_x, datos_y, 1);
    [recta, delta_1] = polyval(pol, datos_x, S);

    umbral_superior = recta + 3*delta_1;
    umbral_inferior = recta - 3*delta_1;
    filtro = datos_y < umbral_superior & datos_y > umbral_inferior;

    datos_x = datos_x(filtro);
    datos_y = datos_y(filtro);
end

% recupero datos válidos
[recta, delta_1] = polyval(pol, mm_x_camara_2, S);
umbral_superior = recta + 3*delta_1;
umbral_inferior = recta - 3*delta_1;
filtro = mm_y_camara_2 > umbral_inferior & mm_y_camara_2 < umbral_superior;
datos_x = mm_x_camara_2(filtro);
datos_y = mm_y_camara_2(filtro);

for i = 1:3
    [pol, S] = polyfit(datos_x, datos_y, 1);
    [recta, delta_1] = polyval(pol, datos_x, S);

    umbral_superior = recta + 3*delta_1;
    umbral_inferior = recta - 3*delta_1;
    filtro = datos_y < umbral_superior & datos_y > umbral_inferior;

    datos_x = datos_x(filtro);
    datos_y = datos_y(filtro);
end

a = pol(1);
% h = norma(datos_x, datos_y);
% h = 59.983;
h = 59.958;
alpha = atand(a);

delta_x = h*cosd(alpha);
delta_y = h*sind(alpha);

[delta_x, delta_y]

mm_x_camara_2_trasladado = mm_x_camara_2 - delta_x;
mm_y_camara_2_trasladado = mm_y_camara_2 - delta_y;


%%%%%%%%%%%%%%%

% % calculo la punta que falta (derecha roja)
% filtro = mm_x_camara_2_trasladado > 80 & mm_x_camara_2_trasladado < 140;
% datos_x_1 = mm_x_camara_2_trasladado(filtro);
% datos_y_1 = mm_y_camara_2_trasladado(filtro);
% 
% filtro = mm_x_camara_2_trasladado > 140 & mm_x_camara_2_trasladado < 160;
% datos_x_2 = mm_x_camara_2_trasladado(filtro);
% datos_y_2 = mm_y_camara_2_trasladado(filtro);
% 
% % ajusto los 2 lados
% for i = 1:3
%     [pol, S] = polyfit(datos_x_1, datos_y_1, 1);
%     [recta, delta_1] = polyval(pol, datos_x_1, S);
% 
%     umbral_superior = recta + 3*delta_1;
%     umbral_inferior = recta - 3*delta_1;
%     filtro = datos_y_1 < umbral_superior & datos_y_1 > umbral_inferior;
% 
%     datos_x_1 = datos_x_1(filtro);
%     datos_y_1 = datos_y_1(filtro);
% end
% 
% a1 = pol(1);
% b1 = pol(2);
% 
% for i = 1:3
%     [pol, S] = polyfit(datos_x_2, datos_y_2, 1);
%     [recta, delta_1] = polyval(pol, datos_x_2, S);
% 
%     umbral_superior = recta + 3*delta_1;
%     umbral_inferior = recta - 3*delta_1;
%     filtro = datos_y_2 < umbral_superior & datos_y_2 > umbral_inferior;
% 
%     datos_x_2 = datos_x_2(filtro);
%     datos_y_2 = datos_y_2(filtro);
% end
% 
% a2 = pol(1);
% b2 = pol(2);
% 
% % punta que faltaba
% x_0 = (b2 - b1)/(a1 - a2);
% y_0 = a1*x_0 + b1;
% 
% error_x = abs(x_0 - punta_mm_x_1);
% error_y = abs(y_0 - punta_mm_y_1);
% 
% [error_x, error_y]

%%%%%%%%%%%%%%%

close all
figure(1)
hold on
grid on

% plot(pixel_x_camara_1, pixel_y_camara_1, '.-b')
% plot(pixel_x_camara_2, pixel_y_camara_2, '.-r')

plot(mm_x_camara_1, mm_y_camara_1, '.-b')
% plot(mm_x_camara_2, mm_y_camara_2, '--r')

% plot(mm_x_camara_2_trasladado, mm_y_camara_2_trasladado, '.-r')

plot(punta_mm_x_1, punta_mm_y_1, '*g')
% plot(punta_mm_x_2, punta_mm_y_2, '*y')
plot(punta_mm_x_2 - delta_x, punta_mm_y_2 - delta_y, '*y')
% plot(x_0, y_0, 'og')

% plot(datos_x_1 , datos_y_1, '.g')
% plot(datos_x_2, datos_y_2, '.y')

% plot(datos_x, datos_y, '.y')
% plot(datos_x, recta, '--b')

% plot(punta_px_1, punta_py_1, '*g')
% plot(punta_px_2, punta_py_2, '*y')