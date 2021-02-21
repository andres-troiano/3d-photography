imaqreset
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
tol = 1e-3;

mover_stage_2(socketID, group_y, positioner_y, 600, tol);
mover_stage_2(socketID, group_x, positioner_x, 300, tol);
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
set(src2, 'ExposureTime', 2500);
set(src1, 'AoiThreshold', 100);
set(src1, 'ExposureTime', 2500);
%%

% camara vieja
% ymin = 300
% ymax = 500
% xmin = 90
% xmax = 180

% camara nueva
% ymin = 280
% ymax = 400
% xmin = 70
% xmax = 260

% es complicado definir una región
% a x = 170 (más o menos la mitad del rango)
% ymin = 260        xmin = 130
% ymax = 360        xmax = 170

y_min_2 = 300;
y_max_2 = 500;
x_min_2 = 90;
x_max_2 = 180;

y_min_1 = 260;
y_max_1 = 360;
x_min_1 = 130;
x_max_1 = 170;

paso = 10;

particion_x_1 = x_min_1:paso:x_max_1;
particion_y_1 = y_min_1:paso:y_max_1;

particion_x_2 = x_min_2:paso:x_max_2;
particion_y_2 = y_min_2:paso:y_max_2;

% mover_stage_2(socketID, group_y, positioner_y, y_max_2, tol);
% mover_stage_2(socketID, group_x, positioner_x, x_max_2, tol);
% 
% close all
% 
% frame = getsnapshot(camara2);
% perfil = median(frame);
% perfil = double(perfil)/2^4;
% 
% figure(1)
% plot(perfil, '.-')

%%

% for i = 1:1000
%     getsnapshot(camara);
% end

%%

% CALIBRACIÓN CÁMARA 1

output_file = fopen( [path 'coord_pedidas_vs_medidas_camara_1.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

pause on

N = numel(particion_x_1)*numel(particion_y_1);
k = 0;

for i=1:numel(particion_x_1) 
    for j=1:numel(particion_y_1)
        
        k = k + 1;
        
        sprintf('Paso %d de %d', k, N)
        
        x = particion_x_1(i);
        y = particion_y_1(j);
        
%         SIEMPRE MOVERSE PRIMERO EN Y
        mover_stage_2(socketID, group_y, positioner_y, y, tol);
        mover_stage_2(socketID, group_x, positioner_x, x, tol);
        
        % creo que con esperar al 2do estaría esperando al 1ro también
        pause(15)
        
        [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
        [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        
        % saco una foto
        frame = getsnapshot(camara1);
        
        tag = sprintf('LUT_camara_1_frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
        
        imwrite(frame, [path tag '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;

%%

% CALIBRACIÓN CÁMARA 2

output_file = fopen( [path 'coord_pedidas_vs_medidas_camara_2.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

tol = 1e-3;
pause on

N = numel(particion_x_2)*numel(particion_y_2);
k = 0;

for i=1:numel(particion_x_2) 
    for j=1:numel(particion_y_2)
        
        k = k + 1;
        
        sprintf('Paso %d de %d', k, N)
        
        x = particion_x_2(i);
        y = particion_y_2(j);
        
%         SIEMPRE MOVERSE PRIMERO EN Y
        mover_stage_2(socketID, group_y, positioner_y, y, tol);
        mover_stage_2(socketID, group_x, positioner_x, x, tol);
        
        % creo que con esperar al 2do estaría esperando al 1ro también
        pause(15)
        
        [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
        [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        
        % saco una foto
        frame = getsnapshot(camara2);
        
        tag = sprintf('LUT_camara_2_frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
        
        imwrite(frame, [path tag '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;
%%

% Close connection
TCP_CloseSocket(socketID);