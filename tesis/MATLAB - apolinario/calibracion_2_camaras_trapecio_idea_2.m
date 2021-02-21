clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion17\';

creo_directorios_2_camaras(path);

separar_frames_utiles(path, 1);
separar_frames_utiles(path, 2);

%%

% ahora modifiqué esto para que sirva para las 2 cámaras
% solo hay que cambiar el str "camara", y descomentar la "receta" apropiada 
% lo cambié para que no haya que descomentar nada
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear variables

% ahora cargo solo los frames utiles, y analizo
% path = 'C:\Users\60069978\Documents\MATLAB\medicion12\';
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

N = numel(x_pedido);

% for i = 1

% paso = round(N/50);
% for i = 1:paso:N
    
for i = 1:N

% for i = 697
    tic

    sprintf('Paso %d de %d, período = %.2f s', i, numel(x_pedido), periodo)

    tag_x = num2str(x_pedido(i));
    tag_y = num2str(y_pedido(i));
    
%     tag_x = '220';
%     tag_y = '420';
    
    filename = dir([path dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png']);
    filename = {filename.name};
    
    if numel(filename) == 0
        continue
    end
    
    filename = filename{1};
    filename = [path dir_camara filename];
    
%     filename = [path dir_camara '\LUT_camara_' camara '_frame_x_125_y_450.png'];

    frame = imread(filename);

    y = median(frame);
    y = double(y)/2^4;

    x = 1:1:numel(y);

    [x, y] = tiro_datos_nulos_perfil(x, y);

    [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(y, x, -1, 3);
    [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);

    datos_x = datos_x(3:end-2);
    datos_y = datos_y(3:end-2);

    [datos_x, datos_y] = tiro_base_trapecio(datos_x, datos_y, camara);

    if datos_x(end) - datos_x(1) > 600
        [datos_x, datos_y] = tiro_mitad_datos(datos_x, datos_y, camara);
    end

    % close all
    % figure
    % hold on
    % grid on
    % 
    % plot(x, y, '.-k')
    % plot(datos_x, datos_y, '.b')

    for j = 1:2

        [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_trapecio(datos_x, datos_y, camara);
        [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

        % acá chequeo si tengo que redefinir los dominios y volver a correr
        [datos_x, datos_y] = redefino_dominio(x, y, datos_x, datos_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_px, punta_py, a1, a2, camara);

    end

    [datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(x, y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
    [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

    %%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    param_rectas = [a1, b1, a2, b2];

    [fig_name, flag_descarte] = descarte_perfil_invalido_trapecio(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);

    flag_descarte

    % % numel(datos_x_1) + numel(datos_x_2)
    % numel(datos_x_1)
    % numel(datos_x_2)

    close all
    h = figure(1);
    hold on
    grid on

    plot(x, y, '.-k')
    plot(datos_x, datos_y, '.b')
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')
    plot(punta_px, punta_py, '*r')

    xlabel('pixel x')
    ylabel('pixel y')
%     xlim([min([datos_x_1, datos_x_2])-margen max([datos_x_1, datos_x_2])+margen])
%     ylim([min([datos_y_1, datos_y_2])-margen max([datos_y_1, datos_y_2])+margen])
%     

    x = [datos_x_1, datos_x_2];
    y = [datos_y_1, datos_y_2];

    if numel(x) > 0
        xlim([min(x)-margen max(x)+margen])
        ylim([min(y)-margen max(y)+margen])
    end

    %%%%%%%% guardo los gráficos %%%%%%%%
    
    saveas(h, [path dir_camara fig_name], 'png');
%     saveas(h, [path dir_camara fig_name]);
    
    %%%%%%%%%%%%%%%%%%% guardo los datos curados %%%%%%%%%%%%%%%%%%%
    
% disp('4')

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

% disp('5')
    
end

% disp('6')

%%%%%%%%%%%%% armo la tabla %%%%%%%%%%%%%

output_file = fopen( [path 'camara_' camara '\LUT_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'tag_x\ttag_y\tx_stage\ty_stage\tx_ccd\ty_ccd\tx_P1\ty_P1\tx_P2\ty_P2\n');

for i = 1:numel(x_ccd)
    fprintf(output_file, '%d\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', tag_x_array(i), tag_y_array(i), x_stage(i), y_stage(i), x_ccd(i), y_ccd(i), x_P1_array(i), y_P1_array(i), x_P2_array(i), y_P2_array(i));
end

fclose all;
clear output_file;


%%
% este comando es para cuando estoy haciendo pruebas, que todo el tiempo
% necesito borrar los resultados y empezar de nuevo
    
vacio_directorio(path, camara)