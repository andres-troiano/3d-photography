imaqreset
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion49\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
tol = 1e-3;

set(0,'DefaultFigureVisible', 'on')

%%

mover_stage_2(socketID, group_y, positioner_y, 500, tol);
mover_stage_2(socketID, group_x, positioner_x, 600, tol);

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
set(src1, 'AoiThreshold', 75);

% para los hexágonos negros
set(src1, 'ExposureTime', 1000);
set(src2, 'ExposureTime', 2000);

% % para todo lo demás
% set(src1, 'ExposureTime', 200);
% set(src2, 'ExposureTime', 200);

%%

% set(src1, 'CameraMode', 'image');
% set(src2, 'CameraMode', 'image');

set(src1, 'ExposureTime', 1*1e3);
set(src2, 'ExposureTime', 2*1e3);

set(src1, 'AoiThreshold', 70);
set(src2, 'AoiThreshold', 95);

frame = getsnapshot(camara1);

% close all
% figure(1)
% imagesc(frame)

close all, figure, hold on, grid on
perfil = median(frame);
perfil = double(perfil)/2^4;
plot(perfil, '.-')

%%

% % patrón centrado
% x_min = 190;
% x_max = 210;
% y_min = 550;
% y_max = 570;

% % para calibrar trapecio inclinado 30º, y horizontal también
% x_min = 0;
% x_max = 300;
% y_min = 400;
% y_max = 500;

% set(src1, 'ExposureTime', 1250);
% set(src2, 'ExposureTime', 3*1e3);



% calibración con el hexágono 3 de zandalazini
x_min = 0;
x_max = 350;
y_min = 430;
y_max = 530;

paso = 5;

particion_x = x_min:paso:x_max;
particion_y = y_min:paso:y_max;
% 
mover_stage_2(socketID, group_y, positioner_y, 515, tol);
mover_stage_2(socketID, group_x, positioner_x, 180, tol);

close all
    
frame = getsnapshot(camara2);
perfil = median(frame);
perfil = double(perfil)/2^4;

figure(1)
hold on
grid on
plot(perfil, '.-')

axis equal
% xlim([800 1400])
% ylim([600 850])

% plot(1088 - perfil, '.-')
% imagesc(frame)

% imwrite(frame, [path 'misma_esquina_c2.png'], 'PNG');

%%

[~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
[~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
[pos_x pos_y]

%%

% mover_stage_2(socketID, group_y, positioner_y, 415, tol);
% mover_stage_2(socketID, group_x, positioner_x, 600, tol);

figure(1)
hold on
grid on

for i = 1:1e6
    
    frame = getsnapshot(camara2);
    perfil = median(frame);
    perfil = double(perfil)/2^4;
    
    plot(perfil, '.-')

    axis equal
%     xlim([800 1400])
%     ylim([600 850])
    
end

%%

% uso los mismos puntos para ambas cámaras, así que es un solo archivo
output_file = fopen( [path 'coord_pedidas_vs_medidas.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

N = numel(particion_x)*numel(particion_y);
k = 0;

for i=1:numel(particion_x)
    for j=1:numel(particion_y)
        
        k = k + 1;
        
        sprintf('Paso %d de %d', k, N)
        
        x = particion_x(i);
        y = particion_y(j);
        
%         SIEMPRE MOVERSE PRIMERO EN Y
        mover_stage_2(socketID, group_y, positioner_y, y, tol);
        mover_stage_2(socketID, group_x, positioner_x, x, tol);
        
        [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
        [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        
        % cámara 1
        frame = getsnapshot(camara1);
        
        tag = sprintf('LUT_camara_1_frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
        
        imwrite(frame, [path tag '.png'], 'PNG');
        
%         cámara 2
        frame = getsnapshot(camara2);
        tag = sprintf('LUT_camara_2_frame_x_%d_y_%d', x, y);
        
        imwrite(frame, [path tag '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;

%%

mover_stage_2(socketID, group_y, positioner_y, 0, tol);
mover_stage_2(socketID, group_x, positioner_x, 600, tol);

%% para medir el patrón en forma de corona

% path = 'C:\Users\60069978\Documents\MATLAB\temp\';
path = 'C:\Users\60069978\Documents\MATLAB\medicion45\';

x = 200;
y = 560;
radio = 6;
z = 50;

mover_stage_2(socketID, group_y, positioner_y, y, tol);
mover_stage_2(socketID, group_x, positioner_x, x, tol);
% 
close all
    
frame = getsnapshot(camara1);
perfil = median(frame);
perfil = double(perfil)/2^4;

% figure
% hold on
% grid on
% plot(perfil, '.-')

imwrite(frame, [path 'radio' num2str(radio) '\frame_corona_camara_1_x_' num2str(x) '_y_' num2str(y) '_radio_' num2str(radio) '_z_' num2str(z) '.png'], 'PNG');
% imwrite(frame, [path 'frame_corona_camara_1_x_' num2str(x) '_y_' num2str(y) '_radio_' num2str(radio) '_z_' num2str(z) '.png'], 'PNG');
% imwrite(frame, [path 'mismo_radio\frame_corona_camara_1_x_' num2str(x) '_y_' num2str(y) '_radio_' num2str(radio) '.png'], 'PNG');

frame = getsnapshot(camara2);
perfil = median(frame);
perfil = double(perfil)/2^4;

% figure
% hold on
% grid on
% plot(perfil, '.-')

imwrite(frame, [path 'radio' num2str(radio) '\frame_corona_camara_2_x_' num2str(x) '_y_' num2str(y) '_radio_' num2str(radio) '_z_' num2str(z) '.png'], 'PNG');
% imwrite(frame, [path 'mismo_radio\frame_corona_camara_2_x_' num2str(x) '_y_' num2str(y) '_radio_' num2str(radio) '.png'], 'PNG');

%% medición de la corona de manera continua

% para que se integre con el resto, esto tiene que guardar png. Me parece
% una mala idea, pero la otra opción es reescribir los scripts de análisis

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion46\';

% mover_stage_2(socketID, group_y, positioner_y, 550, tol);
% mover_stage_2(socketID, group_x, positioner_x, 200, tol);

N = 200; % cantidad de perfiles que voy a tomar en ppio

% perfiles = {nan(2048, N), nan(2048, N)}; % guardo los perfiles, separando camara 1 y 2
camaras = {camara1, camara2};

for i = 1:N
    
    i
    
    for q = 1:2
        frame = getsnapshot(camaras{q});
        perfil = median(frame);
%         % guardo los perfiles como columna
%         perfiles{q}(:, 1) = perfil;

        imwrite(frame, [path_datos 'hexagono_2_continuo_camara_' num2str(q) '_' num2str(i) '.png'], 'PNG');

    end

end

% save(fullfile(path, 'perfiles_continuo'),'perfiles')

%%

[~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
[~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
[pos_x pos_y]

%% medicion patron cilindrico

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion48\';

patron = '34700730';

% mover_stage_2(socketID, group_y, positioner_y, 515, tol);
% mover_stage_2(socketID, group_x, positioner_x, 180, tol);
camaras = {camara1, camara2};

close all
for q = 1:2
    frame = getsnapshot(camaras{q});
    figure,plot(median(frame))
%     imwrite(frame, [path_datos 'patron_' patron '_camara_' num2str(q) '.png'], 'PNG');
end

%%

% Close connection
TCP_CloseSocket(socketID);