clear all
close all

frame = imread('C:\Users\60069978\Pictures\punta.png');

perfil = median(frame);

% primero tengo que identificar la region de interes

% tiro los ceros
datos_x = [];
datos_y = [];

for i = 1:numel(perfil)
    if perfil(i) ~= 0
        datos_x = [datos_x i];
        datos_y = [datos_y perfil(i)];
    end
end

% identifico el minimo, donde cambia la pendiente
min_y = min(datos_y);
min_x = datos_x(find(datos_y == min_y, 1));

% ajusto las partes decreciente y creciente
% para asegurarme de que evito el pico que hay sobre la punta, dejo 10
% puntos de distancia a izq y der

p_decreciente = polyfit(datos_x(1:(min_x-10)), datos_y(1:(min_x-10)), 1);

figure(1)
hold on
plot(perfil)
plot(datos_x, datos_y, '.r')
plot(min_x, min_y, 'g*')
