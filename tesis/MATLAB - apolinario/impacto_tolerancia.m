path = 'C:\Users\60069978\Documents\MATLAB\scan11\';
out_path = 'C:\Users\60069978\Documents\MATLAB\scan11\impacto_tolerancia\';

% cargo todos los archivos que corresponden a ese punto del espacio
list = dir([path 'trapecio_frame_x_330_y_520*.png']);
fnames = {list.name};
N = numel(fnames);
%N = 20;

% acá guardo la tira de mediciones para un mismo punto
% hay una tira para cada punto
medida_iteraciones = zeros(N, 1);

% armo un archivo para guardar las medidas de todas las iteraciones. Un
% archivo por punto del espacio
%output_file = fopen( [path 'tolerancia_x_330_y_520.txt'], 'wt' );

% ahora este loop corre sobre un único lugar del espacio
for i=1:N
    
    sprintf('Procesando perfil %d de %d', i, N)

    filename = [path fnames{i}];
    frame = imread(filename);

    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'frame_');
    tag = tag{2};
    tag = strsplit(tag, '_');

    X0 = [350, 975];

    options = optimset('Display', 'off', 'TolFun', 1e-4, 'TolX', 1e-4);

    f = @(x)ajuste_trapecio_funcion_2_params(x, frame);
    [x, fval] = fminsearch(f, X0, options);

    x = round(x);

    pos_x = str2double(tag{2});
    pos_y = str2double(tag{4});

    medida = trapecio_2_params(x, filename);
    %fprintf(output_file, '%f\n', medida);

    medida_iteraciones(i) = medida;

end

% lo que quiero analizar es el gráfico de las repeticiones
set(0,'DefaultFigureVisible', 'on');

close all
h = figure(1);
ax = plot(medida_iteraciones, '.-');
grid on
xlabel('iteración')
ylabel('medida')

fig_name = ['tolerancia_x_330_y_520'];
%saveas(h, [out_path fig_name], 'png');

%fclose all;