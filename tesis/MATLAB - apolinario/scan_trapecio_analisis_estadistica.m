% Este programa es igual a scan_trapecio_analisis.m, solo que está pensado
% para cuando uno tomó muchas mediciones en cada punto, para ver si la
% medición es estable o si hay errores para estudiar

%clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan\';
    
list = dir([path 'trapecio_frame_*.png']);
fnames = {list.name};

N = numel(fnames);

% la dificultad adicional está acá, en saber agrupar las mediciones que
% corresponden a un mismo punto.
tag_espacial = cell(N, 1);

for i=1:N
    
    tag = strsplit(fnames{i}, '_medicion_');
    tag = tag{1};
    tag = strsplit(tag, 'trapecio_frame_');
    tag = tag(2);
    tag = tag{:};
    
    tag_espacial{i} = tag;
    
end

tag_espacial_unicos = unique(tag_espacial);

% output_file = fopen( [path 'scan_trapecio_medidas.txt'], 'wt' );
% fprintf(output_file, 'x_stage\ty_stage\tmedida\n');

for j = 1:numel(tag_espacial_unicos)
%for j = 33:numel(tag_espacial_unicos)
%for j = 30
    
    % cargo todos los archivos que corresponden a ese punto del espacio
    list = dir([path '*frame_' tag_espacial_unicos{j} '*.png']);
    fnames = {list.name};
    N = numel(fnames);
    
    % DE PRUEBA
    %N = 10;

    % acá guardo la tira de mediciones para un mismo punto
    % hay una tira para cada punto
    medida_iteraciones = zeros(N, 1);
    
    % armo un archivo para guardar las medidas de todas las iteraciones. Un
    % archivo por punto del espacio
    output_file = fopen( [path 'medida_iteraciones_' tag_espacial_unicos{j} '.txt'], 'wt' );
    
    % ahora este loop corre sobre un único lugar del espacio
    for i=1:N
    
        sprintf('Punto %d de %d', j, numel(tag_espacial_unicos))
        sprintf('Iteracion %d de %d', i, N)
    
        filename = [path fnames{i}];
        frame = imread(filename);

        tag = strsplit(filename, '.');
        tag = tag{1};
        tag = strsplit(tag, 'frame_');
        tag = tag{2};
        tag = strsplit(tag, '_');

        %X0 = [350, 975];
        
        % les doy valores del orden de los valores de x, no de sus indices
        X0 = [800, 1400];
        
        options = optimset('Display', 'off');

        %f = @(x)ajuste_trapecio_funcion_2_params(x, frame);
        f = @(x)ajuste_trapecio_nuevo(x, frame);
        [x, fval] = fminsearch(f, X0, options);

        %x = round(x);

        pos_x = str2double(tag{2});
        pos_y = str2double(tag{4});

        %medida = trapecio_2_params(x, filename);
        medida = plot_trapecio_nuevo(x, filename);
        %fprintf(output_file, '%d\t%d\t%.2f\n', pos_x, pos_y, medida);
        fprintf(output_file, '%f\n', medida);
        
        medida_iteraciones(i) = medida;

    end
    
    % lo que quiero analizar es el gráfico de las repeticiones
    set(0,'DefaultFigureVisible', 'on');

    close all
    h = figure(2);
    ax = plot(medida_iteraciones, '.-');
    grid on
    xlabel('iteración')
    ylabel('medida (mm)')
    
    fig_name = ['medida_iteraciones_x_' tag{2} '_y_' tag{4}];
    % saveas(h, [path fig_name], 'png');
    
end

fclose all;

disp('Terminé')