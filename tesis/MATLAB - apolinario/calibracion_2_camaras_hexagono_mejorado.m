clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion18\';

creo_directorios_2_camaras(path);

separar_frames_utiles(path, 1);
separar_frames_utiles(path, 2);

%%

camara = '2';

dir_camara = ['camara_' camara '\'];
list = dir([path dir_camara 'LUT_camara*.png']);
fnames = {list.name};

tiempo_restante = inf;
periodo_estadistica = [];
periodo = nan;

%%%%%%%%%%%%%%%%%%%

% cargo el txt que tiene las coords medidas
datos = importdata([path 'coord_pedidas_vs_medidas.txt'], '\t', 1);
datos = datos.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);
x_medido = datos(:, 3);
y_medido = datos(:, 4);

%%%%%%%%%%%%%%%%%%%

tag_x_array = [];
tag_y_array = [];

x_ccd = [];
y_ccd = [];

x_stage = [];
y_stage = [];

x_P1_array = [];
y_P1_array = [];

x_P2_array = [];
y_P2_array = [];

set(0,'DefaultFigureVisible', 'off');

% cargo la lista negra
% if camara == '2'
%     datos = importdata([path 'lista_negra_camara_2.txt'], '\t', 1);
%     datos = datos.data;
% 
%     x_negro = datos(:, 1);
%     y_negro = datos(:, 2);
% end
    
N = numel(x_pedido);

% for i = 1

% paso = round(N/150);
% for i = 1:paso:N
    
for i = 1:N

% for i = 100

    tic

    sprintf('Paso %d de %d, período = %.2f s', i, numel(x_pedido), periodo)

    tag_x = num2str(x_pedido(i));
    tag_y = num2str(y_pedido(i));
    
%     if camara == '2'
%         % si está en la lista negra lo paso de largo
%         for j = 1:numel(x_negro)
%             if x_pedido(i) == x_negro(j) && y_pedido(i) == y_negro(j)
%                 continue
%             end
%         end
%     end
    
%     tag_x = '220';
%     tag_y = '420';
    
    filename = dir([path dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png']);
    filename = {filename.name};
    
    if numel(filename) == 0
        continue
    end
    
    % si el filename existe, llamo a la función que hace todo (y no uso más
    % el filename, sino que busco por tag)
    
    % todo lo que necesito lo calcula la función
    [punta_px, punta_py, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2, flag_descarte] = hexagono_individual_funcion(path, camara, tag_x, tag_y, 'off', 1);

    x = [datos_x_1, datos_x_2];
    y = [datos_y_1, datos_y_2];

    if flag_descarte == 0
        
        tag_x_array = [tag_x_array x_pedido(i)];
        tag_y_array = [tag_y_array y_pedido(i)];
        
        x_ccd = [x_ccd punta_px];
        y_ccd = [y_ccd punta_py];

        x_stage = [x_stage x_medido(i)];
        y_stage = [y_stage y_medido(i)];
        
        % armo 2 puntos con los cuales, junto con la punta, medir el ángulo
        % P1 es el primer punto de la recta_1, y P2 es el último de recta_2
        x_P1_array = [x_P1_array datos_x_1(1)];
        y_P1_array = [y_P1_array recta_1(1)];
        
        x_P2_array = [x_P2_array datos_x_2(end)];
        y_P2_array = [y_P2_array recta_2(end)];
        
        output_datos_curados = fopen( [path dir_camara 'LUT_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
        fprintf(output_datos_curados, 'datos_x\tdatos_y\n');
        
        for j = 1:numel(x)
            fprintf(output_datos_curados, '%f\t%f\n', x(j), y(j));
        end
        
        fclose all;
        clear output_datos_curados;
    end
    
    periodo = toc;
    
end

%%%%%%%%%%%%% armo la tabla %%%%%%%%%%%%%

output_file = fopen( [path 'camara_' camara '\LUT_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'tag_x\ttag_y\tx_stage\ty_stage\tx_ccd\ty_ccd\tx_P1\ty_P1\tx_P2\ty_P2\n');

for i = 1:numel(x_ccd)
    fprintf(output_file, '%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', tag_x_array(i), tag_y_array(i), x_stage(i), y_stage(i), x_ccd(i), y_ccd(i), x_P1_array(i), y_P1_array(i), x_P2_array(i), y_P2_array(i));
end

fclose all;
clear output_file;


%%
    
vacio_directorio(path, camara)