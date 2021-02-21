% el enfoque anterior no sirve.
% no logro distinguir el patrón con el método de ajustar y mirar la banda
% de error
% ahora voy a tratar de distinguirlo del soporte estimando a qué distancia
% está el patrón del soporte y dando ese número absoluto

imaqreset
clear classes
clear all
close all

% directorio donde voy a guardar los frames
path = 'C:\Users\60069978\Documents\MATLAB\scan\';

camara = videoinput('gige', 1);

src = getselectedsource(camara);

set(src, 'CameraMode', 'CenterOfGravity');
set(src, 'ReverseY', 'True');
set(src, 'ExposureTime', 300);
set(src, 'EnableDC2', 'True');
set(src, 'EnableDC0', 'False');
set(src, 'EnableDC0Shift', 'False');
set(src, 'EnableDC1', 'False');
set(src, 'FramePeriod', 3000);
set(src, 'AoiThreshold', 130);
set(src, 'LightDevice0LightBrightness', 100);
set(src, 'LightDevice0LightSource', 'ExposureActive');
set(src, 'ProfilesPerFrame', 50);
set(src, 'PacketSize', 5000);

%%

frame = getsnapshot(camara);

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

% digo que el soporte está en un más menos 30 respecto del primer punto
dist_patron_soporte = 30;

datos_x_temp = [];
datos_y_temp = [];

for i = 1:numel(datos_x)
    if (datos_y(i) > datos_y(1) - dist_patron_soporte) && (datos_y(i) < datos_y(1) + dist_patron_soporte)
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

datos_x = datos_x_temp;
datos_y = datos_y_temp;

% hago un ajuste para tirar ruido ocasional
cant_sigmas = 3;

datos_x_temp = [];
datos_y_temp = [];

% ajusto
[pol, S] = polyfit(datos_x, datos_y, 1);
[recta, error] = polyval(pol, datos_x, S);

% tiro datos
for i = 1:numel(datos_x)
    if (datos_y(i) > recta(i) - cant_sigmas*error(i)) && (datos_y(i) < recta(i) + cant_sigmas*error(i))
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

% me quedo con los datos que me interesan
datos_x = datos_x_temp;
datos_y = datos_y_temp;

close all
figure(1)
hold on
plot(perfil, 'b.-')
plot(datos_x, datos_y, 'r.-')

% lo que identifiqué como patrón, lo transformo al mundo real, y luego
% ajusto para calcular la norma

lut = 'C:\Users\60069978\Documents\MATLAB\scan6\LUT.txt';

[x_real, y_real] = interpolacion_lut_funcion(lut, datos_x, datos_y);

% ahora ajusto para medir
[pol, S] = polyfit(x_real, y_real, 1);
[recta, error] = polyval(pol, x_real, S);

figure(2)
hold on
plot(x_real, y_real, '.-')
plot(x_real, recta, 'r--')

% se ve bastante chotex
medida = norma(x_real, recta);

medida_pixels = sqrt((datos_x(end) - datos_x(1))^2 + (datos_y(end) - datos_y(1))^2);

[medida, medida_pixels]

