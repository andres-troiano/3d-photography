clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion10\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
tol = 1e-3;

%%

% seteo cámaras
camara1 = videoinput('gige', 1, 'Mono16');
src1 = getselectedsource(camara1);

% la cámara vieja sólo funciona en 16 bits, pero no acepta que se lo pongas
% en el comando
camara2 = videoinput('gige', 2);
src2 = getselectedsource(camara2);

triggerconfig(camara1, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src1.ProfileTriggerMode = 'CameraInput2';

triggerconfig(camara2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src2.ProfileTriggerMode = 'CameraInput2';

set(src1, 'CameraMode', 'CenterOfGravity');
set(src1, 'ReverseY', 'True');
set(src1, 'ExposureTime', 300);
set(src1, 'EnableDC2', 'True');
set(src1, 'EnableDC0', 'False');
set(src1, 'EnableDC0Shift', 'False');
set(src1, 'EnableDC1', 'False');
set(src1, 'FramePeriod', 3000);
set(src1, 'LightDevice0LightSource', 'Off');
set(src1, 'ProfilesPerFrame', 50);
set(src1, 'PacketSize', 5000);


set(src2, 'CameraMode', 'CenterOfGravity');
set(src2, 'ReverseY', 'True');
set(src2, 'ExposureTime', 300);
set(src2, 'EnableDC2', 'True');
set(src2, 'EnableDC0', 'False');
set(src2, 'EnableDC0Shift', 'False');
set(src2, 'EnableDC1', 'False');
set(src2, 'FramePeriod', 3000);
set(src2, 'LightDevice0LightBrightness', 100);
set(src2, 'LightDevice0LightSource', 'ExposureActive');
set(src2, 'ProfilesPerFrame', 50);
set(src2, 'PacketSize', 5000);

set(src2, 'AoiThreshold', 100);
set(src2, 'ExposureTime', 2500);
set(src1, 'AoiThreshold', 100);
set(src1, 'ExposureTime', 2500);

%%

mover_stage_2(socketID, group_y, positioner_y, 600, tol);
mover_stage_2(socketID, group_x, positioner_x, 0, tol);

%%

for i = 1:1e6
    getsnapshot(camara2);
    pause(0.25)
end

%%

tag_patron = '34700730';
x = 200;
y = 550;

% x = 400;

mover_stage_2(socketID, group_y, positioner_y, y, tol);
mover_stage_2(socketID, group_x, positioner_x, x, tol);

pause on
pause(15)

% z = 1-21 (1, 6, 11, 16, 21)
z = 20;

% frame = getsnapshot(camara);
% perfil = median(frame);
% perfil = double(perfil)/2^4;
% 
% set(0,'DefaultFigureVisible', 'on');
% close all
% figure
% plot(perfil)

% en esta parte mido y guardo los frames

tag_x = num2str(x);
tag_y = num2str(y);
tag_z = num2str(z);

tag = ['frame_cilindro_' tag_patron '_x_' tag_x '_y_' tag_y '_z_' tag_z '.png'];

frame = getsnapshot(camara);
imwrite(frame, [path tag], 'PNG');

% esta parte la dejo para chequear en el momento que el frame es bueno

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

[y_min, indice_min] = min(datos_y);
x_min = datos_x(indice_min);

% uso que el reflejo de la base está a más de 300 pixels de lo más que
% alcanzo a ver del cilindro

dist = 300;

datos_x_temp = [];
datos_y_temp = [];

for i = 1:numel(datos_x)
    if datos_y(i) < min(datos_y) + dist
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

datos_x = datos_x_temp;
datos_y = datos_y_temp;

close all
figure(1)
hold on
grid on
%plot(perfil, '.b')
plot(datos_x, datos_y, '.b')
%plot(x_min, y_min, '*g')

%%

% Close connection
TCP_CloseSocket(socketID);