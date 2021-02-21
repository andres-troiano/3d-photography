clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan\';
    
list = dir([path 'LUT_frame_*.png']);
fnames = {list.name};

% Las coordenadas de la punta en pixels, en las diferentes posiciones
x_ccd = [];
y_ccd = [];

x_stage = [];
y_stage = [];

N = 4;
%N = numel(fnames);

%for i=1:N
for i = 3
    sprintf('Procesando frame %d de %d', i, N)
    
    filename = [path fnames{i}];
    disp(filename)
    
    % del filename obtengo las coordenadas del stage
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'frame_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    
    [x_0, y_0] = deteccion_punta_funcion(filename);
    
    x_ccd = [x_ccd x_0];
    y_ccd = [y_ccd y_0];
    
%     x_stage = [x_stage tag(2)];
%     y_stage = [y_stage tag(4)];
    x_stage = [x_stage str2double(tag(2))];
    y_stage = [y_stage str2double(tag(4))];

end

set(0,'DefaultFigureVisible', 'off');
%%
close all
h = figure(2);
plot(x_ccd, y_ccd, '.')
xlabel('x');
ylabel('y');
grid on
saveas(h, [path 'grilla'], 'png');

% close all
% h = figure(2);
% hold on
% for i = 1:numel(x_ccd)
%     plot(x_ccd(i), y_ccd(i), '.', 'MarkerSize', 20, 'DisplayName', ['x_s = ' num2str(x_stage(i)) ', y_s = ' num2str(y_stage(i))])
% end
% legend(gca, 'show', 'Location','Best')
% xlabel('x');
% ylabel('y');
% grid on
% saveas(h, [path 'grilla'], 'png');

output_file = fopen( [path 'LUT.txt'], 'wt' );
fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\n');

for i = 1:numel(x_ccd)
    %disp(sprintf('i = %d, x_ccd = %.2f, y_ccd = %.2f\n', i, x_ccd(i), y_ccd(i)));
    fprintf(output_file, '%.2f\t%.2f\t%.2f\t%.2f\n', x_stage(i), y_stage(i), x_ccd(i), y_ccd(i));
    %fprintf(output_file, '%.2f\t%.2f\t%.2f\t%.2f\n', x_stage{i}, y_stage{i}, x_ccd(i), y_ccd(i));
    %fprintf(output_file, '%.2f\t%.2f\t%.2f\t%.2f\n', 1, 2, 3, 4);
end

fclose all;
clear output_file;

