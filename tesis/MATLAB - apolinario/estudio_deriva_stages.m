clear variables

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();

%%

path = 'C:\Users\60069978\Documents\MATLAB\scan\';

x_min = 290;
x_max = 390;

y_min = 440;
y_max = 570;

PositionerSGammaParametersSet(socketID, positioner_x, 200, 600, 0.005, 0.05);
PositionerSGammaParametersSet(socketID, positioner_y, 200, 600, 0.005, 0.05);

% siempre moverme primero a la region de trabajo, para no chocarme nada
mover_stage(socketID, group_y, positioner_y, y_max);
mover_stage(socketID, group_x, positioner_x, x_min);

pause on

%%

% STAGE X
%%%%%%%%%

PositionerSGammaParametersSet(socketID, positioner_x, 10, 10, 0.005, 0.05);

x_0 = 350;

N = 15;
M = 5;

p = 0;
for k = 1:N

    % se mueve por 5 lugares al azar
    for j = 1:M
        x = randi([x_min, x_max]);
        mover_stage_2(socketID, group_x, positioner_x, x, 1e-3);
        
        sprintf('Paso %d de %d', p, N*M)
        p = p+1;
    end
    
    deriva = [];
    tiempo = [];

    % va a destino y mide
    mover_stage_2(socketID, group_x, positioner_x, x_0, 1e-3);

    tic

    close all
    h = figure(1);
    hold on
    grid on

    for i = 1:75
        [~, pos] = GroupPositionCurrentGet(socketID, positioner_x, 1);
        tiempo = [tiempo, toc];

        deriva = [deriva pos];

        plot(tiempo, deriva, '.-b')
        xlabel('tiempo (s)')
        ylabel('posición x (mm)')

        pause(0.25)
    end

    saveas(h, [path 'dispersion_stage_x_' num2str(x)], 'png');

end

%%
    
% STAGE Y
%%%%%%%%%

PositionerSGammaParametersSet(socketID, positioner_y, 10, 10, 0.005, 0.05);

y_0 = 500;

N = 15;
M = 5;

p = 0;
for k = 1:N

    % se mueve por 5 lugares al azar
    for j = 1:M
        y = randi([y_min, y_max]);
        mover_stage_2(socketID, group_y, positioner_y, y, 1e-3);
        
        sprintf('Paso %d de %d', p, N*M)
        p = p+1;
    end
    
    deriva = [];
    tiempo = [];

    % va a destino y mide
    mover_stage_2(socketID, group_y, positioner_y, y_0, 1e-3);

    tic

    close all
    h = figure(1);
    hold on
    grid on

    for i = 1:75
        [~, pos] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        tiempo = [tiempo, toc];

        deriva = [deriva pos];

        plot(tiempo, deriva, '.-b')
        xlabel('tiempo (s)')
        ylabel('posición y (mm)')

        pause(0.25)
    end

    saveas(h, [path 'dispersion_stage_y_' num2str(y)], 'png');

end

%%

TCP_CloseSocket(socketID);