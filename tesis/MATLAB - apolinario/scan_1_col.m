%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hacer try catch para errores del stage, y de pérdida de conexión con la
% cámara
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear classes
clear all
close all

% directorio donde voy a guardar los frames
path = 'C:\Users\60069978\Documents\MATLAB\scan\';

camara = gigecam(1);

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
set(camara, 'AoiThreshold', 102);
set(camara, 'LightSource', 'ExposureActive');
set(camara, 'GevSCPSPacketSize', 5000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the library
xps_load_drivers ;

% Set connection parameters
IP = '192.168.0.254' ;
Port = 5001 ;
TimeOut = 20.0 ;

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

x_0 = 290;

y_min = 460;
y_max = 600;

paso = 40;

particion_y = y_min:paso:y_max;

% ubico los dos posicionadores en la esquina inferior izquierda
tic
[errorCode] = GroupMoveAbsolute(socketID, positioner_y, y_max); 
toc
[errorCode] = GroupMoveAbsolute(socketID, positioner_x, x_0); 

%%

output_file = fopen( [path 'scan_1_col_log.txt'], 'wt' );
fprintf(output_file, 'x\ty\tpos_x\tpos_y\thora\tmin\tsec\terr_x\terr_y\tstatus_x\tstatus_y\n');

x_stage = [];
y_stage = [];

for j=1:numel(particion_y)

    x = x_0;
    y = particion_y(j);

    errorCode_x = 0;
    [~, status_x] = GroupStatusGet(socketID, group_x);
    % Ojo, esta función está mal documentada en el manual del Q. El
    % tercer argumento es el número de posicionadores en el grupo
    [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);

    % me muevo en y
    [errorCode_y] = GroupMoveAbsolute(socketID, positioner_y, y);
    [~, status_y] = GroupStatusGet(socketID, group_y);
    [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);

    % saco una foto
    [frame, timestamp] = snapshot(camara);
    timestamp = datevec(timestamp);

    tag = sprintf('frame_x_%d_y_%d', x, y);
    fprintf(output_file, '%d\t%d\t%.2f\t%.2f\t%d\t%d\t%.2f\t%d\t%d\t%d\t\t%d\n', x, y, pos_x, pos_y, timestamp(4), timestamp(5), timestamp(6), errorCode_x, errorCode_y, status_x, status_y);

    imwrite(frame, [path tag '.png'], 'PNG');

end   

fclose all;
clear output_file;

% [errorCode, position_x] = XPS_Get_Single_Position(socketID, group_x);

%%

% Close connection
TCP_CloseSocket(socketID) ;