% esta funcion es para hacer movimientos con el stage asegurandose de que
% llega a destino y se acomoda antes de devolver el control

% estimo el timeout t_out como la distancia que me voy a mover dividido la
% velocidad. Le doy el doble que eso para estar seguro

function[distancia, pos_actual] = mover_stage_2(socketID, group, positioner, pos_llegada, tol)

    [~, pos_actual] = GroupPositionCurrentGet(socketID, positioner, 1);
    [~, velocidad, ~, ~, ~] = PositionerSGammaParametersGet(socketID, positioner);
    
    distancia = abs(pos_actual - pos_llegada);

    %t_out = 2*distancia/velocidad;
    t_out = 60;

    GroupMoveAbsolute(socketID, positioner, pos_llegada);
    
    [~, pos_actual] = GroupPositionCurrentGet(socketID, positioner, 1);
    distancia = abs(pos_actual - pos_llegada);
    
    tic
    
    condicion = distancia < tol;
    %while distancia > tol
    while condicion == 0

        %[~, status] = GroupStatusGet(socketID, group);
        [~, pos_actual] = GroupPositionCurrentGet(socketID, positioner, 1);
        distancia = abs(pos_actual - pos_llegada);
        condicion = distancia < tol;
        
        t = toc;
        if t > t_out
            break
        end

    end
    
end