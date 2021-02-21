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

% Close connection
TCP_CloseSocket(socketID) ;