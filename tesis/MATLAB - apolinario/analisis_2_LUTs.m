path = 'C:\Users\60069978\Documents\MATLAB\';
% 
% archivo = [path '2_LUTs_comparacion.txt'];
% datos = importdata(archivo, '\t', 1);
% datos = datos.data;
% 
% x_pedido = datos(:, 1);
% y_pedido = datos(:, 2);
% x_ccd_1 = datos(:, 3);
% x_ccd_2 = datos(:, 4);
% y_ccd_1 = datos(:, 5);
% y_ccd_2 = datos(:, 6);
% 
% error_x = x_ccd_2 - x_ccd_1;
% error_y = y_ccd_2 - y_ccd_1;

%%%%%%%%%%%%%%

% como no tengo excel cargo las 2 luts por separado
lut_1 = importdata('C:\Users\60069978\Documents\MATLAB\scan18\LUT.txt', '\t', 1);
datos = lut_1.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);
x_ccd_1 = datos(:, 3);
y_ccd_1 = datos(:, 4);

lut_2 = importdata('C:\Users\60069978\Documents\MATLAB\scan19\LUT.txt', '\t', 1);
datos = lut_2.data;

x_ccd_2 = datos(:, 3);
y_ccd_2 = datos(:, 4);

error_x = x_ccd_2 - x_ccd_1;
error_y = y_ccd_2 - y_ccd_1;

close all
h = figure(1);
hold on
grid on
plot(error_x, '.-b')
plot(error_y, '.-r')
xlabel('número de medición')
ylabel('error (pixels)')
legend('error en x', 'error en y')

saveas(h, [path '2_LUTs_comparacion_tira_de_errores'], 'png');

%%

% [X, Y] = meshgrid(x_pedido, y_pedido);
% 
% close all
% figure(1)
% grid on
% plot3(X, Y, error_x, '.b')
% %plot3(X, Y, error_y, '.r')
% xlabel('x (mm)')
% ylabel('y (mm)')
% zlabel('error (pixels)')

%%

% r = x_pedido;
% s = y_pedido;
% t = error_x;
% 
% r = r.';
% s = s.';
% t = t.';
% 
% ri = unique(r);
% si = unique(s);
% [R,S] = meshgrid(ri,si);
% T = reshape(t, size(R));
% 
% set(0,'DefaultFigureVisible', 'on');
% 
% close all
% h_1 = figure(1);
% surf(R, S, T)
% xlabel('x_{stage} (mm)')
% ylabel('y_{stage} (mm)')
% zlabel('error en pixel_x (pixels)')
% 
% % saveas(h, [path '2_LUTs_comparacion_pixel_x_con_pausa'], 'png');
% 
% %%
% 
% r = x_pedido;
% s = y_pedido;
% t = error_y;
% 
% r = r.';
% s = s.';
% t = t.';
% 
% ri = unique(r);
% si = unique(s);
% [R,S] = meshgrid(ri,si);
% T = reshape(t, size(R));
% 
% set(0,'DefaultFigureVisible', 'on');
% 
% h_2 = figure(2);
% surf(R, S, T)
% xlabel('x_{stage} (mm)')
% ylabel('y_{stage} (mm)')
% zlabel('error en pixel_y (pixels)')

% saveas(h, [path '2_LUTs_comparacion_pixel_y_con_pausa'], 'png');