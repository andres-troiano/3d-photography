% esta función se conecta a 2 posicionadores lineales y los crea como
% objetos

function[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages()

    % Load the library
    xps_load_drivers ;

    % chequear manual
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
    
end