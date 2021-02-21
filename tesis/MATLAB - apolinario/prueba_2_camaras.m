imaqreset
clear variables

camara1 = videoinput('gige', 1, 'Mono16');
% camara1 = videoinput('gige', 1, 'Mono8');
src1 = getselectedsource(camara1);

% la cámara vieja sólo funciona en 16 bits, pero no acepta que se lo pongas
% en el comando
camara2 = videoinput('gige', 2);
src2 = getselectedsource(camara2);

%%

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
tol = 1e-3;

mover_stage_2(socketID, group_y, positioner_y, 400, tol);
mover_stage_2(socketID, group_x, positioner_x, 120, tol);

%%

triggerconfig(camara1, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src1.ProfileTriggerMode = 'CameraInput2';

triggerconfig(camara2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src2.ProfileTriggerMode = 'CameraInput2';

%%

% 100 parece ser un buen valor para la punta negra
% para el patrón plateado en cambio es mejor 120

threshold = 102;

set(src1, 'CameraMode', 'CenterOfGravity');
set(src1, 'ReverseY', 'True');
set(src1, 'ExposureTime', 300);
set(src1, 'EnableDC2', 'True');
set(src1, 'EnableDC0', 'False');
set(src1, 'EnableDC0Shift', 'False');
set(src1, 'EnableDC1', 'False');
set(src1, 'FramePeriod', 3000);
set(src1, 'AoiThreshold', threshold);
% set(src1, 'LightDevice0LightBrightness', 100);
set(src1, 'LightDevice0LightSource', 'Off');
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
set(src2, 'AoiThreshold', threshold);
set(src2, 'LightDevice0LightBrightness', 100);
set(src2, 'LightDevice0LightSource', 'ExposureActive');
set(src2, 'ProfilesPerFrame', 50);%*
set(src2, 'PacketSize', 5000);

%%

set(src2, 'LightDevice0LightSource', 'On');

close all

frame = getsnapshot(camara1);
perfil = median(frame);
perfil = double(perfil)/2^4;

plot(perfil, '.-')

% set(src2, 'CameraMode', 'Image');
% 
% frame = getsnapshot(camara2);
% imagesc(frame)
% 
% %%
% 
% set(src1, 'CameraMode', 'Image');
% 
% frame = getsnapshot(camara1);
% imagesc(frame)
% 
% %%
% 
% close all
% 
% threshold = 100;
% 
% set(src2, 'CameraMode', 'CenterOfGravity');
% set(src2, 'AoiThreshold', threshold);
% set(src2, 'ExposureTime', 100000);
% 
% frame = getsnapshot(camara2);
% perfil = median(frame);
% perfil = double(perfil)/2^4;
% 
% plot(perfil, '.-')
% 
% %%
% 
% close all
% 
% threshold = 100;
% 
% set(src1, 'CameraMode', 'CenterOfGravity');
% set(src1, 'AoiThreshold', threshold);
% set(src1, 'ExposureTime', 100000);
% 
% frame = getsnapshot(camara1);
% perfil = median(frame);
% perfil = double(perfil)/2^4;
% 
% plot(perfil, '.-')
% 
%%

TCP_CloseSocket(socketID);