clear variables
basepath = 'C:\Users\60069978\Documents\MATLAB\medicion20\';

camara = '2';

set(0,'DefaultFigureVisible', 'on');

% cargo el txt que tiene las coords medidas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lut = [basepath 'camara_' camara '\LUT_camara_' camara '.txt'];
% lut = [basepath 'camara_' camara '\LUT_curada_camara_' camara '.txt'];

lut = [basepath 'LUT_paso_5_mm_MOD.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

% tag_x = datos(:, 1);
% tag_y = datos(:, 2);
% x_stage = datos(:, 3);
% y_stage = datos(:, 4);
% x_pixel = datos(:, 5);
% y_pixel = datos(:, 6);
% x_P1 = datos(:, 7);
% y_P1 = datos(:, 8);
% x_P2 = datos(:, 9);
% y_P2 = datos(:, 10);

tag_x = datos(:, 1);
tag_y = datos(:, 2);
x_stage = datos(:, 3);
y_stage = datos(:, 4);
x_pixel = datos(:, 5);
y_pixel = datos(:, 6);

[x_en_mm, y_en_mm] = convertir_px_a_mm_polinomio(x_pixel, y_pixel, lut);

x_en_mm = x_en_mm.';
y_en_mm = y_en_mm.';

error_x = x_en_mm - x_stage;
error_y = y_en_mm - y_stage;



close all
figure (1)
hold on
grid on

subplot(2, 1, 1)
plot(error_x)

xlabel('índice')
ylabel('error en x (mm)')

title(['Cámara ' camara])

subplot(2, 1, 2)
plot(error_y)

xlabel('índice')
ylabel('error en y (mm)')






% close all
% figure (1)
% hold on
% grid on
% 
% plot3(x_stage, y_stage, x_en_mm - x_stage, '.b')
% plot3(x_stage, y_stage, y_en_mm - y_stage, '.r')
% 
% xlabel('x (mm)')
% ylabel('y (mm)')
% zlabel('error de calibración (mm)')
% legend('error en X', 'error en Y')
% title(['Cámara ' camara])





% error_mediana_x = median(x_en_mm - x_stage);
% std_mediana_x = std(x_en_mm - x_stage);
% 
% error_mediana_y = median(y_en_mm - y_stage);
% std_mediana_y = std(y_en_mm - y_stage);

mediana_error_x = median(error_x);
std_error_x = std(error_x);

mediana_error_y = median(error_y);
std_error_y = std(error_y);

[std_error_x, std_error_y]


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% filtro los puntos malos de la lut

% filtro en x
filtro = (error_x < mediana_error_x + 3*std_error_x) & (error_x > mediana_error_x - 3*std_error_x);

tag_x = tag_x(filtro);
tag_y = tag_y(filtro);
x_stage = x_stage(filtro);
y_stage = y_stage(filtro);
x_pixel = x_pixel(filtro);
y_pixel = y_pixel(filtro);
x_P1 = x_P1(filtro);
y_P1 = y_P1(filtro);
x_P2 = x_P2(filtro);
y_P2 = y_P2(filtro);

x_en_mm = x_en_mm(filtro);
y_en_mm = y_en_mm(filtro);
error_x = error_x(filtro);
error_y = error_y(filtro);

mediana_error_y = median(error_y);
std_error_y = std(error_y);

% filtro en y
filtro = (error_y < mediana_error_y + 3*std_error_y) & (error_y > mediana_error_y - 3*std_error_y);

tag_x = tag_x(filtro);
tag_y = tag_y(filtro);
x_stage = x_stage(filtro);
y_stage = y_stage(filtro);
x_pixel = x_pixel(filtro);
y_pixel = y_pixel(filtro);
x_P1 = x_P1(filtro);
y_P1 = y_P1(filtro);
x_P2 = x_P2(filtro);
y_P2 = y_P2(filtro);

x_en_mm = x_en_mm(filtro);
y_en_mm = y_en_mm(filtro);
error_x = error_x(filtro);
error_y = error_y(filtro);

% grafico
close all
figure (1)
hold on

plot3(x_stage, y_stage, error_x, '.b')
plot3(x_stage, y_stage, error_y, '.r')

grid on
xlabel('x stage (mm)')
ylabel('y stage (mm)')
zlabel('error de calibración (mm)')

% guardo las nuevas lut sin los datos malos
output_file = fopen( [basepath 'camara_' camara '\LUT_curada_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'tag_x\ttag_y\tx_stage\ty_stage\tx_ccd\ty_ccd\tx_P1\ty_P1\tx_P2\ty_P2\n');

for i = 1:numel(x_pixel)
    fprintf(output_file, '%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', tag_x(i), tag_y(i), x_stage(i), y_stage(i), x_pixel(i), y_pixel(i), x_P1(i), y_P1(i), x_P2(i), y_P2(i));
end

fclose all;
clear output_file;