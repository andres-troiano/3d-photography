clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan\';

[socketID, positioner_x, positioner_y, group_x, group_y] = setup_stages();
camara = setup_camara(102);

tol = 1e-3;

%%

mover_stage_2(socketID, group_y, positioner_y, 600, tol);
mover_stage_2(socketID, group_x, positioner_x, 400, tol);

%%
pause on

%for i = 1:1000
%     frame = getsnapshot(camara);
%     perfil = median(frame);
%     perfil = double(perfil)/2^4;
%     
%     plot(perfil, '.-')
%     
%     pause(0.5)
% end

%%

% para el patrón 4700130
% limites x = 410, 460
%         y = 540, 600
%         z = 11, 31 (11, 16, 21, 26, 31)

% patrón 4700530
% z = 36-16 (16, 21, 26, 31, 36)
% x_min = 410;
% x_max = 450;
% y_min = 600;
% y_max = 600;

% patrón 4700530
% x_min = 400;
% x_max = 470;
% y_min = 520;
% y_max = 600;

tag_patron = '34700030';

x_min = 400;
x_max = 470;
y_min = 520;
y_max = 600;

x = x_max;
y = y_max;

mover_stage_2(socketID, group_y, positioner_y, y, tol);
mover_stage_2(socketID, group_x, positioner_x, x, tol);

pause on
pause(15)

% z = 36-16 (16, 21, 26, 31, 36)
z = 36;

% frame = getsnapshot(camara);
% perfil = median(frame);
% perfil = double(perfil)/2^4;
% 
% set(0,'DefaultFigureVisible', 'on');
% close all
% figure
% plot(perfil)

% en esta parte mido y guardo los frames

tag_x = num2str(x);
tag_y = num2str(y);
tag_z = num2str(z);

tag = ['frame_cilindro_' tag_patron '_x_' tag_x '_y_' tag_y '_z_' tag_z '.png'];

frame = getsnapshot(camara);
imwrite(frame, [path tag], 'PNG');

% esta parte la dejo para chequear en el momento que el frame es bueno

perfil = median(frame);
perfil = double(perfil)/2^4;

datos_x = [];
datos_y = [];

for i = 1:numel(perfil)
    if perfil(i) ~= 0
        datos_x = [datos_x i];
        datos_y = [datos_y perfil(i)];
    end
end

[y_min, indice_min] = min(datos_y);
x_min = datos_x(indice_min);

% uso que el reflejo de la base está a más de 300 pixels de lo más que
% alcanzo a ver del cilindro

dist = 300;

datos_x_temp = [];
datos_y_temp = [];

for i = 1:numel(datos_x)
    if datos_y(i) < min(datos_y) + dist
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

datos_x = datos_x_temp;
datos_y = datos_y_temp;

close all
figure(1)
hold on
grid on
%plot(perfil, '.b')
plot(datos_x, datos_y, '.b')
%plot(x_min, y_min, '*g')

%%

% Close connection
TCP_CloseSocket(socketID);

%%

% en esta parte hago el análisis de los frames
% me convendria guardar cada perfil como columna de una matriz. La llamo P
% una dificultad es que cada perfil tendrá una cantidad distinta de puntos
% podría empezar definiendo algo del largo de lo que veo, y después tomar
% la mínima región que contenga todos los perfiles
% o directamente mirar los x límite en los perfiles

%clear variables
%path = 'C:\Users\60069978\Documents\MATLAB\scan23\';

% acá voy eligiendo qué posición (x, y) analizo
tag_patron = '34700030';
%nominal = 88.9117;
%nominal = 139.707;
nominal = 73.0113;
x = 400;
y = 520;

tag_x = num2str(x);
tag_y = num2str(y);

list = dir([path 'frame_cilindro_' tag_patron '_x_' tag_x '_y_' tag_y '*.png']);
fnames = {list.name};

N = numel(fnames);
%N = 1;

% guardo la información de los diámetros, promedio y std en un txt
output_file = fopen( [path 'diametros_' tag_patron '_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
fprintf(output_file, 'z\tdiametro\n');
    
diametros_todo_z = [];
errores_todo_z = [];

for j = 1:N
%for j = 2
    
    filename = [path fnames{j}];
    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    datos_x = [];
    datos_y = [];

    for i = 1:numel(perfil)
        if perfil(i) ~= 0
            datos_x = [datos_x i];
            datos_y = [datos_y perfil(i)];
        end
    end

    [y_min, indice_min] = min(datos_y);
    x_min = datos_x(indice_min);

    % uso que el reflejo de la base está a más de 300 pixels de lo más que
    % alcanzo a ver del cilindro

    dist = 300;

    datos_x_temp = [];
    datos_y_temp = [];

    for i = 1:numel(datos_x)
        if datos_y(i) < min(datos_y) + dist
            datos_x_temp = [datos_x_temp datos_x(i)];
            datos_y_temp = [datos_y_temp datos_y(i)];
        end
    end

    datos_x = datos_x_temp;
    datos_y = datos_y_temp;
    
    % convierto a mm
    %%%%%%%%%%%%%%%%
    lut = 'C:\Users\60069978\Documents\MATLAB\scan24\LUT_paso_5_mm.txt';
    [x, y] = convertir_a_unidades_reales(datos_x, datos_y, lut);
    
    % matrix con x, y como columnas
    XY = [x; y];    % así están como filas
    XY = XY.';
    
    circulo = TaubinNTN(XY);

    centro_x = circulo(1);
    centro_y = circulo(2);
    radio = circulo(3);
    diametro = 2*radio;

    th = 0:pi/50:2*pi;
    circulo_x = radio * cos(th) + centro_x;
    circulo_y = radio * sin(th) + centro_y;
    
    error = abs(nominal - diametro);
    
    % filtro datos malos
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    error_radial = radio - sqrt((x - centro_x).^2 + (y - centro_y).^2);
    
    % como criterio de tolerancia uso la std del error
    error_avg = mean(error_radial);
    sigma = std(error_radial);
    
    filtro = error_avg + 3*sigma;
    
    % me fijo qué datos están dentro de la tolerancia
    
    % usando tolerancia relativa
    booleano = abs(error_radial) < filtro;
    
    % usando tolerancia de 1 mm
    %booleano = abs(error_radial) < 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % vuelvo a ajustar después del filtrado
    
    x_filtrado = x(booleano);
    y_filtrado = y(booleano);
    
    % por qué esto no anda y lo de abajo sí???
    %XY = [x_filtrado; x_filtrado];    % así están como filas
    XY = [x(booleano); y(booleano)];
    XY = XY.';
    
    circulo = TaubinNTN(XY);
    
    centro_x = circulo(1);
    centro_y = circulo(2);
    radio = circulo(3);
    diametro = 2*radio;
    
    diametros_todo_z = [diametros_todo_z diametro];

    th = 0:pi/50:2*pi;
    circulo_x = radio * cos(th) + centro_x;
    circulo_y = radio * sin(th) + centro_y;
    
    % vuelvo a calcular el error luego de haber filtrado
    error_radial_filtrado = radio - sqrt((x_filtrado - centro_x).^2 + (y_filtrado - centro_y).^2);
    % error_radial = radio - sqrt((x(booleano) - centro_x).^2 + (y(booleano) - centro_y).^2);
    
    error = abs(nominal - diametro);
    errores_todo_z = [errores_todo_z error];
    
    % grafico
    %%%%%%%%%
    
    margen = 2;

    set(0,'DefaultFigureVisible', 'off');
    
    close all
    
    h = figure(1);
    ax(2) = subplot(2, 1, 2);
    hold on
    grid on
    plot(x, error_radial, '.-g')
    %plot(x(booleano), error_radial_filtrado, '.-b')
    plot(x_filtrado, error_radial_filtrado, '.-b')
    %plot(x(booleano), error_radial, '.-')
    plot([min(x), max(x)], [filtro, filtro], '--r')
    plot([min(x), max(x)], [-filtro, -filtro], '--r')
    xlabel('x (mm)')
    ylabel('datos - ajuste (mm)')
    legend('Pre filtrado', 'Post filtrado', 'Corte del filtro', 'Location', 'Best')
    %title('Distancia medición-ajuste');

    ax(1) = subplot(2, 1, 1);
    %h = figure(2);
    hold on
    grid on
    plot(x, y, '.g')
    plot(x_filtrado, y_filtrado, '.b')
    plot(circulo_x, circulo_y, '--r')
    xlabel('x (mm)')
    ylabel('y (mm)')
    xlim([min(x) - margen max(x) + margen]);
    ylim([min(y) - margen max(y) + margen]);
    legend('datos filtrados', 'perfil', 'ajuste círculo', 'Location', 'Best');
    
    tit = sprintf('Diámetro real menos teórico = %.4f mm', error);
    title(tit);
    
    tag_z = strsplit(filename, '.');
    tag_z = strsplit(tag_z{1}, '_z_');
    tag_z = tag_z{2};
    
    %linkaxes(ax,'x');
    
    tag = ['plot_cilindro_' tag_patron '_x_' tag_x '_y_' tag_y '_z_' tag_z];
    
    saveas(h, [path tag], 'png');
    saveas(h, [path tag]);

    % guardo diámetros y demás en el txt
    fprintf(output_file, '%s\t%f\n', tag_z, diametro);
    
end

promedio_diametros = mean(diametros_todo_z);
desviacion_diametros = std(diametros_todo_z);

promedio_errores = mean(errores_todo_z);
desviacion_errores = std(errores_todo_z);

fprintf(output_file, '\npromedio diametros: %f\nstd diametros: %f\n', promedio_diametros, desviacion_diametros);
fprintf(output_file, '\npromedio errores: %f\nstd errores: %f\n', promedio_errores, desviacion_errores);

fclose all;
clear output_file;