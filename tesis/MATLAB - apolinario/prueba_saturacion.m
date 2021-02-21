clear variables
set(0,'DefaultFigureVisible', 'on')
imaqreset

% la cámara vieja sólo funciona en 16 bits, pero no acepta que se lo pongas
% en el comando
camara2 = videoinput('gige', 2);
src2 = getselectedsource(camara2);

%%

set(src2, 'ExposureMode', 'Timed');

%%

triggerconfig(camara2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src2.ProfileTriggerMode = 'CameraInput2';

set(src2, 'CameraMode', 'Image');
set(src2, 'ReverseY', 'True');
set(src2, 'ExposureTime', 300);
set(src2, 'EnableDC2', 'True');%*
set(src2, 'EnableDC0', 'False');%*
set(src2, 'EnableDC0Shift', 'False');%*
set(src2, 'EnableDC1', 'False');
set(src2, 'FramePeriod', 3000);
set(src2, 'LightDevice0LightBrightness', 100);
set(src2, 'LightDevice0LightSource', 'ExposureActive');
set(src2, 'ProfilesPerFrame', 50);%*
set(src2, 'PacketSize', 5000);

set(src2, 'AoiThreshold', 100);
set(src2, 'ExposureTime', 300);

%%

% src2.MultipleSlopeMode = 'DualSlope';
% src2.ExposureSlopeKneePointCount = 1;
% src2.ExposureSlopeDuration = 60;
% src2.ExposureMode = 'MultiSloped';

src2.ExposureSlopeKneePointCount = 2;
src2.ExposureSlopeThreshold = 20;

close all

frame = getsnapshot(camara2);

figure(1)
imagesc(frame)

figure(2)
hold on

plot(frame(:, 1265))
plot(frame(:, 950))

%%

% vemos qué pendientes tenemos que usar
basepath = 'C:\Users\60069978\Documents\MATLAB\medicion21\';

camara = '2';

src2.MultipleSlopeMode = 'SingleSlope';

tiempo_exposicion = 20:10:500;

N = numel(tiempo_exposicion);

for i = 1:N
    set(src2, 'ExposureTime', tiempo_exposicion(i));
    frame = getsnapshot(camara2);
    
    tag = ['multislope_camara_' camara '_tiempo_' num2str(tiempo_exposicion(i)) '_us'];
    imwrite(frame, [basepath tag '.png'], 'PNG');
end

%%

foto = imread([basepath 'multislope_camara_' camara '_tiempo_' num2str(200) '_us.png']);

close all
figure(1)

imagesc(foto)

%%

set(src2, 'ExposureTime', 200);
% set(src2, 'CameraMode', 'CenterOfGravity');
set(src2, 'CameraMode', 'Image');
src2.MultipleSlopeMode = 'TripleSlope';

frame = getsnapshot(camara1);
perfil = median(frame);

close all
figure(1)

% plot(perfil)
imagesc(frame)