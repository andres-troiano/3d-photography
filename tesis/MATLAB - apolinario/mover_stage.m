% esta funcion es para hacer movimientos con el stage asegurandose de que
% llega a destino y se acomoda antes de devolver el control

% estimo el timeout t_out como la distancia que me voy a mover dividido la
% velocidad. Le doy el doble que eso para estar seguro

function[status] = mover_stage(socketID, group, positioner, pos_llegada)

    [~, pos_actual] = GroupPositionCurrentGet(socketID, positioner, 1);
    [~, velocidad, ~, ~, ~] = PositionerSGammaParametersGet(socketID, positioner);
    
    distancia = abs(pos_actual - pos_llegada);

    t_out = 2*distancia/velocidad;

    GroupMoveAbsolute(socketID, positioner, pos_llegada);

    status = 0;
    tic

    while status ~= 12

        [~, status] = GroupStatusGet(socketID, group);
        
        t = toc;
        if t > t_out
            break
        end

    end
    
end