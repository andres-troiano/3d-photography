path = 'C:\Users\60069978\Documents\MATLAB\scan11\';

% tomo las múltiples mediciones para cada punto, tiro los que no
% correspondan, y calculo el promedio

list = dir([path 'medida_iteraciones*.txt']);
fnames = {list.name};

valores_promediados = [];
x = [];
y = [];

%for i = 1
for i = 1:numel(fnames)
    
    datos = importdata([path fnames{i}]);
    mediana = median(datos);
    desviacion = std(datos);
    c = 3;
    
    datos_temp_x = [];
    datos_temp_y = [];
    
    for j = 1:numel(datos)
        if datos(j) < mediana + c*desviacion && datos(j) > mediana - c*desviacion
            datos_temp_x = [datos_temp_x j];
            datos_temp_y = [datos_temp_y datos(j)];
        end
    end
    
    promedio = mean(datos_temp_y);
    
    valores_promediados = [valores_promediados promedio];
    
    % aca guardo los valores de x,y correspondientes
    tag = strsplit(fnames{i}, '.');
    tag = tag{1};
    tag = strsplit(tag, 'medida_iteraciones_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    
    x = [x str2double(tag{2})];
    y = [y str2double(tag{4})];
    
    set(0,'DefaultFigureVisible', 'off');
    
    close all
    h = figure(1);
    hold on
    grid on
    plot(datos, '.-b')
    plot(datos_temp_x, datos_temp_y, '.r')
    plot([1 100], [mediana mediana], '--r')
    plot([1 100], [mediana - c*desviacion mediana - c*desviacion], '--g')
    plot([1 100], [mediana + c*desviacion mediana + c*desviacion], '--g')
    
    fig_name = ['promedios_x_' tag{2} '_y_' tag{4}];
    saveas(h, [path fig_name], 'png');

end

% escribo un txt nuevo que tiene: x,y,medida
% ojo: para hacerlo más fácil uso los valores pedidos de x,y, porque para
% este fin no es importante el error del stage

output_file = fopen( [path 'medida_trapecio_superficie_promediado.txt'], 'wt' );
fprintf(output_file, 'x\ty\tmedida\n');

for i = 1:numel(x)
    fprintf(output_file, '%d\t%d\t%f\n', x(i), y(i), valores_promediados(i));
end

fclose all;

%%

% esta parte del script carga el txt que es output de la seccion anterior y
% construye la superficie

clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan11\';
archivo = [path 'medida_trapecio_superficie_promediado.txt'];

datos = importdata(archivo, '\t', 1);
datos = datos.data;

r = datos(:, 1);  % x
s = datos(:, 2);  % y
t = datos(:, 3);  % medida

r = r.';
s = s.';
t = t.';

referencia = 60.0310*ones(1, numel(t));
t = t - referencia;

ri = unique(r);
si = unique(s);
[R,S] = meshgrid(ri,si);
T = reshape(t, size(R));

set(0,'DefaultFigureVisible', 'on');

close all
figure
surf(R, S, T)
xlabel('x_{stage} (mm)')
ylabel('y_{stage} (mm)')
zlabel('medicion - dato (mm)')