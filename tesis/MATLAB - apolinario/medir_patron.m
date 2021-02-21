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
set(src, 'AoiThreshold', 102);
set(src, 'LightDevice0LightBrightness', 100);
set(src, 'LightDevice0LightSource', 'ExposureActive');
set(src, 'ProfilesPerFrame', 50);
set(src, 'PacketSize', 5000);

frame = getsnapshot(camara);

imwrite(frame, [path 'patron.png'], 'PNG');

%%

perfil = median(frame);
perfil = double(perfil)/2^4;

% tiro los ceros
% Obs.: no me importa conservar la posición en x, porque sólo voy a medir
% el largo del objeto, no dónde está ubicado
% Sí me importa, porque lo que tengo tabulado es un cierto rango de pixels
datos_x = [];
datos_y = [];

for i = 1:numel(perfil)
    if perfil(i) ~= 0
        datos_x = [datos_x i];
        datos_y = [datos_y perfil(i)];
    end
end

% a mano me quedo con los puntos que me interesan en este caso
patron_x = [];
patron_y = [];

%%

umbral = 580;

for i = 1:numel(datos_y)
    if datos_y(i) < umbral
        patron_x = [patron_x datos_x(i)];
        patron_y = [patron_y datos_y(i)];
    end
end

% tiro los rebordes
dominio = patron_x;

[pol, S] = polyfit(dominio, patron_y, 1);
[recta, error] = polyval(pol, dominio, S);

dominio_temp = [];
patron_temp = [];

for i = 1:numel(dominio)
    if (patron_y(i) > recta(i) - 3*error(i)) && (patron_y(i) < recta(i) + 3*error(i))
        dominio_temp = [dominio_temp dominio(i)];
        patron_temp = [patron_temp patron_y(i)];
    end
end

% close all
% figure(1)
% hold on
% plot(perfil, '.-')
% plot(datos_x, datos_y, '.-')
% plot(patron_x, patron_y, '.-')
% plot(dominio, [recta; recta + error; recta - error], 'r--')
% plot(dominio_temp, patron_temp, 'g.-')

%%

lut = 'C:\Users\60069978\Documents\MATLAB\scan6\LUT.txt';

datos_y = importdata(lut, '\t', 1);
datos_y = datos_y.data;

x = datos_y(:, 1);
y = datos_y(:, 2);
px = datos_y(:, 3);
py = datos_y(:, 4);

% Interpolo Y en función de px, py
%%%%%%%%%%%%%
F_y = scatteredInterpolant(px, py, y, 'natural');

% evalúo el interpolador en mis datos
pxq = dominio_temp;
pyq = patron_temp;

y_real = F_y(pxq, pyq);

% Interpolo X en función de px, py
%%%%%%%%%%%%%
F_x = scatteredInterpolant(px, py, x, 'natural');

x_real = F_x(pxq, pyq);

%%

figure(2)
plot(x_real, y_real, '.-')

%%

% para medir el objeto, ajusto y calculo la norma
[pol, S] = polyfit(x_real, y_real, 1);
[recta, error] = polyval(pol, x_real, S);

% close all
% figure(3)
% plot(x_real, recta, '.-')

x_0 = x_real(1);
y_0 = recta(1);
x_1 = x_real(end);
y_1 = recta(end);

norma = sqrt((x_1 - x_0)^2 + (y_1 - y_0)^2)