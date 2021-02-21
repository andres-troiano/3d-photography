path = 'C:\Users\60069978\Documents\MATLAB\scan\';

list = dir([path 'frame_grados_01*.png']);
fnames = {list.name};

N = numel(fnames);

distribucion = [];

for i=1:N
    sprintf('Procesando frame %d de %d', i, N)
    
    filename = [path fnames{i}];
    disp(filename)
    
    medida = ajuste_trapecio_funcion(filename);
    distribucion = [distribucion medida];
    
end

close all
figure(1)
plot(distribucion, '.-')

%%

% quiero ver el 4 y el 5
[medida_4, x_4, y_4, datos_x_1_4, datos_y_1_4, recta_1_4, datos_x_2_4, datos_y_2_4, recta_2_4, datos_x_3_4, datos_y_3_4, recta_3_4, perfil_4] = ajuste_trapecio_funcion([path, fnames{4}]);
[medida_5, x_5, y_5, datos_x_1_5, datos_y_1_5, recta_1_5, datos_x_2_5, datos_y_2_5, recta_2_5, datos_x_3_5, datos_y_3_5, recta_3_5, perfil_5] = ajuste_trapecio_funcion([path, fnames{5}]);

norma(x_4, y_4)
norma(x_5, y_5)

close all
figure(2)
hold on
% plot(perfil_4, '-b')
%plot(perfil_5, '-r')
% plot(datos_x_1_4, recta_1_4, '-b')
% plot(datos_x_1_5, recta_1_5, '-r')
% plot(datos_x_2_4, recta_2_4, '-b')
% plot(datos_x_2_5, recta_2_5, '-r')
% plot(datos_x_3_4, recta_3_4, '-b')
% plot(datos_x_3_5, recta_3_5, '-r')
plot(datos_x_1_4, datos_y_1_4, '*b')
plot(datos_x_1_5, datos_y_1_5, '.r')
% plot(datos_x_2_4, datos_y_2_4, '.-b')
% plot(datos_x_2_5, datos_y_2_5, '.-r')
% plot(datos_x_3_4, datos_y_3_4, '.-b')
% plot(datos_x_3_5, datos_y_3_5, '.-r')
% plot(x_4, y_4, '.b')
% plot(x_5, y_5, '.r')