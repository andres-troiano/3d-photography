clear variables
path = 'C:\Users\60069978\Documents\MATLAB\scan26\';

% acá voy eligiendo qué posición (x, y) analizo
tag_patron = '34700730';

%nominal = 88.9117;
% nominal = 139.707;
%nominal = 73.0113;
nominal = 177.8057;

x = 410;
y = 550;

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
%for j = 4
    
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
    
    
    % filtro datos malos
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cant_sigmas = [3 3 3];
    filtros = [3 2 1];
    booleano = true(size(x));
    
    % hago un loop filtrando con un umbral físico hasta 1 mm
    for k = 1:numel(filtros)
        
        % matrix con x, y como columnas
        XY = [x(booleano); y(booleano)];    % así están como filas
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
        
        % es la distancia de (x, y) al último ajuste realizado
        % debería hacerlo desde los (x, y) salidos del último filtrado
        error_radial = radio - sqrt((x - centro_x).^2 + (y - centro_y).^2);

        % como criterio de tolerancia uso la std del error
        error_avg = mean(error_radial(booleano));
        sigma = std(error_radial(booleano));

%        filtro = error_avg + cant_sigmas(k)*sigma;
        filtro = filtros(k);

        % me fijo qué datos están dentro de la tolerancia
        % usando tolerancia relativa
        booleano = abs(error_radial) < filtro;

        % vuelvo a calcular el error luego de haber filtrado
        error_radial_filtrado = error_radial(booleano);
        % error_radial = radio - sqrt((x(booleano) - centro_x).^2 + (y(booleano) - centro_y).^2);

        figure,plot(x,error_radial,'.-'),hold all, plot(x([1 end]),[filtro filtro]),plot(x(~booleano),error_radial(~booleano),'o')

    end
    
    % hago otro loop filtrando con la desviación estándar
    for k = 1:numel(cant_sigmas)
        
        % matrix con x, y como columnas
        XY = [x(booleano); y(booleano)];    % así están como filas
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
        
        % es la distancia de (x, y) al último ajuste realizado
        % debería hacerlo desde los (x, y) salidos del último filtrado
        error_radial = radio - sqrt((x - centro_x).^2 + (y - centro_y).^2);

        % como criterio de tolerancia uso la std del error
        error_avg = mean(error_radial(booleano));
        sigma = std(error_radial(booleano));

        filtro = error_avg + cant_sigmas(k)*sigma;

        % me fijo qué datos están dentro de la tolerancia

        % usando tolerancia relativa
        booleano = abs(error_radial) < filtro;
    
        % vuelvo a calcular el error luego de haber filtrado
        error_radial_filtrado = error_radial(booleano);

        figure,plot(x,error_radial,'.-'),hold all, plot(x([1 end]),[filtro filtro]),plot(x(~booleano),error_radial(~booleano),'o')

    end
        
    error = nominal - diametro;
    errores_todo_z = [errores_todo_z error];
    
    % grafico
    %%%%%%%%%
    margen = 2;

    set(0,'DefaultFigureVisible', 'on');
    
    close all
    h = figure(1);
    ax(2) = subplot(2, 1, 2);
    hold on
    grid on
    plot(x(booleano), error_radial(booleano), '.-b')
    plot([min(x), max(x)], [filtro, filtro], '--r')
    plot([min(x), max(x)], [-filtro, -filtro], '--r')
    xlabel('x (mm)')
    ylabel('datos - ajuste (mm)')
    legend('Pre filtrado', 'Post filtrado', 'Corte del filtro', 'Location', 'Best')

    ax(1) = subplot(2, 1, 1);
    hold on
    grid on
    plot(x, y, '.g')
    plot(x(booleano), y(booleano), '.b')
    plot(circulo_x, circulo_y, '--r')
    xlabel('x (mm)')
    ylabel('y (mm)')
    xlim([min(x) - margen max(x) + margen]);
    ylim([min(y) - margen max(y) + margen]);
    legend('datos filtrados', 'perfil', 'ajuste círculo', 'Location', 'Best');
    
    linkaxes(ax,'x');
    
    tit = sprintf('Diámetro real menos teórico = %.4f mm', error);
    title(tit);
    
    tag_z = strsplit(filename, '.');
    tag_z = strsplit(tag_z{1}, '_z_');
    tag_z = tag_z{2};
    
    tag = ['plot_cilindro_' tag_patron '_x_' tag_x '_y_' tag_y '_z_' tag_z];
    
%     saveas(h, [path tag], 'png');
%     saveas(h, [path tag]);

    % guardo diámetros y demás en el txt
    fprintf(output_file, '%s\t%f\n', tag_z, diametro);
    
    diametros_todo_z = [diametros_todo_z diametro];
end

promedio_diametros = mean(diametros_todo_z);
desviacion_diametros = std(diametros_todo_z);

promedio_errores = mean(errores_todo_z);
desviacion_errores = std(errores_todo_z);

fprintf(output_file, '\npromedio diametros: %f\nstd diametros: %f\n', promedio_diametros, desviacion_diametros);
fprintf(output_file, '\npromedio errores: %f\nstd errores: %f\n', promedio_errores, desviacion_errores);

fclose all;
clear output_file;