clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion06\';

%%

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

%%

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
path = 'C:\Users\60069978\Documents\MATLAB\medicion06\';
camara = '1';

dir_camara = ['camara_' camara '\'];
list = dir([path dir_camara 'LUT_camara*.png']);
fnames = {list.name};

tiempo_restante = inf;
periodo_estadistica = [];
periodo = nan;

set(0,'DefaultFigureVisible', 'off');

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

% for i = 1:numel(fnames)
for i = 1:numel(x_pedido)
% for i = 1

    
    
    if i > 1
        periodo_estadistica = [periodo_estadistica periodo];
        tiempo_restante = (numel(fnames) - i)*mean(periodo_estadistica);
        
        porcentaje = i/numel(fnames);
    
        if tiempo_restante < 60
            fprintf('%.0f%% completado. Tiempo restante: %.0f segundos aprox.\n', 100*porcentaje, tiempo_restante)
        end

        if tiempo_restante > 60
            fprintf('%.0f%% completado. Tiempo restante: %.1f minutos aprox.\n', 100*porcentaje, tiempo_restante/60)
        end
    end
    
    tic
    
    filename = dir([path dir_camara 'LUT_camara_' camara '_frame_x_' num2str(x_pedido(i)) '_y_' num2str(y_pedido(i)) '.png']);
%     filename = {filename.name};
    filename = {filename.name};
    
    if numel(filename) == 0
        [num2str(x_pedido(i)), num2str(y_pedido(i)), 'CONTINUE']
        continue
    end
    
    filename = filename{1};
    filename = [path dir_camara filename];
%     filename = [path dir_camara 'LUT_camara_' camara '_frame_x_' num2str(x_pedido(i)) '_y_' num2str(y_pedido(i)) '.png'];
%     filename = [path camara fnames{i}];
%     filename = [path 'LUT_camara_1_frame_x_250_y_350.png'];

    
    
    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    perfil_x = 1:1:numel(perfil);
    
    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);

%     whos datos_y
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % en muchos casos veo ruido aislado a la derecha del perfil. Está
    % aprox a 100 pixels, así que voy a tirar lo que esté a más de 50.
    % una vez que encuentro un salto mayor a 50, corto. Lo que sigue no
    % me interesa
    % trato de tirarlos mirando la mediana en x,y
    
    mediana_x = median(datos_x);
    sigma_x = std(datos_x);
    
    mediana_y = median(datos_y);
    sigma_y = std(datos_y);
    
    % lado derecho
    corte_x = mediana_x + 3*sigma_x;

    indices_mediana_x = datos_x < corte_x;
    datos_x = datos_x(indices_mediana_x);
    datos_y = datos_y(indices_mediana_x);
    
    % lado de abajo
    corte_y = mediana_y - 3*sigma_y;

    indices_mediana_y = datos_y > corte_y;
    datos_x = datos_x(indices_mediana_y);
    datos_y = datos_y(indices_mediana_y);
    
    % después de haber tirado una parte, recalculo las medianas y
    % dispersiones
    mediana_x = median(datos_x);
    sigma_x = std(datos_x);
    
    mediana_y = median(datos_y);
    sigma_y = std(datos_y);
    
    % lado izquierdo
    corte_x = mediana_x - 3*sigma_x;

    indices_mediana_x = datos_x > corte_x;
    datos_x = datos_x(indices_mediana_x);
    datos_y = datos_y(indices_mediana_x);
    
    % lado de arriba
    corte_y = mediana_y + 3*sigma_y;

    indices_mediana_y = datos_y < corte_y;
    datos_x = datos_x(indices_mediana_y);
    datos_y = datos_y(indices_mediana_y);
    
    % ahora itero ajustes + filtrado de outliers
    cant_sigmas = [3 3 3];
    
%     for k = 1:numel(cant_sigmas)
    for k = 1:3

        % corro un ajuste y obtengo un parámetro óptimo (el separador)
        [y_min, indice_min] = min(datos_y);
        x_min = datos_x(indice_min);

        X0 = x_min;

        f = @(x)ajuste_punta_1_param_2_camaras(x, datos_x, datos_y);
        [x, fval] = fminsearch(f, X0);
        % fminbnd (mas rapido)
        
        % era un valor de x, no un índice
        separador_optimo = x;
        
        % ahora veo qué datos están dentro de sigma
        % para definir el umbral tengo que ajustar linealmente

        % por qué estoy separando en regiones 1 y 2 EN LOS 2 SCRIPTS?
%         a esta altura ya lo hizo el otro script, así que que me devuelva
%         las 2 regiones ya.
%         Cómo hago para minimizar uno de varios
%         parámetros de una función?


        indices_region_1 = datos_x < separador_optimo;

        datos_x_1 = datos_x(indices_region_1);
        datos_y_1 = datos_y(indices_region_1);

        datos_x_2 = datos_x(~indices_region_1);
        datos_y_2 = datos_y(~indices_region_1);

        [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
        [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);

        [recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
        [recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);
        
        umbral_superior_1 = recta_1 + cant_sigmas(k)*delta_1;
        umbral_inferior_1 = recta_1 - cant_sigmas(k)*delta_1;
        indices_filtrados_1 = datos_y_1 < umbral_superior_1 & datos_y_1 > umbral_inferior_1;
        
        umbral_superior_2 = recta_2 + cant_sigmas(k)*delta_2;
        umbral_inferior_2 = recta_2 - cant_sigmas(k)*delta_2;
        indices_filtrados_2 = datos_y_2 < umbral_superior_2 & datos_y_2 > umbral_inferior_2;
        
        
        % para mí la solución que necesito es usar la info del ajuste para ir
        % refinando cada vez. Voy a tener que reutilizar la info original

        % un criterio posible es que si lo que me quedó dentro del rango
        % permitido es conexo, lo que quedó afuera de ese mismo lado (1 o 2)
        % lo tiro. Es lo que está pasando del lado derecho en este caso. Del
        % lado izq en cambio me estaría tirando datos buenos, entonces por
        % ahora eso lo quiero dejar igual y esperar a que mejore una vez que
        % haya tirado el ruido del lado derecho
        
        % miro el incremento más grande observado en los datos originales y
        % en los filtrados, y me fijo que en los filtrados nunca el paso
        % sea mayor de lo que era en los datos originales, porque eso
        % significa que se creó un hueco en el medio
        
        % región 1
        datos_x_1_filtrado = datos_x_1(indices_filtrados_1);
        datos_y_1_filtrado = datos_y_1(indices_filtrados_1);
        
        paso_max_x_1 = max(diff(datos_x_1));
        paso_max_x_1_filtrado = max(diff(datos_x_1_filtrado));
        
        if paso_max_x_1_filtrado > paso_max_x_1
%             disp('True 1')
            indices_filtrados_1 = true(size(datos_x_1));
        end
        
        % región 2
        datos_x_2_filtrado = datos_x_2(indices_filtrados_2);
        datos_y_2_filtrado = datos_y_2(indices_filtrados_2);
        
        paso_max_x_2 = max(diff(datos_x_2));
        paso_max_x_2_filtrado = max(diff(datos_x_2_filtrado));
        
        if paso_max_x_2_filtrado > paso_max_x_2
%             disp('True 2')
            indices_filtrados_2 = true(size(datos_x_2));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % IDEA
        % antes de componer, tirar los outliers
        
        aux_2_x = datos_x_2(indices_filtrados_2);
        aux_2_y = datos_y_2(indices_filtrados_2);

        delta_2_x = diff(aux_2_x);
        delta_2_y = diff(aux_2_y);

        pendiente_2 = delta_2_y./delta_2_x;

        median_pendiente_2 = median(pendiente_2);
        sigma_pendiente_2 = std(pendiente_2);

        filtro_outliers_2 = pendiente_2 < median_pendiente_2 + 1*sigma_pendiente_2;
        

        datos_x = [datos_x_1(indices_filtrados_1), aux_2_x(filtro_outliers_2)];
        datos_y = [datos_y_1(indices_filtrados_1), aux_2_y(filtro_outliers_2)];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
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
    
    % identificación del frame
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'LUT_camara_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    dir_camara = tag{1};
    tag_x = tag{4};
    tag_y = tag{6};
    
    fig_name = ['plot_camara_' dir_camara '_x_' tag_x '_y_' tag_y];
    
    extremo_izq_y = datos_y_1(indices_filtrados_1);
    extremo_izq_y = extremo_izq_y(1);
    
    extremo_der_y = datos_y_2(indices_filtrados_2);
    extremo_der_y = extremo_der_y(end);
    
    % tiro aquellos perfiles donde la "punta" no es la que yo deseo
    if punta_py > extremo_izq_y || punta_py > extremo_der_y
        fig_name = ['descarte\plot_camara_' dir_camara '_x_' tag_x '_y_' tag_y];
    end
    
    % tiro perfiles donde casi no se ve el flanco izquierdo
    % delta_x_1 es el rango en px_x que cubre el flanco izquierdo
    aux_1 = datos_x_1(indices_filtrados_1);
    delta_x_1 = aux_1(end) - aux_1(1);
    if delta_x_1 <= 5
        fig_name = ['descarte\plot_camara_' dir_camara '_x_' tag_x '_y_' tag_y];
    end
    
    % tiro perfiles donde las 2 pendientes tienen el mismo signo
    if a1*a2 > 0 % (tienen igual signo)
        fig_name = ['descarte\plot_camara_' dir_camara '_x_' tag_x '_y_' tag_y];
    end
    
    % tiro perfiles donde la punta salió cortada porque se salió del campo
    % visual de la cámara. Pongo 5 px como tamaño límite del hueco
    
    aux_2 = datos_x_2(indices_filtrados_2);
    if aux_2(1) - aux_1(end) > 5
        fig_name = ['descarte\plot_camara_' dir_camara '_x_' tag_x '_y_' tag_y];
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
    
%     saveas(h, [path dir_camara fig_name], 'png');
%     saveas(h, [path camara fig_name]);
    
    periodo = toc;
    
    %%%%%%%%%%%%%%%%%%% armo la tabla %%%%%%%%%%%%%%%%%%%
    
    x_ccd = [x_ccd punta_px];
    y_ccd = [y_ccd punta_py];
    
    x_stage = [x_stage x_medido(i)];
    y_stage = [y_stage y_medido(i)];
    
end