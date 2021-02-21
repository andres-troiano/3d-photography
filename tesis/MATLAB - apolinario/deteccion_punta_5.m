clear all
close all

% cargo un perfil que tenga ceros, para que el algoritmo los descarte
frame_1 = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_270_y_600.png');
frame_2 = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_290_y_460.png');
frame_3 = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_350_y_515.png');
frame_4 = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_390_y_460.png');
frame_5 = imread('C:\Users\60069978\Documents\MATLAB\frame_umbral_102_x_410_y_600.png');

perfil = median(frame_1);

% corrijo por el subpixel resolution
perfil = double(perfil)/2^4;

% primero tengo que identificar la region de interes
% solo necesito encontrar los indices
indice_1 = find(perfil, 1, 'first');

% chequeo que el indice 1 sea correcto, y no que haya agarrado un punto
% intermedio sobre el flanco ascendente.

% Esto en ppio no es muy robusto porque podría no haber simplemente un
% flanco ascendente, sino ruido
% Además necesitaria que esto itere todas las veces que sea necesario. Por
% ahora lo dejo así
if perfil(indice_1 + 1) > perfil(indice_1)
    indice_1 = indice_1 + 1;
end

indice_3 = find(perfil, 1, 'last');

% Me creo un par de vectores donde guardo las coordenadas de la punta
punta_x = [];
punta_y = [];

% yo quiero tirar los ceros que están entre indice 1 e indice 3
for i = indice_1:indice_3
    if perfil(i) ~= 0
        punta_y = [punta_y perfil(i)];
        punta_x = [punta_x i];
    end
end

% para encontrar el punto de quiebre, busco el minimo entre los dos indices
% anteriores

% ojo, el indice 2 está en el sist de coordenadas de la punta, no del
% perfil total
quiebre_y = min(punta_y); 
indice_2 = find(punta_y == quiebre_y);

% Con frame 2 encuentro 2 mínimos con el mismo valor, muy cerquita uno del
% otro. Para casos así propongo usar el primero para ajustar la
% decreciente, y el último para la creciente.
% Podrían presentarse casos más complicados.

% ajusto las dos caras de la punta

[p_decreciente, S_decreciente] = polyfit(punta_x(1:indice_2(1)), punta_y(1:indice_2(1)), 1);
[recta_decreciente, delta_decreciente] = polyval(p_decreciente, punta_x, S_decreciente);

[p_creciente, S_creciente] = polyfit(punta_x(indice_2(end):end), punta_y(indice_2(end):end), 1);
[recta_creciente, delta_creciente] = polyval(p_creciente, punta_x, S_creciente);

% Descarto puntos que caigan afuera de la banda de error.
% Uso 3 sigmas como umbral (en verdad no sé si son sigmas, porque no sé
% cómo las calculan)
% Por ahora lo hago una vez, puede ser que necesite iterar hasta converger

% para esto necesito tener discriminadas las 2 regiones por pendiente

% Hago la limpieza creando vectores nuevos, para evitar que al tirar cosas 
% el indice se pase del mínimo y empiece a evaluar cosas de la otra cara
punta_x_temp = [];
punta_y_temp = [];

for i = 1:indice_2(1)
    % si el punto está adentro de la banda, lo guardo en temp
    % Obs.: para ver si estoy adentro, necesito cumplir ambas condiciones.
    % Para ver si estaba afuera, me faltaba no cumplir con una
    
%     disp(sprintf('Coord y = %.2f', punta_y(i)));
%     disp(sprintf('Band inferior = %.2f', recta_decreciente(i) - 3*delta_decreciente(i)));
%     disp(sprintf('Banda superior = %.2f', recta_decreciente(i) + 3*delta_decreciente(i)));
%     disp();
    
    if (punta_y(i) > recta_decreciente(i) - 3*delta_decreciente(i)) && (punta_y(i) < recta_decreciente(i) + 3*delta_decreciente(i))
        punta_x_temp = [punta_x_temp punta_x(i)];
        punta_y_temp = [punta_y_temp punta_y(i)];
    end
end

% close all
% figure(1)
% hold on
% plot(punta_x_temp, punta_y_temp, '.-b')
% plot(punta_x_temp(end), punta_y_temp(end), '*r')

for i = indice_2(end):numel(punta_x)
    if (punta_y(i) > recta_creciente(i) - 3*delta_creciente(i)) && (punta_y(i) < recta_creciente(i) + 3*delta_creciente(i))
        punta_x_temp = [punta_x_temp punta_x(i)];
        punta_y_temp = [punta_y_temp punta_y(i)];
    end
end

% recalculo el mínimo, sin los puntos no deseados
quiebre_y = min(punta_y_temp); 
indice_2 = find(punta_y_temp == quiebre_y);

% y vuelvo a ajustar
[p_decreciente, S_decreciente] = polyfit(punta_x_temp(1:indice_2), punta_y_temp(1:indice_2), 1);
[recta_decreciente, delta_decreciente] = polyval(p_decreciente, punta_x_temp, S_decreciente);

[p_creciente, S_creciente] = polyfit(punta_x_temp(indice_2:end), punta_y_temp(indice_2:end), 1);
[recta_creciente, delta_creciente] = polyval(p_creciente, punta_x_temp, S_creciente);

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
plot(perfil, '.-b')
plot(punta_x_temp, punta_y_temp, '.-r')
% plot(400, quiebre_y, 'y*')
% plot(indice_1, perfil(indice_1), '*r')
% plot(punta_x_temp(indice_2), punta_y_temp(indice_2), '*g')
% plot(indice_3, perfil(indice_3), '*c')
% plot(punta_x, punta_y, '.-r')
plot(punta_x_temp, [recta_decreciente; recta_decreciente + delta_decreciente; recta_decreciente - delta_decreciente], 'k--')
plot(punta_x_temp, [recta_creciente; recta_creciente + delta_creciente; recta_creciente - delta_creciente], 'k--')
plot(x_0, y_0, 'r.')