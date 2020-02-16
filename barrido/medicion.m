% este script hace un barrido en una grilla rectangular usando dos
% posicionadores lineales dispuestos en forma XY, y en cada punto saca 2
% fotos, una con cada cámara. Las cámaras tienen una inclinación relativa
% con lo cual ven partes diferentes del objeto que está escaneando.
% Extendiendo este método a 6 cámaras se barren los 360º.

% clear variables
basepath = 'C:\Users\60069978\Documents\MATLAB\medicion40\';

% seteo los posicionadores lineales
[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();

% seteo cámaras
[camara1, camara2] = setup_camaras();

set(0,'DefaultFigureVisible', 'on')

% rango del barrido
x_min = 0;
x_max = 300;
y_min = 400;
y_max = 500;

paso = 5;

particion_x = x_min:paso:x_max;
particion_y = y_min:paso:y_max;

% me ubico en una zona segura antes de empezar
mover_stages(socketID, group_y, positioner_y, 500, tol);
mover_stages(socketID, group_x, positioner_x, 0, tol);

%% barrido

% guardo las coordenadas donde se posicionaron los stages, para tener en
% cuenta el error
output_file = fopen( [basepath 'coord_pedidas_vs_medidas.txt'], 'wt' );
fprintf(output_file, 'x_pedido\ty_pedido\tx_medido\ty_medido\n');

N = numel(particion_x)*numel(particion_y);
k = 0;

tol = 1e-3; % tolerancia en el posicionamiento, en mm

for i=1:numel(particion_x)
    for j=1:numel(particion_y)
        
        k = k + 1;
        
        sprintf('Paso %d de %d', k, N)
        
        x = particion_x(i);
        y = particion_y(j);
        
        % posiciono la muestra. Siempre moverse 1ro en Y
        mover_stages(socketID, group_y, positioner_y, y, tol);
        mover_stages(socketID, group_x, positioner_x, x, tol);
        
        % mido la posición de los stages
        [~, pos_x] = GroupPositionCurrentGet(socketID, positioner_x, 1);
        [~, pos_y] = GroupPositionCurrentGet(socketID, positioner_y, 1);
        
        % cámara 1, hago una captura
        frame = getsnapshot(camara1);
        
        tag = sprintf('LUT_camara_1_frame_x_%d_y_%d', x, y);
        fprintf(output_file, '%d\t%d\t%f\t%f\n', x, y, pos_x, pos_y);
        
        % guardo la captura
        imwrite(frame, [basepath tag '.png'], 'PNG');
        
%         cámara 2
        frame = getsnapshot(camara2);
        tag = sprintf('LUT_camara_2_frame_x_%d_y_%d', x, y);
        
        imwrite(frame, [basepath tag '.png'], 'PNG');
        
    end   
end

fclose all;
clear output_file;

%%

% cierro la conexión
TCP_CloseSocket(socketID);