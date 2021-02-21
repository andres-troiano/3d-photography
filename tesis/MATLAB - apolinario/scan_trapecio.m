imaqreset
clear variables

% directorio donde voy a guardar los frames
path = 'C:\Users\60069978\Documents\MATLAB\scan\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
camara = setup_camara(120);

PositionerSGammaParametersSet(socketID, positioner_x, 200, 600, 0.005, 0.05);
PositionerSGammaParametersSet(socketID, positioner_y, 200, 600, 0.005, 0.05);

tol = 1e-3;

%%

% valores para el trapecio:
% x entre 330 y 370

% podría ver más abajo en y, pero me choco la mesa
% y entre 520 y 600

x_min = 350;
x_max = 370;

y_min = 520;
y_max = 600;

paso = 10;

particion_x = x_min:paso:x_max;
particion_y = y_min:paso:y_max;

% ubico los dos posicionadores en la esquina inferior izquierda
mover_stage_2(socketID, group_y, positioner_y, y_min, tol);
mover_stage_2(socketID, group_x, positioner_x, x_min, tol);

set(0,'DefaultFigureVisible', 'on');

frame = getsnapshot(camara);
perfil = median(frame);
perfil = double(perfil)/2^4;

figure(1)
plot(perfil)

% antes de poder alinear tengo que asegurarme que tengo el script de ajuste
% corregido

%%

output_file = fopen( [path 'scan_trapecio_log.txt'], 'wt' );
fprintf(output_file, 'x\ty\tpos_x\tpos_y\n');

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
        
        % tomo 100 mediciones
        M = 100;
        for k = 1:M
            sprintf('Medición %d de %d', k, M)
            frame = getsnapshot(camara);

            tag = sprintf('trapecio_frame_x_%d_y_%d_medicion_%d', x, y, k);
            fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);

            imwrite(frame, [path tag '.png'], 'PNG');
        end
        
    end   
end

fclose all;
clear output_file;

%%

% Close connection
TCP_CloseSocket(socketID)