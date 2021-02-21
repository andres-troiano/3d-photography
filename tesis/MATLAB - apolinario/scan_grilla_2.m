% Load the library
xps_load_drivers ;

% Set connection parameters
IP = '192.168.0.254' ;
Port = 5001 ;
TimeOut = 10.0 ;

% Connect to XPS
socketID = TCP_ConnectToServer (IP, Port, TimeOut) ;

% Check connection
if (socketID < 0)
    disp 'Connection to XPS failed, check IP & Port' ;
    return ;
end

%%

imaqreset

% directorio donde voy a guardar los frames
path = 'C:\Users\60069978\Documents\MATLAB\scan\';

camara = videoinput('gige', 1);

src = getselectedsource(camara);

set(src, 'CameraMode', 'CenterOfGravity');
set(src, 'ReverseY', 'True');
set(src, 'ExposureTime', 300);
set(src, 'EnableDC2', 'True');
set(src, 'EnableDC0', 'False');
set(src, 'EnableDC0Shift', 'False');
set(src, 'EnableDC1', 'False');
set(src, 'FramePeriod', 3000);
% este parece ser un buen valor para la punta negra
% para el patrón plateado en cambio es mejor 120
set(src, 'AoiThreshold', 102);
set(src, 'LightDevice0LightBrightness', 100);
set(src, 'LightDevice0LightSource', 'ExposureActive');
set(src, 'ProfilesPerFrame', 50);
set(src, 'PacketSize', 5000);

%%

% EJE X
%%%%%%%

% define positioner X
% esto es la tarjeta a la que conecté el stage
group_x = 'Group4' ;
positioner_x = 'Group4.Pos' ;

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
group_y = 'Group6' ;
positioner_y = 'Group6.Pos' ;

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

PositionerSGammaParametersSet(socketID, positioner_x, 200, 600, 0.005, 0.05);
PositionerSGammaParametersSet(socketID, positioner_y, 200, 600, 0.005, 0.05);

x_min = 280;
x_max = 390;

y_min = 440;
y_max = 570;

paso = 10;

particion_x = x_min:paso:x_max;
particion_y = y_min:paso:y_max;

[errorCode] = GroupMoveAbsolute(socketID, positioner_y, 500); 
[errorCode] = GroupMoveAbsolute(socketID, positioner_x, 300);

set(0,'DefaultFigureVisible', 'on');

frame = getsnapshot(camara);
perfil = median(frame);
perfil = double(perfil)/2^4;

figure(1)
plot(perfil)

%%

output_file = fopen( [path 'coord_pedidas_vs_medidas.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

x_stage = [];
y_stage = [];

N = numel(particion_x)*numel(particion_y);
k = 0;

for i=1:numel(particion_x) 
    for j=1:numel(particion_y)
        
        k = k + 1;
        
        sprintf('Paso %d de %d', k, N)
        
        x = particion_x(i);
        y = particion_y(j);
        
        % me muevo en x
        [errorCode_x] = GroupMoveAbsolute(socketID, positioner_x, x);
        [~, status_x] = GroupStatusGet(socketID, group_x);
        % Ojo, esta función está mal documentada en el manual del Q. El
        % tercer argumento es el número de posicionadores en el grupo
        [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);

        % me muevo en y
        [errorCode_y] = GroupMoveAbsolute(socketID, positioner_y, y);
        [~, status_y] = GroupStatusGet(socketID, group_y);
        [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        
        % saco una foto
        frame = getsnapshot(camara);
        
        tag = sprintf('LUT_frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
        
        imwrite(frame, [path tag '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;

%%

% Close connection
TCP_CloseSocket(socketID);