clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan24\';

% acá elijo el paso (más grueso que el original) que quiero usar. Debe ser
% múltiplo de 5 mm
paso = 35;

% cargo el txt que tiene las coords medidas
archivo = [path 'coord_pedidas_vs_medidas.txt'];
datos = importdata(archivo, '\t', 1);
datos = datos.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);
x_medido = datos(:, 3);
y_medido = datos(:, 4);

% cargo las coordenadas del ccd
archivo = [path 'LUT_paso_5_mm.txt'];
datos = importdata(archivo, '\t', 1);
datos = datos.data;

x_ccd = datos(:, 3);
y_ccd = datos(:, 4);

size = numel(x_pedido);

% me fijo cual es el paso minimo
diff_x = unique(diff(x_pedido));
paso_minimo = diff_x(2);

% tomo puntos salteados
x_pedido_unicos = unique(x_pedido);
y_pedido_unicos = unique(y_pedido);

% ahora de esta lista quiero tomar salteado. Ej, si quiero ir cada 10,
% salteo 1, si quiero ir cada 15 salteo 2 etc
tag_paso = num2str(paso);
m = paso/5;

x_pedido_unicos_grueso = x_pedido_unicos(1:m:end);
y_pedido_unicos_grueso = y_pedido_unicos(1:m:end);

x_pedido_grueso = zeros(1, size);
y_pedido_grueso = zeros(1, size);
x_medido_grueso = zeros(1, size);
y_medido_grueso = zeros(1, size);
x_ccd_grueso = zeros(1, size);
y_ccd_grueso = zeros(1, size);

% el problema es que no quiero hacer un doble loop, quiero recorrer la
% lista de pares x, y

for i = 1:size
    if ismember(x_pedido(i), x_pedido_unicos_grueso) && ismember(y_pedido(i), y_pedido_unicos_grueso)

        x_pedido_grueso(i) = x_pedido(i);
        y_pedido_grueso(i) = y_pedido(i);
        x_medido_grueso(i) = x_medido(i);
        y_medido_grueso(i) = y_medido(i);
        x_ccd_grueso(i) = x_ccd(i);
        y_ccd_grueso(i) = y_ccd(i);
        
    end
end

% ahora elimino los ceros que me quedaron
% esto sólo sirve porque sé que nunca mandé un stage a 0!

x_pedido_grueso(x_pedido_grueso == 0) = [];
y_pedido_grueso(y_pedido_grueso == 0) = [];
x_medido_grueso(x_medido_grueso == 0) = [];
y_medido_grueso(y_medido_grueso == 0) = [];
x_ccd_grueso(x_ccd_grueso == 0) = [];
y_ccd_grueso(y_ccd_grueso == 0) = [];

set(0,'DefaultFigureVisible', 'on');

close all
h = figure(2);
hold on
plot(x_ccd, y_ccd, '.b')
plot(x_ccd_grueso, y_ccd_grueso, '.r')
xlabel('pixel_x');
ylabel('pixel_y');
grid on
legend('Paso 5 mm', ['Paso ' tag_paso ' mm'], 'Location', 'Best');

%%

% guardo los datos

% saveas(h, [path 'grilla_paso_' tag_paso '_mm'], 'png');
% saveas(h, [path 'grilla_paso_' tag_paso '_mm']);
% 
% output_file = fopen( [path 'LUT_paso_' tag_paso '_mm.txt'], 'wt' );
% fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\n');
% 
% for i = 1:numel(x_ccd_grueso)
%     fprintf(output_file, '%f\t%f\t%f\t%f\n', x_medido_grueso(i), y_medido_grueso(i), x_ccd_grueso(i), y_ccd_grueso(i));
% end
% 
% fclose all;
% clear output_file;

%%

% ya que estoy, en el mismo código comparo las distintas tablas

% para mí tengo que usar un mismo dominio para graficar la diferencia. Y
% tiene que ser el dominio grueso.
% No, es más fácil: me tengo que armar un dominio cualquiera e interpolar
% siempre ahí
% pero para calcular el interpolador sí necesito usar los pixels que feron
% tabulados

clear variables

paso_grueso = 15;
set(0,'DefaultFigureVisible', 'on');

% interpolación fina
%%%%%%%%%%%%%%%%%%%%
lut = 'C:\Users\60069978\Documents\MATLAB\scan24\LUT_paso_5_mm.txt';

datos = importdata(lut, '\t', 1);
datos = datos.data;

x_fino = datos(:, 1);
y_fino = datos(:, 2);
px_fino = datos(:, 3);
py_fino = datos(:, 4);

% x fino
%%%%%%%%

F = scatteredInterpolant(px_fino, py_fino, x_fino, 'natural');

% armo un dominio para evaluar la interpolación (query)
% quiero usar esto para las 2 interpolaciones. Quizás convendría que fuera
% más chico

% pruebo de dejar un margen alrededor de los bordes del dominio que tabulé,
% porque quizás allí la interpolación sea muy mala

margen = 100;
az = 38;
el = 24;

pxq = linspace(min(px_fino) + margen, max(px_fino) - margen, 100);
pyq = linspace(min(py_fino) + margen, max(py_fino) - margen, 100);

% esto se calcula una sola vez!
[PX,PY] = meshgrid(pxq, pyq);

x_fino_interpolado = F(PX, PY);

% y fino
%%%%%%%%
F = scatteredInterpolant(px_fino, py_fino, y_fino, 'natural');
y_fino_interpolado = F(PX, PY);

% interpolación gruesa
%%%%%%%%%%%%%%%%%%%%%%

tag_paso_grueso = num2str(paso_grueso);

lut = ['C:\Users\60069978\Documents\MATLAB\scan24\LUT_paso_' tag_paso_grueso '_mm.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

x_grueso = datos(:, 1);
y_grueso = datos(:, 2);
px_grueso = datos(:, 3);
py_grueso = datos(:, 4);

% x grueso
%%%%%%%%%%

F = scatteredInterpolant(px_grueso, py_grueso, x_grueso, 'natural');
x_grueso_interpolado = F(PX, PY);

% y grueso
%%%%%%%%%%

F = scatteredInterpolant(px_grueso, py_grueso, y_grueso, 'natural');
y_grueso_interpolado = F(PX, PY);

% comparo las dos interpolaciones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diferencia_x = x_grueso_interpolado - x_fino_interpolado;
diferencia_y = y_grueso_interpolado - y_fino_interpolado;

% reporto el rango del error
error_x = abs(max(max(diferencia_x)) - min(min(diferencia_x)));
error_y = abs(max(max(diferencia_y)) - min(min(diferencia_y)));

% [error_x, error_y]

close all

h1 = figure(1);
hold on
surf(PX, PY, diferencia_x)
grid on;
xlabel('pixel_x');
ylabel('pixel_y');
zlabel('Error en x (mm)');
title([tag_paso_grueso ' mm vs 5 mm'])
view(az,el)

h2 = figure(2);
hold on
surf(PX, PY, diferencia_y)
grid on;
xlabel('pixel_x');
ylabel('pixel_y');
zlabel('Error en y (mm)');
title([tag_paso_grueso ' mm vs 5 mm'])
view(az,el)

%%

% analizo el apartamiento de la tendencia observado en la lut cada 15 mm
% miro 1ro la interpolación fina, aunque debería estar chequeada ya

[PX_dato, PY_dato] = meshgrid(px_fino, py_fino);

close all
figure(3)
hold on
grid on
% plot3(PX, PY, x_fino_interpolado, '.y')
% plot3(PX, PY, x_grueso_interpolado, '.g')
surf(PX, PY, x_fino_interpolado)
surf(PX, PY, x_grueso_interpolado)
plot3(px_fino, py_fino, x_fino, '.b')
view(-36,39)
alpha(0.5)

%%

% path = 'C:\Users\60069978\Documents\MATLAB\scan24\';
% 
% tit1 = [path 'error_en_x_' tag_paso_grueso '_mm_vs_5_mm'];
% saveas(h1, tit1, 'png');
% saveas(h1, tit1);
% 
% tit2 = [path 'error_en_y_' tag_paso_grueso '_mm_vs_5_mm'];
% saveas(h2, tit2, 'png');
% saveas(h2, tit2);