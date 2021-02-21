% esta funcion es para hacer movimientos con el stage asegurandose de que
% llega a destino y se acomoda antes de devolver el control

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();

%%

% estimo el timeout t_out como la distancia que me voy a mover dividido la
% velocidad. Le doy el doble que eso para estar seguro

pos_llegada = 600;
[~, pos_actual] = GroupPositionCurrentGet(socketID, positioner_y, 1);

PositionerSGammaParametersSet(socketID, positioner_y, 20, 100, 0.005, 0.05);

distancia = abs(pos_actual - pos_llegada);
[~, velocidad, ~, ~, ~] = PositionerSGammaParametersGet(socketID, positioner_y);

t_out = 2*distancia/velocidad;

PositionerSGammaParametersSet(socketID, positioner_y, velocidad, 100, 0.005, 0.05);

[errorCode] = GroupMoveAbsolute(socketID, positioner_y, pos_llegada);

status = 0;
tic

while status ~= 12

    [~, status] = GroupStatusGet(socketID, group_y);
    t = toc;
    [~, pos_actual] = GroupPositionCurrentGet(socketID, positioner_y, 1)
    
    if t > t_out
        break
    end
    
end

[~, pos_actual] = GroupPositionCurrentGet(socketID, positioner_y, 1)

%%

TCP_CloseSocket(socketID);