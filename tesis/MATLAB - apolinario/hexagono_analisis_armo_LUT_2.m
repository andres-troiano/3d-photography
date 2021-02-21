clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion18\';

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

% paso = round(N/150);
% for i = 1:paso:N
    
for i = 1:N

% for i = 1
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
    
    %%%%%%% esta parte cambia según analice la cámara 1 o la 2 %%%%%%%

    [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = receta_limpieza_datos_2(datos_x, datos_y, camara);
    
    % fin receta
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % coordenadas de la punta en pixels
    punta_px = (b2 - b1)/(a1 - a2);
    punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

    %%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    param_rectas = [a1, b1, a2, b2];

    [fig_name, flag_descarte] = descarte_perfil_invalido(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    close all
    h = figure(1);
    hold on
    plot(perfil, '.-k')
    
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')

    plot(datos_x_1, recta_1, '--b')
    plot(datos_x_2, recta_2, '--r')
    
    plot(punta_px, punta_py, '*r')
%     plot(x_P1, y_P1, '*b')
%     plot(x_P2, y_P2, '*m')
    
    margen = 25;
    
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
    xlim([min(datos_x)-margen max(datos_x)+margen])
    ylim([min(datos_y)-margen max(datos_y)+margen])
    
    %%%%%%%% guardo los gráficos %%%%%%%%
    
    saveas(h, [path dir_camara fig_name], 'png');
%     saveas(h, [path dir_camara fig_name]);
    
    %%%%%%%%%%%%%%%%%%% guardo los datos curados %%%%%%%%%%%%%%%%%%%
    
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

% esto ya no lo usaría más

%%%%%%%%%%%%%%%%%%%%%% receta para la camara 2 (vieja) %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% clear variables
% 
% % ahora cargo solo los frames utiles, y analizo
% path = 'C:\Users\60069978\Documents\MATLAB\medicion09\';
% camara = '2';
% 
% dir_camara = ['camara_' camara '\'];
% list = dir([path dir_camara 'LUT_camara*.png']);
% fnames = {list.name};
% 
% %%%%%%%%%%%%%%%%%%%
% 
% % cargo el txt que tiene las coords medidas
% datos = importdata([path 'coord_pedidas_vs_medidas.txt'], '\t', 1);
% datos = datos.data;
% 
% x_pedido = datos(:, 1);
% y_pedido = datos(:, 2);
% x_medido = datos(:, 3);
% y_medido = datos(:, 4);
% 
% %%%%%%%%%%%%%%%%%%%
% 
% x_ccd = [];
% y_ccd = [];
% 
% x_stage = [];
% y_stage = [];
% 
% x_P1 = [];
% y_P1 = [];
% 
% x_P2 = [];
% y_P2 = [];
% 
% set(0,'DefaultFigureVisible', 'off');
% 
% for i = 1:numel(x_pedido)
% % for i = 1
% 
%     sprintf('Paso %d de %d', i, numel(x_pedido))
% 
%     tag_x = num2str(x_pedido(i));
%     tag_y = num2str(y_pedido(i));
%     
%     filename = dir([path dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png']);
%     filename = {filename.name};
%     
%     if numel(filename) == 0
%         continue
%     end
%     
%     filename = filename{1};
%     filename = [path dir_camara filename];
%     
% %     filename = [path dir_camara '\LUT_camara_' camara '_frame_x_125_y_450.png'];
% 
%     frame = imread(filename);
% 
%     perfil = median(frame);
%     perfil = double(perfil)/2^4;
% 
%     perfil_x = 1:1:numel(perfil);
%     
%     indices_no_nulos = perfil ~= 0;
%     datos_y = perfil(indices_no_nulos);
%     datos_x = perfil_x(indices_no_nulos);
%     
%     % receta nueva 2
%     %%%%%%%%%%%%%%%%%%
%     [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 2);
%     [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);
%     [datos_y, datos_x] = filtro_saltos_grandes(datos_y, datos_x, 3);
%     [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, 1, 3);
%     [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
%     [datos_y, datos_x] = filtro_saltos_grandes(datos_y, datos_x, 3);
% 
%     % ahora itero ajustes + filtrado de outliers
%     cant_sigmas = [3 3 3];
% %     
%     for k = 1:3
%         [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
%         datos_x = [datos_x_1, datos_x_2];
%         datos_y = [datos_y_1, datos_y_2];
%     end
%     
%     % coordenadas de la punta en pixels
%     punta_px = (b2 - b1)/(a1 - a2);
%     punta_py = a1*(b2 - b1)/(a1 - a2) + b1;
% 
%     %%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%     
%     extremo_izq_y = datos_y(1);
%     extremo_der_y = datos_y(end);
%     
%     % ahora voy a poner condiciones para descartar frames malos
%     % hago un flag que dice si el perfil se descartó, para no tabular ese
%     % dato
%     
%     flag_descarte = 0;
%     
%     % tiro aquellos perfiles donde la "punta" no es la que yo deseo
%     if punta_py > extremo_izq_y || punta_py > extremo_der_y
%         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         flag_descarte = 1;
%     end
%     
%     % tiro perfiles donde casi no se ve el flanco izquierdo
%     % delta_x_1 es el rango en px_x que cubre el flanco izquierdo
%     delta_x_1 = datos_x_1(end) - datos_x_1(1);
%     if delta_x_1 <= 5
%         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         flag_descarte = 2;
%     end
%     
%     % idem lado derecho
%     delta_x_2 = datos_x_2(end) - datos_x_2(1);
%     if delta_x_2 <= 5
%         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         flag_descarte = 3;
%     end
%     
%     % tiro perfiles donde las 2 pendientes tienen el mismo signo
%     if a1*a2 > 0 % (tienen igual signo)
%         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         flag_descarte = 4;
%     end
%     
%     % tiro perfiles donde la punta salió cortada porque se salió del campo
%     % visual de la cámara. Pongo 5 px como tamaño límite del hueco
%     
%     hueco = datos_x_2(1) - datos_x_1(end);
%     if hueco > 5
%         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         flag_descarte = 5;
%     end
%     
%     % si una región salió con muy pocos puntos (porque no se alcanzó a
%     % ver), tiro el frame. Corto en 10 puntos. Acá lo hago sólo para la
%     % región izquierda, que es donde lo observé
%     if numel(datos_x_1) < 10
%         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
%         flag_descarte = 6;
%     end
%     
%     % idem lado derecho
%     if numel(datos_x_2) < 10
%         flag_descarte = 7;
%     end
%     
%     close all
%     h = figure(1);
%     hold on
%     plot(perfil, '.-k')
%     
%     plot(datos_x_1, datos_y_1, '.g')
%     plot(datos_x_2, datos_y_2, '.y')
% 
%     plot(datos_x_1, recta_1, '--b')
%     plot(datos_x_2, recta_2, '--r')
%     
%     plot(punta_px, punta_py, '*r')
%     
%     margen = 25;
%     
%     grid on
%     xlabel('pixel x')
%     ylabel('pixel y')
%     xlim([min(datos_x)-margen max(datos_x)+margen])
%     ylim([min(datos_y)-margen max(datos_y)+margen])
%     
%     %%%%%%%% guardo los gráficos %%%%%%%%
%     
%     saveas(h, [path dir_camara fig_name], 'png');
%     saveas(h, [path dir_camara fig_name]);
%     
%     %%%%%%%%%%%%%%%%%%% guardo los datos curados %%%%%%%%%%%%%%%%%%%
%     
%     if flag_descarte == 0
%         x_ccd = [x_ccd punta_px];
%         y_ccd = [y_ccd punta_py];
% 
%         x_stage = [x_stage x_medido(i)];
%         y_stage = [y_stage y_medido(i)];
%         
%         x_P1 = [x_P1 datos_x_1(1)];
%         y_P1 = [y_P1 recta_1(1)];
%         
%         x_P2 = [x_P2 datos_x_2(end)];
%         y_P2 = [y_P2 recta_2(end)];
%         
%         output_datos_curados = fopen( [path dir_camara 'LUT_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
%         fprintf(output_datos_curados, 'datos_x\tdatos_y\n');
%         
%         for j = 1:numel(datos_x)
%             fprintf(output_datos_curados, '%f\t%f\n', datos_x(j), datos_y(j));
%         end
%         
%         fclose all;
%         clear output_datos_curados;
%     end
%     
% end
% 
% %%%%%%%%%%%%% armo la tabla %%%%%%%%%%%%%
% 
% output_file = fopen( [path 'LUT_camara_' camara '.txt'], 'wt' );
% fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\tx_P1\ty_P1\tx_P2\ty_P2\n');
% 
% for i = 1:numel(x_ccd)
%     fprintf(output_file, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', x_stage(i), y_stage(i), x_ccd(i), y_ccd(i), x_P1(i), y_P1(i), x_P2(i), y_P2(i));
% end
% 
% fclose all;
% clear output_file;

%%
% este comando es para cuando estoy haciendo pruebas, que todo el tiempo
% necesito borrar los resultados y empezar de nuevo
    
vacio_directorio(path, camara)