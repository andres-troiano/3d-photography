imaqreset
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion16\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
tol = 1e-3;

set(0,'DefaultFigureVisible', 'on')

%%

mover_stage_2(socketID, group_y, positioner_y, 400, tol);
mover_stage_2(socketID, group_x, positioner_x, 600, tol);

%%

% seteo cámaras
camara1 = videoinput('gige', 1, 'Mono16');
src1 = getselectedsource(camara1);

% la cámara vieja sólo funciona en 16 bits, pero no acepta que se lo pongas
% en el comando
camara2 = videoinput('gige', 2);
src2 = getselectedsource(camara2);

% triggerconfig(camara1, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
% src1.ProfileTriggerMode = 'CameraInput2';
% 
% triggerconfig(camara2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
% src2.ProfileTriggerMode = 'CameraInput2';

% no sé si hace falta esto. Quiero controlar el láser viejo con LightDevice0LightSource
% triggerconfig(camara1, 'immediate');
% triggerconfig(camara2, 'immediate');

set(src1, 'CameraMode', 'CenterOfGravity');
set(src1, 'ReverseY', 'True');
set(src1, 'ExposureTime', 300);
set(src1, 'EnableDC2', 'True');
set(src1, 'EnableDC0', 'False');
set(src1, 'EnableDC0Shift', 'False');
set(src1, 'EnableDC1', 'False');
set(src1, 'FramePeriod', 3000);
set(src1, 'ProfilesPerFrame', 50);
set(src1, 'PacketSize', 5000);


set(src2, 'CameraMode', 'CenterOfGravity');
set(src2, 'ReverseY', 'True');
set(src2, 'ExposureTime', 300);
set(src2, 'EnableDC2', 'True');%*
set(src2, 'EnableDC0', 'False');%*
set(src2, 'EnableDC0Shift', 'False');%*
set(src2, 'EnableDC1', 'False');
set(src2, 'FramePeriod', 3000);
set(src2, 'ProfilesPerFrame', 50);%*
set(src2, 'PacketSize', 5000);

set(src2, 'AoiThreshold', 100);
set(src2, 'ExposureTime', 2500);
set(src1, 'AoiThreshold', 100);
set(src1, 'ExposureTime', 2500);


% solo el laser nuevo
set(src1, 'LightDevice0LightSource', 'Off')
set(src2, 'LightDevice0LightBrightness', 100);
set(src2, 'LightDevice0LightSource', 'On');
%%

% punto que ven las 2
mover_stage_2(socketID, group_y, positioner_y, 390, tol);
mover_stage_2(socketID, group_x, positioner_x, 200, tol);

close all
    
frame = getsnapshot(camara2);
perfil = median(frame);
perfil = double(perfil)/2^4;

figure(1)
plot(perfil, '.-')

% imwrite(frame, [path 'frame_camara_2_laser_2.png'], 'PNG');

%%

camara = '2';

set(0,'DefaultFigureVisible', 'on');
close all

list = dir([path 'frame_camara_' camara '*.png']);
fnames = {list.name};

N = numel(fnames);

punta_x_array = [0, 0];
punta_y_array = [0, 0];

for i = 1:N
    
    filename = fnames{i};
    filename = [path filename];

    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    perfil_x = 1:1:numel(perfil);
    
    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);
    
    
    
    
    
    [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_tuerca_inclinada(datos_x, datos_y, camara);
    
    punta_px = (b2 - b1)/(a1 - a2);
    punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

    [x_definitivo_1, y_definitivo_1, x_definitivo_2, y_definitivo_2, punta_definitiva_px, punta_definitiva_py] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_x_2, recta_1, recta_2, delta_1, delta_2, punta_px, a1, a2, b1, b2);

    
    punta_x_array(i) = punta_definitiva_px;
    punta_y_array(i) = punta_definitiva_py;
%     
%     filename
%     fprintf('Punta x = %.3f, Punta x = %.3f\n', punta_definitiva_px, punta_definitiva_py)
%     
    
%     close all
%     h = figure(1);
    figure
    hold on
    plot(perfil, '.-k')

    plot(datos_x_1, datos_y_1, '.b')
    plot(datos_x_2, datos_y_2, '.r')

    plot(datos_x_1, recta_1, '--b')
    plot(datos_x_2, recta_2, '--r')
    plot(x_definitivo_1, y_definitivo_1, '.g')
    plot(x_definitivo_2, y_definitivo_2, '.y')

    plot(punta_definitiva_px, punta_definitiva_py, '*r')
    
    margen = 25;
    
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
    xlim([min(datos_x)-margen max(datos_x)+margen])
    ylim([min(datos_y)-margen max(datos_y)+margen])
    
end

camara
punta_x_array
punta_y_array