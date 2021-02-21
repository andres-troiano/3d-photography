imaqreset
clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion25\';

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

close all
    
frame = getsnapshot(camara2);
perfil_y = median(frame);
perfil_y = double(perfil_y)/2^4;

perfil_x = 1:1:numel(perfil_y);

[x, y] = tiro_datos_nulos_perfil(perfil_x, perfil_y);

figure(1)
hold on 

plot(perfil_x, perfil_y, '.-b')
plot(x, y, '.r')

%%

patron = '34700030';
camara = '1';

path_datos_0 = 'C:\Users\60069978\Documents\MATLAB\medicion25\';
path_datos = ['C:\Users\60069978\Documents\MATLAB\medicion25\' patron '\camara_' camara '\'];
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion23\';

load([path_calibracion 'calibration.mat']);
% POLINOMIOS

% cámara 1
polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

% cámara 2
polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

diametro_array = [];

nominal = 73.011;

close all
h = figure(1);
hold on
grid on

for i = 1:100
% for i = 1
    
    frame = getsnapshot(camara1);
    imwrite(frame, [path_datos patron '_camara_' camara '_frame_' num2str(i) '.png'], 'PNG');
    
    perfil_y = median(frame);
    perfil_y = double(perfil_y)/2^4;
    perfil_x = 1:1:numel(perfil_y);
    [x, y] = tiro_datos_nulos_perfil(perfil_x, perfil_y);
    
    [y, x, ~, ~] = filtro_valores_inusuales(y, x, 1, 3);
    [y, x, mediana, std_error] = filtro_valores_inusuales(y, x, -1, 3);
    
    x = x.';
    y = y.';
    
    x_mm = polyval4XY(polinomio_x_camara_2, x, y);
    y_mm = polyval4XY(polinomio_y_camara_2, x, y);
    
    % no filtrados, para comparar
    x_mm_0 = x_mm;
    y_mm_0 = y_mm;

    for j = 1:3
        
        XY = [x_mm y_mm];

        circulo = TaubinNTN(XY);

        centro_x = circulo(1);
        centro_y = circulo(2);
        radio = circulo(3);
        diametro = 2*radio;

        error = radio - sqrt((x_mm - centro_x).^2 + (y_mm - centro_y).^2);
        mean_error = mean(error);
        std_error = std(error);

        filtro = abs(error) < mean_error + 3*std_error & abs(error) > mean_error - 3*std_error;

        x_mm = x_mm(filtro);
        y_mm = y_mm(filtro);
               
    end
    
    diametro_array = [diametro_array diametro];
    plot(diametro_array, '.-b')
    
%     if diametro > 74.94
%         
%         figure(2)
%         plot(x_mm, y_mm, '.-')
%         
%         break
%     end
    
end

% title(patron)
% xlabel('Iteración')
% ylabel('Diámetro (mm)')
% saveas(h, [path_datos_0 'diametro_' patron '_camara_' camara], 'png');
% 
% [mean(diametro_array), std(diametro_array)]

% figure(2)
% hold on
% grid on
% plot(x_mm_0, y_mm_0, '.-b')
% plot(x_mm, y_mm, '.r')