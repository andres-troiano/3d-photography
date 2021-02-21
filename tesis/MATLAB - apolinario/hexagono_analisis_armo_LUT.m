clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion07\';

%%
% 
% % separo los frames utiles de la camara 1
% 
% list = dir([path 'LUT_camara_1*.png']);
% fnames = {list.name};
% 
% set(0,'DefaultFigureVisible', 'off');
% 
% for i = 1:numel(fnames)
% % for i = 1
% 
%     sprintf('Paso %d de %d', i, numel(fnames))
%     
%     filename = [path fnames{i}];
%     
%     % identificación del frame
%     tag = strsplit(filename, '.');
%     tag = tag{1};
%     tag = strsplit(tag, 'camara_');
%     tag = tag{2};
%     tag = strsplit(tag, '_');
%     camara = tag{1};
%     tag_x = tag{4};
%     tag_y = tag{6};
%     
%     frame = imread(filename);
% 
%     perfil = median(frame);
%     perfil = double(perfil)/2^4;
%     
%     datos_x = [];
%     datos_y = [];
% 
%     for i = 1:numel(perfil)
%         if perfil(i) ~= 0
%             datos_x = [datos_x i];
%             datos_y = [datos_y perfil(i)];
%         end
%     end
%     
%     fig_name = ['camara_1\LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];
%     
%     % tiro frames donde no se vio nada, o se vio algún ruido nomás
%     if numel(datos_x) <= 10
%         continue
%     end
%     
%     % los buenos los guardo en \camara_1
%     imwrite(frame, [path fig_name]);
%     
% end
% 
% %%
% 
% % separo los frames utiles de la camara 2
% 
% list = dir([path 'LUT_camara_2*.png']);
% fnames = {list.name};
% 
% set(0,'DefaultFigureVisible', 'off');
% 
% for i = 1:numel(fnames)
% % for i = 1
% 
%     sprintf('Paso %d de %d', i, numel(fnames))
%     
%     filename = [path fnames{i}];
%     
%     % identificación del frame
%     tag = strsplit(filename, '.');
%     tag = tag{1};
%     tag = strsplit(tag, 'camara_');
%     tag = tag{2};
%     tag = strsplit(tag, '_');
%     camara = tag{1};
%     tag_x = tag{4};
%     tag_y = tag{6};
%     
%     frame = imread(filename);
% 
%     perfil = median(frame);
%     perfil = double(perfil)/2^4;
%     
%     datos_x = [];
%     datos_y = [];
% 
%     for i = 1:numel(perfil)
%         if perfil(i) ~= 0
%             datos_x = [datos_x i];
%             datos_y = [datos_y perfil(i)];
%         end
%     end
%     
%     fig_name = ['camara_2\LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];
%     
%     % tiro frames donde no se vio nada, o se vio algún ruido nomás
%     if numel(datos_x) <= 10
%         continue
%     end
%     
%     % los buenos los guardo en \frames_utiles
%     imwrite(frame, [path fig_name]);
%     
% end

%%

clear variables

% ahora cargo solo los frames utiles, y analizo
path = 'C:\Users\60069978\Documents\MATLAB\medicion07\';
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

x_ccd = [];
y_ccd = [];

x_stage = [];
y_stage = [];

set(0,'DefaultFigureVisible', 'on');

% for i = 1:numel(x_pedido)
for i = 40

    sprintf('Paso %d de %d', i, numel(x_pedido))

    tag_x = num2str(x_pedido(i));
    tag_y = num2str(y_pedido(i));
    
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
    
    
    
    
    % tiro saltos grandes y valores inusuales
    
    [aux_y, aux_x] = filtro_saltos_grandes(datos_y, datos_x, 1);
    [aux_x, aux_y] = filtro_saltos_grandes(aux_x, aux_y, 1);

    [aux_x, aux_y] = filtro_valores_inusuales(aux_x, aux_y, 1, 3);
    [aux_y, aux_x] = filtro_valores_inusuales(aux_y, aux_x, 1, 1);
    [aux_y, aux_x] = filtro_valores_inusuales(aux_y, aux_x, -1, 1);

    [aux_y, aux_x] = filtro_saltos_grandes(aux_y, aux_x, 1);
    
    [aux_x, aux_y] = filtro_valores_inusuales(aux_x, aux_y, -1, 3);

    datos_x = aux_x;
    datos_y = aux_y;
    
    
%     
%     
%     % ahora itero ajustes + filtrado de outliers
%     cant_sigmas = [3 3 3];
%     
% %     for k = 1:numel(cant_sigmas)
%     for k = 1:3
% 
%         % corro un ajuste y obtengo un parámetro óptimo (el separador)
%         [y_min, indice_min] = min(datos_y);
%         x_min = datos_x(indice_min);
% 
%         X0 = x_min;
% 
%         f = @(x)ajuste_punta_1_param_2_camaras(x, datos_x, datos_y);
%         [x, fval] = fminsearch(f, X0);
%         % fminbnd (mas rapido)
%         
%         % era un valor de x, no un índice
%         separador_optimo = x;
%         
%         % ahora veo qué datos están dentro de sigma
%         % para definir el umbral tengo que ajustar linealmente
% 
%         indices_region_1 = datos_x < separador_optimo;
% 
%         datos_x_1 = datos_x(indices_region_1);
%         datos_y_1 = datos_y(indices_region_1);
% 
%         datos_x_2 = datos_x(~indices_region_1);
%         datos_y_2 = datos_y(~indices_region_1);
%         
%         %%%%%%%%%%%%%%% esto es bueno? %%%%%%%%%%%%%%%
%          % todavía veo ruido arriba a la izquiera (en la cámara vieja)
% %         tiro todo lo que está por encima de 50 pixels arriba del máximo
% %         de la región 1
% 
%         datos_x_2 = datos_x_2(datos_y_2 < max(datos_y_1) + 50);
%         datos_y_2 = datos_y_2(datos_y_2 < max(datos_y_1) + 50);
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%         [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
%         [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);
% 
%         [recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
%         [recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);
%         
%         umbral_superior_1 = recta_1 + cant_sigmas(k)*delta_1;
%         umbral_inferior_1 = recta_1 - cant_sigmas(k)*delta_1;
%         indices_filtrados_1 = datos_y_1 < umbral_superior_1 & datos_y_1 > umbral_inferior_1;
%         
%         umbral_superior_2 = recta_2 + cant_sigmas(k)*delta_2;
%         umbral_inferior_2 = recta_2 - cant_sigmas(k)*delta_2;
%         indices_filtrados_2 = datos_y_2 < umbral_superior_2 & datos_y_2 > umbral_inferior_2;
%         
%         
%         % para mí la solución que necesito es usar la info del ajuste para ir
%         % refinando cada vez. Voy a tener que reutilizar la info original
% 
%         % un criterio posible es que si lo que me quedó dentro del rango
%         % permitido es conexo, lo que quedó afuera de ese mismo lado (1 o 2)
%         % lo tiro. Es lo que está pasando del lado derecho en este caso. Del
%         % lado izq en cambio me estaría tirando datos buenos, entonces por
%         % ahora eso lo quiero dejar igual y esperar a que mejore una vez que
%         % haya tirado el ruido del lado derecho
%         
%         % miro el incremento más grande observado en los datos originales y
%         % en los filtrados, y me fijo que en los filtrados nunca el paso
%         % sea mayor de lo que era en los datos originales, porque eso
%         % significa que se creó un hueco en el medio
%         
%         % región 1
%         datos_x_1_filtrado = datos_x_1(indices_filtrados_1);
%         datos_y_1_filtrado = datos_y_1(indices_filtrados_1);
%         
%         paso_max_x_1 = max(diff(datos_x_1));
%         paso_max_x_1_filtrado = max(diff(datos_x_1_filtrado));
%         
%         if paso_max_x_1_filtrado > paso_max_x_1
% %             disp('True 1')
%             indices_filtrados_1 = true(size(datos_x_1));
%         end
%         
%         % región 2
%         datos_x_2_filtrado = datos_x_2(indices_filtrados_2);
%         datos_y_2_filtrado = datos_y_2(indices_filtrados_2);
%         
%         paso_max_x_2 = max(diff(datos_x_2));
%         paso_max_x_2_filtrado = max(diff(datos_x_2_filtrado));
%         
%         if paso_max_x_2_filtrado > paso_max_x_2
% %             disp('True 2')
%             indices_filtrados_2 = true(size(datos_x_2));
%         end
%         
%         % OJO! lo que viene a continuación no entra en el cálculo de la
%         % última recta! (de las 2 primeras sí)
% %         Tendría que agregar un ajuste más al final?
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % IDEA
%         % antes de componer, tirar los outliers
%         
%         aux_2_x = datos_x_2(indices_filtrados_2);
%         aux_2_y = datos_y_2(indices_filtrados_2);
% 
%         delta_2_x = diff(aux_2_x);
%         delta_2_y = diff(aux_2_y);
% 
%         pendiente_2 = delta_2_y./delta_2_x;
% 
%         median_pendiente_2 = median(pendiente_2);
%         sigma_pendiente_2 = std(pendiente_2);
% 
%         filtro_outliers_2 = pendiente_2 < median_pendiente_2 + 1*sigma_pendiente_2;
%         
% 
%         datos_x = [datos_x_1(indices_filtrados_1), aux_2_x(filtro_outliers_2)];
%         datos_y = [datos_y_1(indices_filtrados_1), aux_2_y(filtro_outliers_2)];
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         
%         
%     end
    
    % calculo la intersección de las 2 rectas
    a1 = pol_1(1);
    b1 = pol_1(2);

    a2 = pol_2(1);
    b2 = pol_2(2);
    
    % coordenadas de la punta en pixels
    punta_px = (b2 - b1)/(a1 - a2);
    punta_py = a1*(b2 - b1)/(a1 - a2) + b1;
    
    %%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    extremo_izq_y = datos_y_1(indices_filtrados_1);
    extremo_izq_y = extremo_izq_y(1);
    
    extremo_der_y = datos_y_2(indices_filtrados_2);
    extremo_der_y = extremo_der_y(end);
    
    % ahora voy a poner condiciones para descartar frames malos
    % hago un flag que dice si el perfil se descartó, para no tabular ese
    % dato
    
    flag_descarte = 0;
    
    % tiro aquellos perfiles donde la "punta" no es la que yo deseo
    if punta_py > extremo_izq_y || punta_py > extremo_der_y
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = 1;
    end
    
    % tiro perfiles donde casi no se ve el flanco izquierdo
    % delta_x_1 es el rango en px_x que cubre el flanco izquierdo
    aux_1 = datos_x_1(indices_filtrados_1);
    delta_x_1 = aux_1(end) - aux_1(1);
    if delta_x_1 <= 5
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = 1;
    end
    
    % tiro perfiles donde las 2 pendientes tienen el mismo signo
    if a1*a2 > 0 % (tienen igual signo)
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = 1;
    end
    
    % tiro perfiles donde la punta salió cortada porque se salió del campo
    % visual de la cámara. Pongo 5 px como tamaño límite del hueco
    
    aux_2 = datos_x_2(indices_filtrados_2);
    if aux_2(1) - aux_1(end) > 5
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = 1;
    end
    
    % si una región salió con muy pocos puntos (porque no se alcanzó a
    % ver), tiro el frame. Corto en 10 puntos. Acá lo hago sólo para la
    % región izquierda, que es donde lo observé
    if numel(aux_1) < 10
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = 1;
    end
    
    close all
    h = figure(1);
    hold on
    plot(perfil, '.-k')
    
    
    plot(datos_x_1(indices_filtrados_1), datos_y_1(indices_filtrados_1), '.g')
    plot(datos_x_2(indices_filtrados_2), datos_y_2(indices_filtrados_2), '.y')
%     plot(datos_x, datos_y, '.b')
    
%     plot(datos_x_1, umbral_superior_1, '--r')    
%     plot(datos_x_1, umbral_inferior_1, '--k')
%     
%     plot(datos_x_2, umbral_superior_2, '--r')    
%     plot(datos_x_2, umbral_inferior_2, '--k')

    plot(datos_x_1, recta_1, '--b')
    plot(datos_x_2, recta_2, '--r')
    
    plot(punta_px, punta_py, '*r')
    
    margen = 25;
    
    grid on
    xlabel('pixel x')
    ylabel('pixel y')
    xlim([min(datos_x)-margen max(datos_x)+margen])
    ylim([min(datos_y)-margen max(datos_y)+margen])
    
    %%%%%%%% guardo los gráficos %%%%%%%%
    
    saveas(h, [path dir_camara fig_name], 'png');
%     saveas(h, [path camara fig_name]);
    
    %%%%%%%%%%%%%%%%%%% armo la tabla %%%%%%%%%%%%%%%%%%%
    
    % acá tabulo sólo los datos que me interesan
    % y guardo los datos curados en un txt por cada perfil
    
    % armo una matriz con los datos curados
    % guardo todo el perfil en lugar de guardarlo ya separado, porque cada
    % flanco tiene distinto tamaño. Sino tendría que guardar 1 txt por cada
    % flanco
    % la info por columnas es:
    % datos_x, datos_y
    % hasta acá esa información está en filas
    
    datos_curados_x = [datos_x_1(indices_filtrados_1) datos_x_2(indices_filtrados_2)];
    datos_curados_y = [datos_y_1(indices_filtrados_1) datos_y_2(indices_filtrados_2)];

    
    
    if flag_descarte == 0
        x_ccd = [x_ccd punta_px];
        y_ccd = [y_ccd punta_py];

        x_stage = [x_stage x_medido(i)];
        y_stage = [y_stage y_medido(i)];
        
        output_datos_curados = fopen( [path dir_camara 'LUT_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
        fprintf(output_datos_curados, 'datos_x\tdatos_y\n');
        
        for j = 1:numel(datos_curados_x)
            fprintf(output_datos_curados, '%f\t%f\n', datos_curados_x(j), datos_curados_y(j));
        end
        
        fclose all;
        clear output_datos_curados;
    end
    
end

%%%%%%%%%%%%% armo la tabla %%%%%%%%%%%%%

output_file = fopen( [path 'LUT_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\n');

for i = 1:numel(x_ccd)
    fprintf(output_file, '%f\t%f\t%f\t%f\n', x_stage(i), y_stage(i), x_ccd(i), y_ccd(i));
end

fclose all;
clear output_file;