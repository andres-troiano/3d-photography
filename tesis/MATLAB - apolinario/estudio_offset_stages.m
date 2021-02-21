[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();

%%

x_min = 280;
x_max = 390;

y_min = 440;
y_max = 570;

[error_x, velocity_x, acceleration_x, min_jerk_x, max_jerk_x] = PositionerSGammaParametersGet(socketID, positioner_x)
[error_y, velocity_y, acceleration_y, min_jerk_y, max_jerk_y] = PositionerSGammaParametersGet(socketID, positioner_y)

%%

PositionerSGammaParametersSet(socketID, positioner_x, 20, 100, 0.005, 0.05);
PositionerSGammaParametersSet(socketID, positioner_y, 20, 100, 0.005, 0.05);

%%
pause on

[errorCode] = GroupMoveAbsolute(socketID, positioner_y, 0);
%[~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);

for i = 1:1000
    i
    pause(0.5)
    [~, status_x] = GroupStatusGet(socketID, group_y)
end

%%

[errorCode] = GroupMoveAbsolute(socketID, positioner_x, 0);
[~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);

%%

% puedo moverme N veces al azar, y después ir al punto.
% No siempre voy a llegar desde el mismo lado. Pero siempre me voy a mover
% primero en x y después en y. Y después cambio

% en primera instancia solo me interesa ver qué dispersión tengo, no me
% importa cómo cambia el error según de dónde vengo

pause on

%M = 100;
M = 10;
k = 0;

distribucion_x = [];
distribucion_y = [];

for j = 1:M

    N = 5;

    for i = 1:N
        k = k + 1;
        sprintf('Paso %d de %d', k, M*N)
        
        % quiero elegir un valor al azar dentro del rango de x, y otro para y
        x = randi([x_min, x_max]);
        y = randi([y_min, y_max]);

        % me paro en ese punto
        [errorCode] = GroupMoveAbsolute(socketID, positioner_x, x);
        [errorCode] = GroupMoveAbsolute(socketID, positioner_y, y);
    end

    % después de la recorrida al azar, voy a un punto de prueba
    x_0 = 350;
    y_0 = 500;

    [errorCode] = GroupMoveAbsolute(socketID, positioner_x, x_0);
    [errorCode] = GroupMoveAbsolute(socketID, positioner_y, y_0);

    % me fijo donde cai
    pause(10)
    
    [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
    [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
    
    distribucion_x = [distribucion_x pos_x];
    distribucion_y = [distribucion_y pos_y];
    
%     [~, status_x] = GroupStatusGet(socketID, group_x);
%     [~, status_y] = GroupStatusGet(socketID, group_y);
    
    
end

set(0,'DefaultFigureVisible', 'on');

close all
h = figure(1);
hold on
grid on
plot(distribucion_x, distribucion_y, '.b')
plot(x_0, y_0, '.r')
xlabel('x (mm)')
ylabel('y (mm)')

% path = 'C:\Users\60069978\Documents\MATLAB\dispersion_stages.png';
% saveas(h, path, 'png');

%%

TCP_CloseSocket(socketID);