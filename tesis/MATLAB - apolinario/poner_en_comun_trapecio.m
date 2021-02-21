clear variables
path = 'C:\Users\60069978\Documents\MATLAB\medicion17\';

set(0,'DefaultFigureVisible', 'on');

x_pedido = 110;
y_pedido = 395;









lut_1 = [path 'camara_1\LUT_camara_1.txt'];
lut_2 = [path 'camara_2\LUT_camara_2.txt'];



datos1 = importdata(lut_1, '\t', 1);
datos1 = datos1.data;

tag_x_1 = datos1(:, 1);
tag_y_1 = datos1(:, 2);
centro_x_1 = datos1(:, 3);
centro_y_1 = datos1(:, 4);
x_ccd_1 = datos1(:, 5);
y_ccd_1 = datos1(:, 6);

datos2 = importdata(lut_2, '\t', 1);
datos2 = datos2.data;

tag_x_2 = datos2(:, 1);
tag_y_2 = datos2(:, 2);
centro_x_2 = datos2(:, 3);
centro_y_2 = datos2(:, 4);
x_ccd_2 = datos2(:, 5);
y_ccd_2 = datos2(:, 6);




% cargo el perfil 1
datos_curados = importdata([path 'camara_1\LUT_camara_1_datos_curados_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.txt'], '\t', 1);
datos_curados = datos_curados.data;

% esto esta en pixels
perfil_px_1 = datos_curados(:, 1);
perfil_py_1 = datos_curados(:, 2);

% % transformo el perfil y la punta a mm
[perfil_x_1, perfil_y_1] = convertir_px_a_mm_polinomio(perfil_px_1, perfil_py_1, lut_1);
[punta_x_1, punta_y_1] = convertir_px_a_mm_polinomio(x_ccd_1, y_ccd_1, lut_1);



indice_x_1 = tag_x_1 == x_pedido;
indice_y_1 = tag_y_1 == y_pedido;

indice_pedido_1 = indice_x_1 == 1 & indice_y_1 == 1;

punta_x_1 = punta_x_1(indice_pedido_1);
punta_y_1 = punta_y_1(indice_pedido_1);




% cargo el perfil 2
datos_curados = importdata([path 'camara_2\LUT_camara_2_datos_curados_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.txt'], '\t', 1);
datos_curados = datos_curados.data;

% esto esta en pixels
perfil_px_2 = datos_curados(:, 1);
perfil_py_2 = datos_curados(:, 2);

% % transformo el perfil y la punta a mm
[perfil_x_2, perfil_y_2] = convertir_px_a_mm_polinomio(perfil_px_2, perfil_py_2, lut_2);
[punta_x_2, punta_y_2] = convertir_px_a_mm_polinomio(x_ccd_2, y_ccd_2, lut_2);




indice_x_2 = tag_x_2 == x_pedido;
indice_y_2 = tag_y_2 == y_pedido;

indice_pedido_2 = indice_x_2 == 1 & indice_y_2 == 1;

punta_x_2 = punta_x_2(indice_pedido_2);
punta_y_2 = punta_y_2(indice_pedido_2);



close all
figure
hold on
grid on

plot(perfil_x_1, perfil_y_1, 'ob')
plot(perfil_x_2, perfil_y_2, '.-r')
plot(punta_x_1, punta_y_1, '*c')
plot(punta_x_2, punta_y_2, '*g')

% plot(perfil_px_1, perfil_py_1, 'ob')
% plot(perfil_px_2, perfil_py_2, '.-r')

%%

datos1 = importdata([path 'camara_1\centro_hexagono\LUT_centro_hexagono_camara_1.txt'], '\t', 1);
datos1 = datos1.data;

tag_x_1 = datos1(:, 1);
tag_y_1 = datos1(:, 2);
centro_x_1 = datos1(:, 3);
centro_y_1 = datos1(:, 4);
x_ccd_1 = datos1(:, 5);
y_ccd_1 = datos1(:, 6);

datos2 = importdata([path 'camara_2\centro_hexagono\LUT_centro_hexagono_camara_2.txt'], '\t', 1);
datos2 = datos2.data;

tag_x_2 = datos2(:, 1);
tag_y_2 = datos2(:, 2);
centro_x_2 = datos2(:, 3);
centro_y_2 = datos2(:, 4);
x_ccd_2 = datos2(:, 5);
y_ccd_2 = datos2(:, 6);





lut_1 = [path 'camara_1\LUT_camara_1.txt'];
lut_2 = [path 'camara_2\LUT_camara_2.txt'];

% cargo el perfil 1
datos_curados = importdata([path 'camara_1\LUT_camara_1_datos_curados_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.txt'], '\t', 1);
datos_curados = datos_curados.data;

% esto esta en pixels
perfil_px = datos_curados(:, 1);
perfil_py = datos_curados(:, 2);

% transformo el perfil y la punta a mm
[perfil_x_1, perfil_y_1] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut_1);
[punta_x_1, punta_y_1] = convertir_px_a_mm_polinomio(x_ccd_1, y_ccd_1, lut_1);



% cargo el perfil 2
datos_curados = importdata([path 'camara_2\LUT_camara_2_datos_curados_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.txt'], '\t', 1);
datos_curados = datos_curados.data;

% esto esta en pixels
perfil_px = datos_curados(:, 1);
perfil_py = datos_curados(:, 2);

% transformo el perfil y la punta a mm
[perfil_x_2, perfil_y_2] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut_2);
[punta_x_2, punta_y_2] = convertir_px_a_mm_polinomio(x_ccd_2, y_ccd_2, lut_2);




tag_pedido = [x_pedido y_pedido];

tag_1 = [tag_x_1 tag_y_1];
tag_2 = [tag_x_2 tag_y_2];

indice_x_1 = tag_x_1 == x_pedido;
indice_y_1 = tag_y_1 == y_pedido;

indice_pedido_1 = indice_x_1 == 1 & indice_y_1 == 1;

punta_x_1 = punta_x_1(indice_pedido_1);
punta_y_1 = punta_y_1(indice_pedido_1);

centro_x_1 = centro_x_1(indice_pedido_1);
centro_y_1 = centro_y_1(indice_pedido_1);




indice_x_2 = tag_x_2 == x_pedido;
indice_y_2 = tag_y_2 == y_pedido;

indice_pedido_2 = indice_x_2 == 1 & indice_y_2 == 1;

punta_x_2 = punta_x_2(indice_pedido_2);
punta_y_2 = punta_y_2(indice_pedido_2);

centro_x_2 = centro_x_2(indice_pedido_2);
centro_y_2 = centro_y_2(indice_pedido_2);

% close all
% figure
% hold on
% grid on
% 
% % plot(indice_x_1, '.-b')
% % plot(indice_y_1, '.-r')
% % plot(indice_pedido_1, 'og')
% % 
% plot(indice_x_2, '.-b')
% plot(indice_y_2, '.-r')
% plot(indice_pedido_2, 'og')



%%%%%%%%%%%%%%%%%%%%%



% los centros deberían estar separados 20 mm

separacion = norma([centro_x_1 centro_x_2], [centro_y_2 centro_y_2]);

r = 40.075/2;
alfa = 120;

% gamma sale de angulos_camara. Lo tengo que encontrar por los tags,
% volviendo a identificar el índice. Podría hacer una función para esto,
% que tome tags y archivo, y te devuelva lo que querés

%%%%%%%%%%%%% busco gamma %%%%%%%%%%%%%

datos1 = importdata([path 'camara_1\angulos_camara_1.txt'], '\t', 1);
datos1 = datos1.data;

tag_x_1 = datos1(:, 1);
tag_y_1 = datos1(:, 2);
alfa_array_1 = datos1(:, 5);
gamma_array_1 = datos1(:, 6);

tag_1 = [tag_x_1 tag_y_1];
tag_2 = [tag_x_2 tag_y_2];

indice_x_1 = tag_x_1 == x_pedido;
indice_y_1 = tag_y_1 == y_pedido;

indice_pedido_1 = indice_x_1 == 1 & indice_y_1 == 1;

alfa_1 = alfa_array_1(indice_pedido_1);
gamma_1 = gamma_array_1(indice_pedido_1);





datos2 = importdata([path 'camara_2\angulos_camara_2.txt'], '\t', 1);
datos2 = datos2.data;

tag_x_2 = datos2(:, 1);
tag_y_2 = datos2(:, 2);
alfa_array_2 = datos2(:, 5);
gamma_array_2 = datos2(:, 6);

% tag_1 = [tag_x_1 tag_y_1];
tag_2 = [tag_x_2 tag_y_2];

indice_x_2 = tag_x_2 == x_pedido;
indice_y_2 = tag_y_2 == y_pedido;

indice_pedido_2 = indice_x_2 == 1 & indice_y_2 == 1;

alfa_2 = alfa_array_2(indice_pedido_2);
gamma_2 = gamma_array_2(indice_pedido_2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cambio esta parte

% x_desplazado_1 = punta_x_1 - r*cosd(alfa/2 - gamma_1);
% y_desplazado_1 = punta_y_1 + r*sind(alfa/2 - gamma_1);
%   
% x_desplazado_2 = punta_x_2 - r*cosd(alfa/2 + gamma_2);
% y_desplazado_2 = punta_y_2 + r*sind(alfa/2 + gamma_2);


x_desplazado_1 = punta_x_1 + r*cosd(alfa_1/2 - gamma_1);
y_desplazado_1 = punta_y_1 - r*sind(alfa_1/2 - gamma_1);
  
% x_desplazado_2 = punta_x_2 - r*cosd(alfa/2 + gamma_2);
% y_desplazado_2 = punta_y_2 - r*sind(alfa/2 + gamma_2);

% separacion = norma([x_desplazado_1 x_desplazado_2], [y_desplazado_1 y_desplazado_2]);

% alfa_1 = 120;
% alfa_2 = 120;

traslacion_x_1 = r*cosd(alfa_1/2 - gamma_1);
traslacion_y_1 = - r*sind(alfa_1/2 - gamma_1);

% traslacion_x_2 = - r*cosd(alfa_2/2 + gamma_2);
traslacion_x_2 = r*cosd(alfa_2/2 + gamma_2);
traslacion_y_2 = - r*sind(alfa_2/2 + gamma_2);

close all
figure
hold on
grid on

plot(perfil_x_1, perfil_y_1, '--b')
plot(perfil_x_2, perfil_y_2, '--r')

plot(perfil_x_1 + traslacion_x_1, perfil_y_1 + traslacion_y_1, '.-b')
plot(perfil_x_2 + traslacion_x_2, perfil_y_2 + traslacion_y_2, '.-r')

plot(x_desplazado_1, y_desplazado_1, '*b')
% plot(x_desplazado_2, y_desplazado_2, '*r')

plot(punta_x_2 + traslacion_x_2, punta_y_2 + traslacion_y_2, '*r')

% plot(punta_x_2, punta_y_2, '*g')

% plot(centro_x_1, centro_y_1, '*g')
% plot(centro_x_2(indice_pedido_2), centro_y_2(indice_pedido_2), '*c')

axis equal