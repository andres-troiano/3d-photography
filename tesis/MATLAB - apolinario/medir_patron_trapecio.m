% imaqreset
% clear classes
% clear all
% close all
% 
% % directorio donde voy a guardar los frames
% path = 'C:\Users\60069978\Documents\MATLAB\scan\';
% 
% camara = videoinput('gige', 1);
% 
% src = getselectedsource(camara);
% 
% set(src, 'CameraMode', 'CenterOfGravity');
% set(src, 'ReverseY', 'True');
% set(src, 'ExposureTime', 300);
% set(src, 'EnableDC2', 'True');
% set(src, 'EnableDC0', 'False');
% set(src, 'EnableDC0Shift', 'False');
% set(src, 'EnableDC1', 'False');
% set(src, 'FramePeriod', 3000);
% set(src, 'AoiThreshold', 102);
% set(src, 'LightDevice0LightBrightness', 100);
% set(src, 'LightDevice0LightSource', 'ExposureActive');
% set(src, 'ProfilesPerFrame', 50);
% set(src, 'PacketSize', 5000);
% 
% %%
% 
% frame = getsnapshot(camara);
% 
% imwrite(frame, [path 'patron.png'], 'PNG');

%%

frame = imread([path 'patron.png']);

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

%%

umbral = 950;

datos_x_temp = [];
datos_y_temp = [];

for i = 1:numel(datos_y)
    if datos_y(i) < 950
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

datos_x = datos_x_temp;
datos_y = datos_y_temp;

%%

X0 = [-0.6, 0.025, 0.6, 1050, 580, 1150];
% X1 = [-0.6, 0, 0.6, 1057.3, 577, 1145];
% X2 = [-0.6, 0.025, 0.6, 1057.3, 577, 1145];

f = @(x)cuadrados_trapecio(x, datos_x, datos_y);
[x, fval] = fminsearch(f, X0);

[x_ajuste, y_ajuste] = trapecio_2(x, datos_x);

close all
figure(1)
hold on
%plot(datos_x, datos_y, '.-')
plot(x_ajuste, y_ajuste, '-.r')

% convierto el ajuste a las unidades reales
[x_ajuste_real, y_ajuste_real] = convertir_a_unidades_reales(x_ajuste, y_ajuste);

medida = norma(x_ajuste_real, y_ajuste_real)