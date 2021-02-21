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

paso = round(N/250);
for i = 1:paso:N
    
% for i = 1:N

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

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    perfil_x = 1:1:numel(perfil);
    
    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);
    
% disp('1')



    % si veo el trapecio entero, me quedo sólo con la mitad que me sirve
    % asumo que el perfil ocupa aprox 500 pixels en x
    if datos_x(end) - datos_x(1) > 850
        [datos_x, datos_y] = tiro_mitad_datos(datos_x, datos_y, camara);
    end

    % la cantidad de iteraciones puede depender de cada cámara
    J = 0;
    if camara == '1'
        J = 2;
    elseif camara == '2'
        J = 2;
    end

    for j = 1:J

        [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_trapecio(datos_x, datos_y, camara);

        % coordenadas de la punta en pixels
        punta_px = (b2 - b1)/(a1 - a2);
        punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

%         numel(datos_x)

        % acá chequeo si tengo que redefinir los dominios y volver a correr
        [datos_x, datos_y] = redefino_dominio(perfil_x, perfil, datos_x, datos_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_px, punta_py, a1, a2, camara);

    end
    
% disp('2')

    % fin receta
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);

    if camara == '1'
        % tiro posibles cosas no deseadas que se hayan sumado
        [datos_x, datos_y] = filtro_basura_derecha(datos_x, datos_y, 20);

    %     vuelvo a calcular punta óptima sin esos datos
        [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, 3);
        [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

        [datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    param_rectas = [a1, b1, a2, b2];
    [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

    [fig_name, flag_descarte] = descarte_perfil_invalido_trapecio(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);

% disp('3')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    close all
    h = figure(1);
    hold on
    plot(perfil, '.-k')
    
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')    
    plot(punta_px, punta_py, '*r')
    
    margen = 25;
    
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
%     xlim([min([datos_x_1, datos_x_2])-margen max([datos_x_1, datos_x_2])+margen])
%     ylim([min([datos_y_1, datos_y_2])-margen max([datos_y_1, datos_y_2])+margen])
%     

    datos_x = [datos_x_1, datos_x_2];
    datos_y = [datos_y_1, datos_y_2];

    if numel(datos_x) > 0
        xlim([min(datos_x)-margen max(datos_x)+margen])
        ylim([min(datos_y)-margen max(datos_y)+margen])
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
        
        for j = 1:numel(datos_x)
            fprintf(output_datos_curados, '%f\t%f\n', datos_x(j), datos_y(j));
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