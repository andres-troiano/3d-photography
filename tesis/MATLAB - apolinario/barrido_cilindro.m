imaqreset
clear variables

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
tol = 1e-3;

set(0,'DefaultFigureVisible', 'on')

%%

mover_stage_2(socketID, group_y, positioner_y, 500, tol);
mover_stage_2(socketID, group_x, positioner_x, 200, tol);

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
set(src1, 'ExposureTime', 200);
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
set(src2, 'ExposureTime', 200);
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
set(src1, 'AoiThreshold', 100);

%%

% para medir 34700030
x_min = 0;
x_max = 350;
y_min = 350;
y_max = 600;

paso = 50;

particion_x = x_min:paso:x_max;
particion_y = y_min:paso:y_max;
% 
mover_stage_2(socketID, group_y, positioner_y, 350, tol);
mover_stage_2(socketID, group_x, positioner_x, 350, tol);
% 
close all
    
frame = getsnapshot(camara1);
perfil = median(frame);
perfil = double(perfil)/2^4;

figure(1)
plot(perfil, '.-')
% imagesc(frame)

%%
 
for i = 1:1e6
    
    frame = getsnapshot(camara1);
    perfil = median(frame);
    perfil = double(perfil)/2^4;

    figure(1)
    plot(perfil, '.-')
    
%     xlim([700, 1400])   
%     ylim([600, 400])
    
end

%%

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion26\';

mkdir([path_datos patron '\camara_1'])
mkdir([path_datos patron '\camara_2'])

% uso los mismos puntos para ambas cámaras, así que es un solo archivo
output_file = fopen( [path_datos patron '\coord_pedidas_vs_medidas.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

pause on

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
        
        % creo que con esperar al 2do estaría esperando al 1ro también
% %         pause(15)
%         pause(12)
        
        [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
        [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        
        % cámara 1
        frame = getsnapshot(camara1);
        
        tag = sprintf('LUT_camara_1_frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
        
        imwrite(frame, [path_datos patron '\' patron '_camara_' camara '_x_' num2str(x) '_y_' num2str(y) '.png'], 'PNG');
        
%         cámara 2
        frame = getsnapshot(camara2);
        
        imwrite(frame, [path_datos patron '\' patron '_camara_' camara '_x_' num2str(x) '_y_' num2str(y) '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;

%%

% Close connection
TCP_CloseSocket(socketID);