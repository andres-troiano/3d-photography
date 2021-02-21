
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% el outlier tirarlo con sigmas.
% hacer try catch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

% cargo un perfil que tenga ceros, para que el algoritmo los descarte
% frame = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_270_y_600.png');
frame = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_270_y_600.png');

perfil = median(frame);

% corrijo por el subpixel resolution
perfil = double(perfil)/2^4;

% primero tengo que identificar la region de interes
% solo necesito encontrar los indices
indice_1 = find(perfil, 1, 'first');
indice_3 = find(perfil, 1, 'last');

% me creo un perfil nuevo, sin los ceros indeseados
perfil_limpio_y = perfil(1:indice_1 - 1);

% para dejar los huecos hay que tener los valores de x tambien
perfil_limpio_x = 1:indice_1 - 1;

close all
figure(1)
hold on
plot(perfil_limpio_x, perfil_limpio_y, '.-b')
plot(perfil_limpio_x(indice_1:indice_3), perfil_limpio_y(indice_1:indice_3), '.-r')

% yo quiero tirar los ceros que están entre indice 1 e indice 3
for i = indice_1:indice_3
    if perfil(i) ~= 0
        perfil_limpio_y = [perfil_limpio_y perfil(i)];
        perfil_limpio_x = [perfil_limpio_x i];
    end
end

perfil_limpio_y = [perfil_limpio_y perfil(indice_3+1:end)];
perfil_limpio_x = [perfil_limpio_x indice_3+1:numel(perfil)];

% para encontrar el punto de quiebre, busco el minimo entre los dos indices
% anteriores
quiebre_y = min(perfil_limpio_y(indice_1:indice_3)); 
indice_2 = find(perfil_limpio_y == quiebre_y);

figure(2)
% plot(perfil_limpio_y(indice_1:indice_3))
plot(perfil(indice_1:indice_3))


% ajusto las partes decreciente y creciente
% para asegurarme de que evito el pico que hay sobre la punta, al hacer el 
% fit dejo 10 puntos de distancia a izq y der

% para graficar las rectas me paso de la punta, así encuentro la
% intersección

% convierto a doble para poder usar polyfit
% perfil = double(perfil);

p_decreciente = polyfit(indice_1:indice_2-10, perfil_limpio_y(indice_1:indice_2-10), 1);
recta_decreciente = polyval(p_decreciente, indice_1:indice_3);

p_creciente = polyfit(indice_2+10:indice_3, perfil_limpio_y(indice_2+10:indice_3), 1);
recta_creciente = polyval(p_creciente, indice_1:indice_3);

% punta = intersect(recta_decreciente, recta_creciente);

% este método requiere Mapping Toolbox
% x1 = [indice_1 indice_2+10];
% y1 = [perfil(indice_1) perfil(indice_2+10)];
% 
% x2 = [indice_2-10 indice_3];
% y2 = [perfil(indice_2-10) perfil(indice_3)];
% 
% figure(2)
% mapshow(x1, y1)

% calculo el (x, y) de la intersección:
% y1 = a1x + b1
% y2 = a2x + b2
% x0 = (b2 - b1)/(a1 - a2)
% y0 = a1x0 + b1

a1 = p_decreciente(1);
b1 = p_decreciente(2);
a2 = p_creciente(1);
b2 = p_creciente(2);

x_0 = (b2 - b1)/(a1 - a2);
y_0 = a1*x_0 + b1;

close all
figure(1)
hold on
% plot(perfil)
plot(400, quiebre_y, 'y*')
plot(indice_1, perfil(indice_1), '*r')
plot(indice_2, perfil(indice_2), '*g')
plot(indice_3, perfil(indice_3), '*c')
plot(perfil_limpio_x, perfil_limpio_y, '.-b')
% plot(indice_1:indice_3, recta_decreciente, 'r.-')
% plot(indice_1:indice_3, recta_creciente, 'c.-')
% plot(x_0, y_0, 'r.')