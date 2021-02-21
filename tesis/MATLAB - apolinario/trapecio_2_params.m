function[medida] = trapecio_2_params(x, filename)

    % indices optimos para las esquinas
    indice_1 = x(1);
    indice_2 = x(2);
    
    indice_1 = round(indice_1);
    indice_2 = round(indice_2);

    frame = imread(filename);
    perfil = median(frame);
    perfil = double(perfil)/2^4;

    datos_x = [];
    datos_y = [];

    for i = 1:numel(perfil)
        if perfil(i) ~= 0
            datos_x = [datos_x i];
            datos_y = [datos_y perfil(i)];
        end
    end

    % digo que la base está a más de 300 más arriba del mínimo
    dist_trapecio_base = 300;

    datos_x_temp = [];
    datos_y_temp = [];

    N = numel(datos_x);
    for i = 1:N
        %if datos_y(i) < min(datos_y) + dist_trapecio_base
        if datos_y(i) < datos_y(round(N/2)) + dist_trapecio_base
            datos_x_temp = [datos_x_temp datos_x(i)];
            datos_y_temp = [datos_y_temp datos_y(i)];
        end
    end

    datos_x = datos_x_temp;
    datos_y = datos_y_temp;

    % tiro unos pocos puntos al final, que pertenecen al flanco que va del
    % trapecio a la mesa
    % Podría verlos al ppio también
    datos_x = datos_x(1:end-3);
    datos_y = datos_y(1:end-3);

    datos_x = datos_x(3:end);
    datos_y = datos_y(3:end);

    %margen = 50;
    margen = 0;
    
    % me armo 3 regiones de datos para ajustar
    % dejo un margen a cada lado de la esquina
    datos_x_1 = datos_x(1:indice_1 - margen);
    datos_y_1 = datos_y(1:indice_1 - margen);

    datos_x_2 = datos_x(indice_1 + margen:indice_2 - margen);
    datos_y_2 = datos_y(indice_1 + margen:indice_2 - margen);

    datos_x_3 = datos_x(indice_2 + margen:end);
    datos_y_3 = datos_y(indice_2 + margen:end);

    for j = 1:3

        [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
        [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);
        [pol_3, S_3] = polyfit(datos_x_3, datos_y_3, 1);

        [recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
        [recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);
        [recta_3, delta_3] = polyval(pol_3, datos_x_3, S_3);

        % hay problemas cuando hay ruido distinto de 0. Filtro apartamientos
        % del ajuste

        datos_x_1_filtrado = [];
        datos_y_1_filtrado = [];

        sigmas = 5;
        for i = 1:numel(datos_x_1)
            if (datos_y_1(i) > recta_1(i) - sigmas*delta_1(i)) && (datos_y_1(i) < recta_1(i) + sigmas*delta_1(i))
                datos_x_1_filtrado = [datos_x_1_filtrado datos_x_1(i)];
                datos_y_1_filtrado = [datos_y_1_filtrado datos_y_1(i)];
            end
        end

        datos_x_1 = datos_x_1_filtrado;
        datos_y_1 = datos_y_1_filtrado;

    end
    
    % ahora calculo la posición de las esquinas por interseccion
    a1 = pol_1(1);
    b1 = pol_1(2);

    a2 = pol_2(1);
    b2 = pol_2(2);

    a3 = pol_3(1);
    b3 = pol_3(2);

    x1 = (b2 - b1)/(a1 - a2);
    y1 = a1*(b2 - b1)/(a1 - a2) + b1;

    x2 = (b3 - b2)/(a2 - a3);
    y2 = a2*(b3 - b2)/(a2 - a3) + b2;

    x = [x1, x2];
    y = [y1, y2];

    set(0,'DefaultFigureVisible', 'off');
    
    close all
    h = figure(1);
    hold on
    plot(datos_x, datos_y, '.-b')
    plot(datos_x_1, datos_y_1, '.r')
    %plot(datos_x_1_filtrado, datos_y_1_filtrado, '.-r')
    plot(datos_x_2, datos_y_2, '.r')
    plot(datos_x_3, datos_y_3, '.r')
    plot(x(1), y(1), '*g')
    plot(x(2), y(2), '*g')
    plot([datos_x(indice_1) datos_x(indice_1)], [min(datos_y) max(datos_y)], '--k')
    plot([datos_x(indice_2) datos_x(indice_2)], [min(datos_y) max(datos_y)], '--k')

    
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'frame_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    % el valor de x es el 2do elemento de tag
    
    %path = 'C:\Users\60069978\Documents\MATLAB\scan\';
    p = strsplit(filename, '\');
    path = [p{1}, '\', p{2}, '\', p{3}, '\', p{4}, '\', p{5}, '\', p{6}, '\'];

    fig_name = ['plot_x_' tag{2} '_y_' tag{4} '_medicion_' tag{6}];
    saveas(h, [path fig_name], 'png');

    % ahora veo cuánto mide:
    [x_real, y_real] = convertir_a_unidades_reales(x, y);

    medida = norma(x_real, y_real);

end