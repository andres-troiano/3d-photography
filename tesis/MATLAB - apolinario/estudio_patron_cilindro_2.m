clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion10\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
camara = setup_camara(102);

tol = 1e-3;

%%

mover_stage_2(socketID, group_y, positioner_y, 600, tol);
mover_stage_2(socketID, group_x, positioner_x, 400, tol);

%%

% for i = 1:1000
%     frame = getsnapshot(camara);
%     perfil = median(frame);
%     perfil = double(perfil)/2^4;
%     
%     plot(perfil, '.-')
%     
%     pause(0.5)
% end

%%

% para el patrón 4700130
% limites x = 410, 460
%         y = 540, 600
%         z = 11, 31 (11, 16, 21, 26, 31)

% patrón 4700530
% z = 36-16 (16, 21, 26, 31, 36)
% x_min = 410;
% x_max = 450;
% y_min = 600;
% y_max = 600;

% patrón 4700530
% z = 36-16 (16, 21, 26, 31, 36)
% x_min = 400;
% x_max = 470;
% y_min = 520;
% y_max = 600;

% patrón 4700730
% z = 9, 14, 20
% x = 410;
% y = 550;

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