clear

path = 'C:\Users\60069978\Documents\MATLAB\scan2\';

%archivo = [path 'coordenadas_grilla.txt'];
archivo = [path 'LUT.txt'];

datos = importdata(archivo, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
p_x = datos(:, 3);
p_y = datos(:, 4);

F = scatteredInterpolant(x, y, p_x, 'natural');

% armo un dominio para evaluar la interpolación (query)
xq = linspace(min(x), max(x), 100);
yq = linspace(min(y), max(y), 100);

[X,Y] = meshgrid(xq, yq);

zq = F(X, Y);

% lo raro es esa última fila
close all
figure(3)
hold on
plot3(x, y, p_x, 'ob');
plot3(X, Y, zq, '.r');
grid on;
xlabel('x');
ylabel('y');
zlabel('pixel_x');

