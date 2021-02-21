% imaqreset
% clear variables
% 
% path = 'C:\Users\60069978\Documents\MATLAB\alineacion_trapecio\';
% 
% camara2 = videoinput('gige', 2);
% src2 = getselectedsource(camara2);
% 
% triggerconfig(camara2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
% src2.ProfileTriggerMode = 'CameraInput2';
% 
% set(src2, 'CameraMode', 'CenterOfGravity');
% set(src2, 'ReverseY', 'True');
% set(src2, 'ExposureTime', 200);
% set(src2, 'EnableDC2', 'True');%*
% set(src2, 'EnableDC0', 'False');%*
% set(src2, 'EnableDC0Shift', 'False');%*
% set(src2, 'EnableDC1', 'False');
% set(src2, 'FramePeriod', 3000);
% set(src2, 'LightDevice0LightBrightness', 100);
% set(src2, 'LightDevice0LightSource', 'ExposureActive');
% set(src2, 'ProfilesPerFrame', 50);%*
% set(src2, 'PacketSize', 5000);
% 
% set(src2, 'AoiThreshold', 100);
% 
% % UBICACIÓN DE LA PIEZA
% % convendría llamar a los stages acá
% 
% % orientación simétrica
% % x_stage = 75
% % y_stage = 500
% 
% % orientación horizontal
% % x_stage = 125
% % y_stage = 500


%%

path = 'C:\Users\60069978\Documents\MATLAB\alineacion_trapecio\';
basepath_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion27\';
load([basepath_calibracion 'calibration.mat']);

polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

close all
figure(1)

longitud = [];

for i = 1:100
% for i = 1
    
    frame = getsnapshot(camara2);

    % guardo 2 iguales para engañar el script. Considerar modificaciones
    % les doy coordenadas dummy
    imwrite(frame, [path 'camara_1\LUT_camara_1_frame_x_1_y_1.png'], 'PNG');
    imwrite(frame, [path 'camara_2\LUT_camara_2_frame_x_1_y_1.png'], 'PNG');

    % correr los scripts de martín, cargar los resultados y medir la norma de
    % las 2 esquinas

    % OJO CON EL PATH DE ESTO!
    convertFiles2DotMat

    % ESTO CAMBIA SEGÚN LA PIEZA ESTÁ HORIZONTAL O NO
    intersecciones_alineacion_trapecio_izq
    intersecciones_alineacion_trapecio_der

%     intersecciones_alineacion_trapecio_izq_simetrico
%     intersecciones_alineacion_trapecio_der_simetrico

    % cargo las intersecciones y mido la longitud
    load([path 'intersections_izq.mat']);
    C2_izq = C{2};

    load([path 'intersections_der.mat']);
    C2_der = C{2};

    punta_px_2_izq = C2_izq(1, 1);
    punta_py_2_izq = C2_izq(1, 2);

    punta_px_2_der = C2_der(1, 1);
    punta_py_2_der = C2_der(1, 2);
    
    
    
    punta_mm_x_2_izq = polyval4XY(polinomio_x_camara_2, punta_px_2_izq, punta_py_2_izq);
    punta_mm_y_2_izq = polyval4XY(polinomio_y_camara_2, punta_px_2_izq, punta_py_2_izq);

    punta_mm_x_2_der = polyval4XY(polinomio_x_camara_2, punta_px_2_der, punta_py_2_der);
    punta_mm_y_2_der = polyval4XY(polinomio_y_camara_2, punta_px_2_der, punta_py_2_der);

%     n = norma([punta_px_2_izq, punta_px_2_der], [punta_py_2_izq, punta_py_2_der]);
    n = norma([punta_mm_x_2_izq, punta_mm_x_2_der], [punta_mm_y_2_izq, punta_mm_y_2_der]);
    
    longitud = [longitud n];
    
    plot(longitud, '.-')
%     ylim([59.99 60.025])

end

% save(fullfile(basepath_calibracion,'longitud_trapecio.mat'),'longitud')

error = max(L) - min(L);

%%

L = load([basepath_calibracion 'longitud_trapecio.mat']);
L = L.longitud;

error = max(L) - min(L);
L_avg = mean(L);
sigma = std(L);

[L_avg, sigma]

close all
figure(1)

plot(L, '.-')

%%

% el trapecio está horizontal
% veo que hay un ruido importante en la longitud, teniendo el trapecio
% quieto en una misma alineación. Entonces tomo 100 frames para medir su
% longitud.
% Después de esto lo voy a poner a 30º para barrer. Eso puede modificar la
% alineación, con lo cual después, para relacionar los 2 sistemas de
% referencia, voy a tener que volver a hacer esto a ver cuánto cambió la
% longitud

for i = 1:100
    imwrite(frame, [path 'longitud_trapecio\camara_1\LUT_camara_1_frame_x_125_y_500_' num2str(i) '.png'], 'PNG');
    imwrite(frame, [path 'longitud_trapecio\camara_2\LUT_camara_2_frame_x_125_y_500_' num2str(i) '.png'], 'PNG');
end