clear variables

archivo = 'C:\Users\60069978\Documents\MATLAB\scan18\LUT.txt';

datos = importdata(archivo, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

%%%%%%%%%%
% x

F = scatteredInterpolant(px, py, x, 'natural');

% armo un dominio para evaluar la interpolación (query)
pxq = linspace(min(px), max(px), 100);
pyq = linspace(min(py), max(py), 100);

[PX,PY] = meshgrid(pxq, pyq);

zq = F(PX, PY);

set(0,'DefaultFigureVisible', 'on');

close all

figure(3)
hold on
plot3(px, py, x, '.r');
surf(PX, PY, zq)
grid on;
xlabel('pixel_x');
ylabel('pixel_y');
zlabel('x (mm)');
legend('Mediciones', 'Interpolación')

%%%%%%%%%
% y

F = scatteredInterpolant(px, py, y, 'natural');

% armo un dominio para evaluar la interpolación (query)
pxq = linspace(min(px), max(px), 100);
pyq = linspace(min(py), max(py), 100);

[PX,PY] = meshgrid(pxq, pyq);

zq = F(PX, PY);

figure(4)
hold on
% plot3(px, py, x, 'ob');
plot3(px, py, y, '.r');
%plot3(PX, PY, zq, '.r');
surf(PX, PY, zq)
grid on;
xlabel('pixel_x');
ylabel('pixel_y');
zlabel('y (mm)');
legend('Mediciones', 'Interpolación')
%zlim([200 400])

