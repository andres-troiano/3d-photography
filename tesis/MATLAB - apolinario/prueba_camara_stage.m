%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hacer try catch para errores del stage, y de pérdida de conexión con la
% cámara
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear classes
clear all
close all

camara = gigecam(1);

% camara = videoinput('gige', 1);


%%

% src = getselectedsource(camara);
% 
% set(src, 'CameraMode', 'CenterOfGravity');
% set(src, 'ReverseY', 'True');
% set(src, 'ExposureTime', 1000);
% set(src, 'EnableDC2', 'True');
% set(src, 'EnableDC0', 'False');
% set(src, 'EnableDC0Shift', 'False');
% set(src, 'EnableDC1', 'False');
% set(src, 'FramePeriod', 3000);
% set(src, 'AoiThreshold', 90);
% % set(src, 'LightDevice0LightSource', 'ExposureActive');
% set(src, 'LightDevice0LightSource', 'On');
% set(src, 'ProfilesPerFrame', 50);
% set(src, 'PacketSize', 5000);

set(camara, 'CameraMode', 'CenterOfGravity');
set(camara, 'ProfilesPerFrame', 50);
set(camara, 'ReverseY', 'True');
set(camara, 'LightBrightness', 100);
set(camara, 'ExposureTime', 300);
set(camara, 'PixelFormat', 'Mono16');
set(camara, 'EnableDC2', 'True');
set(camara, 'EnableDC0', 'False');
set(camara, 'EnableDC1', 'False');
set(camara, 'FramePeriod', 3000);
set(camara, 'AoiThreshold', 100);
set(camara, 'LightSource', 'ExposureActive');
set(camara, 'GevSCPSPacketSize', 5000);

% set(camara, 'LightSource', 'On');
% set(camara, 'LightSource', 'Off');

%%

% 80 es el valor minimo, con exposure active
% con laser on, el valor minimo es 90
% ahora se clavo en 90 y no me deja cambiarla (?)

% esto esta andando de forma super inestable
% como si la intensidad medida fuera muy variable
% pero no creo que la luz ambiente pueda pesar lo mismo que el laser (?)
% ademas cada tanto demora infinito en disparar el laser y tomar la foto, y
% tira error de timeout
% sera que no siempre coincide el encendido del laser con el disparo de la
% camara?

% close all

% tiene profiles per frame = 50, pero me devuelve 150 filas (??)

foto = snapshot(camara);
% foto = getsnapshot(camara);
perfil = median(foto);
figure(1)
plot(perfil, '.-');

%imwrite(foto, 'C:\Users\60069978\Pictures\punta.png', 'PNG');

% set(src, 'CameraMode', 'Image');
% foto2 = getsnapshot(camara);
% figure(2)
% imagesc(foto2);

% set(camara, 'CameraMode', 'Image');
% foto2 = snapshot(camara);
% figure(2)
% imagesc(foto2);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the library
xps_load_drivers ;

% Set connection parameters
IP = '192.168.1.254' ;
Port = 5001 ;
TimeOut = 60.0 ;

% Connect to XPS
socketID = TCP_ConnectToServer (IP, Port, TimeOut) ;

% Check connection
if (socketID < 0)
    disp 'Connection to XPS failed, check IP & Port' ;
    return ;
end

%%

% EJE X
%%%%%%%

% define positioner X
% esto es la tarjeta a la que conecté el stage
group_x = 'Group1' ;
positioner_x = 'Group1.Pos' ;

% kill group X
[errorCode] = GroupKill(socketID, group_x) ;

if (errorCode ~= 0)
    disp (['Error ' num2str(errorCode) ' occurred while doing GroupKill ! ']) ;
    return ;
end

% initialize group X
[errorCode] = GroupInitialize(socketID, group_x) ; 

if (errorCode ~= 0)
    disp (['Error ' num2str(errorCode) ' occurred while doing GroupInitialize ! ']) ;
    return ;
end

% home search X
[errorCode] = GroupHomeSearch(socketID, group_x) ;

if (errorCode ~= 0)
    disp (['Error ' num2str(errorCode) ' occurred while doing GroupHomeSearch ! ']) ;
    return ;
end

%%

% EJE Y
%%%%%%%

% Define positioner Y
group_y = 'Group3' ;
positioner_y = 'Group3.Pos' ;

% kill group Y
[errorCode] = GroupKill(socketID, group_y) ;

if (errorCode ~= 0)
    disp (['Error ' num2str(errorCode) ' occurred while doing GroupKill ! ']) ;
    return ;
end

% initialize group Y
[errorCode] = GroupInitialize(socketID, group_y) ; 

if (errorCode ~= 0)
    disp (['Error ' num2str(errorCode) ' occurred while doing GroupInitialize ! ']) ;
    return ;
end

% home search group Y
[errorCode] = GroupHomeSearch(socketID, group_y) ;

if (errorCode ~= 0)
    disp (['Error ' num2str(errorCode) ' occurred while doing GroupHomeSearch ! ']) ;
    return ;
end

%%

% límites y: 460, 600. Lo que limita es el CCD, obviamente
% centro y: 515 aprox

% Límites x. Dependen de la altura
% para y = 460
% x = 290, 390

% para y = 600
% x = 270, 410

% Saco fotos en las 4 esquinas y en el centro

umbral = 102;
set(camara, 'AoiThreshold', umbral);

%%

y = 515;
x = 350;

frame_name = sprintf('frame_umbral_%d_x_%d_y_%d.png', umbral, x, y);
perfil_name = sprintf('perfil_umbral_%d_x_%d_y_%d.png', umbral, x, y);

[errorCode] = GroupMoveAbsolute(socketID, positioner_x, x);
[errorCode] = GroupMoveAbsolute(socketID, positioner_y, y);

close all
frame = snapshot(camara);
perfil = median(frame);
h = figure(1);
plot(perfil, '.-');

imwrite(frame, ['C:\Users\60069978\Documents\MATLAB\' frame_name], 'PNG');
saveas(h, ['C:\Users\60069978\Documents\MATLAB\' perfil_name], 'png');

% veo mucho ruido por el reflejo sobre la mesa
% podría poner un filtro, o subir el threshold y esperar que el ruido sea
% menos intenso. Para separarlos más puedo ponerle blanco al objetivo

% con thrsh = 102 parece andar impecable

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [errorCode] = GroupMoveAbsolute(socketID, positioner_y, 600);
% [errorCode] = GroupMoveAbsolute(socketID, positioner_x, 350);
% 
% foto = snapshot(camara);
% figure(1)
% imagesc(foto);
% 
% imwrite(foto, 'C:\Users\60069978\Pictures\punta.png', 'PNG');

%%

% recorro la grilla
% en cada punto saco una foto e identifico la interseccion de las dos
% rectas



%%

% me muevo por una grilla cuadrada y hago un print en cada punto
pos_min = 20;
pos_max = 100;

puntos = linspace(20, 100, 9);

% ubico los dos posicionadores en 0
[errorCode] = GroupMoveAbsolute(socketID, positioner_x, 0); 
[errorCode] = GroupMoveAbsolute(socketID, positioner_y, 0); 

for i=1:numel(puntos) 
    for j=1:numel(puntos)
        
        x = puntos(i);
        y = puntos(j);
        
        % me muevo en x
        [errorCode] = GroupMoveAbsolute(socketID, positioner_x, x); 

        % me muevo en y
        [errorCode] = GroupMoveAbsolute(socketID, positioner_y, y);
        
        % ejecuto una accion
        disp(sprintf('Estoy en (%d, %d)', x, y));
        
    end   
end

%%

[errorCode] = GroupMoveAbsolute(socketID, positioner_x, 0); 
[errorCode] = GroupMoveAbsolute(socketID, positioner_y, 0); 

% Close connection
TCP_CloseSocket(socketID) ;