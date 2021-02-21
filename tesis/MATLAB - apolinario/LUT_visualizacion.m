% este script es para chequear que la LUT está bien hecha

clear variables
path = 'C:\Users\60069978\Documents\MATLAB\medicion18\';

set(0,'DefaultFigureVisible', 'on');

% cargo el txt que tiene las coords medidas

%%%% LUT 1 %%%%

% datos1 = importdata([path 'camara_1\LUT_camara_1.txt'], '\t', 1);
datos1 = importdata([path 'camara_1\LUT_curada_camara_1.txt'], '\t', 1);
datos1 = datos1.data;

x_stage_1 = datos1(:, 3);
y_stage_1 = datos1(:, 4);
x_ccd_1 = datos1(:, 5);
y_ccd_1 = datos1(:, 6);

%%%% LUT 2 %%%%

% datos2 = importdata([path 'camara_2\LUT_camara_2.txt'], '\t', 1);
datos2 = importdata([path 'camara_2\LUT_curada_camara_2.txt'], '\t', 1);
% datos2 = importdata([path 'camara_2\LUT_camara_2_modificada.txt'], '\t', 1);
datos2 = datos2.data;

x_stage_2 = datos2(:, 3);
y_stage_2 = datos2(:, 4);
x_ccd_2 = datos2(:, 5);
y_ccd_2 = datos2(:, 6);

%%%% grafico ambas %%%%

close all

figure(1)
hold on
grid on

% plot(x_ccd_1, y_ccd_1, 'b.')
plot(x_ccd_2, y_ccd_2, 'b.')

%%

set(0,'DefaultFigureVisible', 'on');

datos1 = importdata([path 'camara_1\centro_hexagono\LUT_centro_hexagono_camara_1.txt'], '\t', 1);
datos1 = datos1.data;

tag_x_1 = datos1(:, 1);
tag_y_1 = datos1(:, 2);
centro_x_1 = datos1(:, 3);
centro_y_1 = datos1(:, 4);

datos2 = importdata([path 'camara_2\centro_hexagono\LUT_centro_hexagono_camara_2.txt'], '\t', 1);
datos2 = datos2.data;

tag_x_2 = datos1(:, 1);
tag_y_2 = datos1(:, 2);
centro_x_2 = datos2(:, 3);
centro_y_2 = datos2(:, 4);

% busco aquellos puntos que tabulé en ambas cámaras

% tag_1 = [1 4; 2 2; 3 6; 4 4];
% tag_2 = [1 4; 7 2; 1 7; 4 4];

% tag_1 = [tag_x_1 tag_y_1];
% tag_2 = [tag_x_2 tag_y_2];

% comunes = intersect(tag_1, tag_2, 'rows');

close all
figure(1)
hold on
grid on

plot(centro_x_1, centro_y_1, 'b.')
plot(centro_x_2, centro_y_2, 'r.')

% plot(tag_1(:, 1), tag_1(:, 2), '.b')
% plot(comunes(:, 1), comunes(:, 2), 'or')