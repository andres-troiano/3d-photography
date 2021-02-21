[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();

%%

x_min = 280;
x_max = 390;

y_min = 440;
y_max = 570;

PositionerSGammaParametersSet(socketID, positioner_x, 200, 600, 0.005, 0.05);
PositionerSGammaParametersSet(socketID, positioner_y, 200, 600, 0.005, 0.05);

% siempre moverme primero a la region de trabajo, para no chocarme nada
mover_stage(socketID, group_y, positioner_y, y_max);
mover_stage(socketID, group_x, positioner_x, x_min);

%%

% puedo moverme N veces al azar, y después ir al punto.
% No siempre voy a llegar desde el mismo lado. Pero siempre me voy a mover
% primero en x y después en y. Y después cambio

% en primera instancia solo me interesa ver qué dispersión tengo, no me
% importa cómo cambia el error según de dónde vengo

M = 100;
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
        mover_stage(socketID, group_x, positioner_x, x);
        mover_stage(socketID, group_y, positioner_y, y);
    end

    % después de la recorrida al azar, voy a un punto de prueba
    x_0 = 350;
    y_0 = 500;

%     mover_stage(socketID, group_x, positioner_x, x_0);
%     mover_stage(socketID, group_y, positioner_y, y_0);
    
    % defino una tolerancia de 1 micron
    tol = 1e-3;

    [distancia_x, pos_x] = mover_stage_2(socketID, group_x, positioner_x, x_0, tol);
    [distancia_y, pos_y] = mover_stage_2(socketID, group_y, positioner_y, y_0, tol);

    [distancia_x, distancia_y]
    
    % me fijo donde cai
%     [~, status_x] = GroupStatusGet(socketID, group_x);
%     [~, status_y] = GroupStatusGet(socketID, group_y);
    
    % me fijo si la posición es estable o si sigue acomodandose
%     pause on
%     
%     for i = 1:10
%         [~, status_x] = GroupStatusGet(socketID, group_x);
%         [~, status_y] = GroupStatusGet(socketID, group_y);
%         
%         [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
%         [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
% 
%         [pos_x, pos_y]
%         
%         pause(0.5)
%     end
    
    distribucion_x = [distribucion_x pos_x];
    distribucion_y = [distribucion_y pos_y];
    
end

set(0,'DefaultFigureVisible', 'on');

% close all
% h = figure(1);
% hold on
% grid on
% plot(distribucion_x, distribucion_y, '.b')
% plot(distribucion_x, '.b')
% plot(distribucion_y, '.r')
% plot(x_0, y_0, '.r')
% xlabel('x (mm)')
% ylabel('y (mm)')

%%
path = 'C:\Users\60069978\Documents\MATLAB\';

close all
h = figure(1);
hold on
grid on
plot(distribucion_x, '.-b')
xlabel('iteración')
ylabel('posición x (mm)')
ylim([349.99, 350.01])

saveas(h, [path 'dispersion_stage_x'], 'png');

hh = figure(2);
hold on
grid on
plot(distribucion_y, '.-b')
xlabel('iteración')
ylabel('posición y (mm)')
ylim([499.99, 500.01])

saveas(hh, [path 'dispersion_stage_y'], 'png');

% path = 'C:\Users\60069978\Documents\MATLAB\dispersion_stages.png';
% saveas(h, path, 'png');

%%

TCP_CloseSocket(socketID);