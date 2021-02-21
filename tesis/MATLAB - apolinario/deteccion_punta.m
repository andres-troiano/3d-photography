clear all
close all

frame = imread('C:\Users\60069978\Pictures\punta.png');

perfil = median(frame);

% primero tengo que identificar la region de interes
% puedo poner un umbral en 50. No sé qué tan robusto será
umbral = 50;

% identifico el minimo, donde cambia la pendiente
[m I] = min(perfil);

figure(1)
hold on
plot(perfil)
plot(I, m, 'go')

% separo las partes creciente y decreciente para ajustar
% esto no está andando
creciente_x = 1:I;
creciente_y = perfil(1:I);

decreciente_x = I+1:numel(perfil);
decreciente_y = perfil(I+1:end);

% descarto el pico que me quedó a la izquierda
% x > 150. En general?
% descarto los puntos que valen 0. Deberian existir?
% Estará muy bajo el tiempo de exposición?
% datos_x = [];
% datos_y = [];
% 
% for i = 150:numel(perfil)
%     if perfil(i) ~= 0
%         datos_x = [datos_x i];
%         datos_y = [datos_y perfil(i)];
%     end
% end

I_descarte = 150

creciente_x_limpio = [];
creciente_y_limpio = [];

for i = I_descarte:numel(creciente_y)
    if creciente_y(i) ~= 0
        creciente_x_limpio = [creciente_x_limpio i];
        creciente_y_limpio = [creciente_y_limpio creciente_y(i)];
    end
end

decreciente_x_limpio = [];
decreciente_y_limpio = [];

for i = 1:numel(decreciente_y)
    if decreciente_y(i) ~= 0
        decreciente_x_limpio = [decreciente_x_limpio decreciente_x(i)];
        decreciente_y_limpio = [decreciente_y_limpio decreciente_y(i)];
    end
end

% ajusto cada parte por una recta
% p_creciente = polyfit(creciente_x_limpio, creciente_y_limpio, 1);
% recta_creciente = polyval(p_creciente, creciente_x_limpio);

% parece que tengo una resolucion de varios pixeles (??)
figure(1)
plot(perfil, '-b')
hold on
%plot(datos_x, datos_y, 'or')
plot(I, m, 'g*')
plot(creciente_x_limpio, creciente_y_limpio, 'c.')
plot(decreciente_x_limpio, decreciente_y_limpio, 'm.')
%plot(creciente_x_limpio, recta_creciente, 'c--')
xlim([700 1300])