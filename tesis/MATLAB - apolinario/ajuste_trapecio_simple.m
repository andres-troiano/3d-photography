frame = imread('C:\Users\60069978\Documents\MATLAB\scan\frame_trapecio.png');

perfil = median(frame);
perfil = double(perfil)/2^4;

datos_x = [];
datos_y = [];

for i = 1:numel(perfil)
    if perfil(i) ~= 0
        datos_x = [datos_x i];
        datos_y = [datos_y perfil(i)];
    end
end

% digo que la base está a más de 300 más arriba del mínimo
dist_trapecio_base = 300;

datos_x_temp = [];
datos_y_temp = [];

for i = 1:numel(datos_x)
    if datos_y(i) < min(datos_y) + dist_trapecio_base
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

datos_x = datos_x_temp;
datos_y = datos_y_temp;

% tiro unos pocos puntos al final, que pertenecen al flanco que va del
% trapecio a la mesa
% Podría verlos al ppio también
datos_x = datos_x(1:end-3);
datos_y = datos_y(1:end-3);

% en este caso, a ojo, tengo:
% el 1er punto en x = 285
% la 1er esquina en x = 547
% la 2da esquina en x = 1124

% la 1er recta mide 262
% la 2da 577
% la 3ra desde 839 hasta el final

% me armo 3 regiones de datos para ajustar
datos_x_1 = datos_x(1:200);
datos_y_1 = datos_y(1:200);

datos_x_2 = datos_x(350:750);
datos_y_2 = datos_y(350:750);

datos_x_3 = datos_x(900:end);
datos_y_3 = datos_y(900:end);

[pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
[pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);
[pol_3, S_3] = polyfit(datos_x_3, datos_y_3, 1);

[recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
[recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);
[recta_3, delta_3] = polyval(pol_3, datos_x_3, S_3);

% ahora calculo la posición de las esquinas por interseccion
a1 = pol_1(1);
b1 = pol_1(2);

a2 = pol_2(1);
b2 = pol_2(2);

a3 = pol_3(1);
b3 = pol_3(2);

x1 = (b2 - b1)/(a1 - a2);
y1 = a1*(b2 - b1)/(a1 - a2) + b1;

x2 = (b3 - b2)/(a2 - a3);
y2 = a2*(b3 - b2)/(a2 - a3) + b2;

x = [x1, x2];
y = [y1, y2];

figure(1)
hold on
plot(datos_x, datos_y, '.-')
% plot(datos_x_1, recta_1, '--r')
% plot(datos_x_2, recta_2, '--g')
% plot(datos_x_3, recta_3, '--b')
plot(x(1), y(1), '*r')
plot(x(2), y(2), '*r')

% ahora veo cuánto mide:
[x_real, y_real] = convertir_a_unidades_reales(x, y);

medida = norma(x_real, y_real)
