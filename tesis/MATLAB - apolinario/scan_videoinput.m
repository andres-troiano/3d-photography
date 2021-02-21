imaqreset
%clear classes
clear variables
close all

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
set(src, 'AoiThreshold', 102);
set(src, 'LightDevice0LightBrightness', 100);
set(src, 'LightDevice0LightSource', 'ExposureActive');
set(src, 'ProfilesPerFrame', 50);
set(src, 'PacketSize', 5000);
% No le puedo setear que me devuelva int16!

%set(camara, 'PixelFormat', 'Mono16');

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% me muevo por una grilla cuadrada
x_min = 290;
x_max = 390;

y_min = 460;
y_max = 600;

paso = 10;

particion_x = x_min:paso:x_max;
particion_y = y_min:paso:y_max;

% ubico los dos posicionadores en la esquina inferior izquierda
[errorCode] = GroupMoveAbsolute(socketID, positioner_y, y_max); 
[errorCode] = GroupMoveAbsolute(socketID, positioner_x, x_min); 

%%

output_file = fopen( [path 'scan_log.txt'], 'wt' );
fprintf(output_file, 'x\ty\tpos_x\tpos_y\terr_x\terr_y\tstatus_x\tstatus_y\n');

x_stage = [];
y_stage = [];

for i=1:numel(particion_x) 
    for j=1:numel(particion_y)
        
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
        
        tag = sprintf('frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%.2f\t%.2f\t%d\t%d\t%d\t\t%d\n', x, y, pos_x, pos_y, errorCode_x, errorCode_y, status_x, status_y);
        
        imwrite(frame, [path tag '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;

% [errorCode, position_x] = XPS_Get_Single_Position(socketID, group_x);

%%

% Close connection
TCP_CloseSocket(socketID)