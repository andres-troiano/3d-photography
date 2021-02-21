clear variables
path = 'C:\Users\60069978\Documents\MATLAB\scan18\';

datos = importdata([path 'LUT.txt'], '\t', 1);
datos = datos.data;

% x = datos(:, 1);
% y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

particion_px = linspace(min(px), max(px), 10);
particion_py = linspace(min(py), max(py), 10);

particion_x = [];
particion_y = [];

N = numel(particion_px)*numel(particion_py);
k = 1;

for i = 1:numel(particion_px)
    for j = 1:numel(particion_py)
        sprintf('Paso %d de %d', k, N)
        k = k+1;
        
        [x, y] = convertir_a_unidades_reales(particion_px(i), particion_py(j));
        
        particion_x = [particion_x x];
        particion_y = [particion_y y];
    end
end

%%



% for i = 1:10
%     fila_x = particion_x(i:i+10);
%     fila_y = particion_y(i:i+10);
%     
%     plot(fila_x, fila_y, '.-b')
%     
% end

% filas
%%%%%%%
fila_x_1 = particion_x(1:10);
fila_y_1 = particion_y(1:10);

fila_x_2 = particion_x(11:20);
fila_y_2 = particion_y(11:20);

fila_x_2 = particion_x(11:20);
fila_y_2 = particion_y(11:20);

fila_x_3 = particion_x(21:30);
fila_y_3 = particion_y(21:30);

fila_x_4 = particion_x(31:40);
fila_y_4 = particion_y(31:40);

fila_x_5 = particion_x(41:50);
fila_y_5 = particion_y(41:50);

fila_x_6 = particion_x(51:60);
fila_y_6 = particion_y(51:60);

fila_x_7 = particion_x(61:70);
fila_y_7 = particion_y(61:70);

fila_x_8 = particion_x(71:80);
fila_y_8 = particion_y(71:80);

fila_x_9 = particion_x(81:90);
fila_y_9 = particion_y(81:90);

fila_x_10 = particion_x(91:100);
fila_y_10 = particion_y(91:100);

% columnas
%%%%%%%%%%

col_x_1 = particion_x(1:10:end);
col_y_1 = particion_y(1:10:end);

col_x_2 = particion_x(2:10:end);
col_y_2 = particion_y(2:10:end);

col_x_3 = particion_x(3:10:end);
col_y_3 = particion_y(3:10:end);

col_x_4 = particion_x(4:10:end);
col_y_4 = particion_y(4:10:end);

col_x_5 = particion_x(5:10:end);
col_y_5 = particion_y(5:10:end);

col_x_6 = particion_x(6:10:end);
col_y_6 = particion_y(6:10:end);

col_x_7 = particion_x(7:10:end);
col_y_7 = particion_y(7:10:end);

col_x_8 = particion_x(8:10:end);
col_y_8 = particion_y(8:10:end);

col_x_9 = particion_x(9:10:end);
col_y_9 = particion_y(9:10:end);

col_x_10 = particion_x(10:10:end);
col_y_10 = particion_y(10:10:end);

close all
h = figure;
hold on
grid on
plot(fila_x_1, fila_y_1, '.-b')
plot(fila_x_2, fila_y_2, '.-b')
plot(fila_x_3, fila_y_3, '.-b')
plot(fila_x_4, fila_y_4, '.-b')
plot(fila_x_5, fila_y_5, '.-b')
plot(fila_x_6, fila_y_6, '.-b')
plot(fila_x_7, fila_y_7, '.-b')
plot(fila_x_8, fila_y_8, '.-b')
plot(fila_x_9, fila_y_9, '.-b')
plot(fila_x_10, fila_y_10, '.-b')

plot(col_x_1, col_y_1, '.-b')
plot(col_x_2, col_y_2, '.-b')
plot(col_x_3, col_y_3, '.-b')
plot(col_x_4, col_y_4, '.-b')
plot(col_x_5, col_y_5, '.-b')
plot(col_x_6, col_y_6, '.-b')
plot(col_x_7, col_y_7, '.-b')
plot(col_x_8, col_y_8, '.-b')
plot(col_x_9, col_y_9, '.-b')
plot(col_x_10, col_y_10, '.-b')

xlabel('x(p_x, p_y) (mm)')
ylabel('y(p_x, p_y) (mm)')

title('Transformación de una grilla rectangular de pixels')

saveas(h, [path 'transformacion_grid_pixels'], 'png');
saveas(h, [path 'transformacion_grid_pixels']);

%%

%py_u = unique(py);

% close all
% figure
% hold on
% grid on
% %plot(py, '.-')
% plot3(x, y, py, '.')
% xlabel('x')
% ylabel('y')
% zlabel('py')

close all
figure
hold on
grid on
plot3(px, py, y, 'b.')
plot3(px, py, x, 'r.')
xlabel('p_x')
ylabel('p_y')
legend('x', 'y')