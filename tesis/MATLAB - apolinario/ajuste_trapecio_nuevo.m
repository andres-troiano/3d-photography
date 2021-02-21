%function[medida, x, y, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2, datos_x_3, datos_y_3, recta_3, perfil] = ajuste_trapecio_funcion(filename)
function[suma] = ajuste_trapecio_nuevo(x, frame)

    %frame = imread('C:\Users\60069978\Documents\MATLAB\scan\frame_grados_01_001.png');
    %frame = imread(filename);
    
    separador_1 = x(1);
    separador_2 = x(2);
    
    % con esto pretendo solucionar el warning
%     indice_1 = round(indice_1);
%     indice_2 = round(indice_2);

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

    %%%%%%%%%%%
    % candidatos a indices de las esquinas
%     indice_1 = 350;
%     indice_2 = 975;

    %margen = 50;
    margen = 0;

    % me armo 3 regiones de datos para ajustar
    % dejo un margen a cada lado de la esquina
    
    % ahora esto lo hago usando los parametros del ajuste como separadores,
    % no como indices
    datos_x_1 = [];
    datos_y_1 = [];
    
    datos_x_2 = [];
    datos_y_2 = [];
    
    datos_x_3 = [];
    datos_y_3 = [];
    
    for i = 1:numel(datos_x)
        
        if datos_x(i) < separador_1
            datos_x_1 = [datos_x_1 datos_x(i)];
            datos_y_1 = [datos_y_1 datos_y(i)];
        end
        
        if datos_x(i) >= separador_1 && datos_x(i) < separador_2
            datos_x_2 = [datos_x_2 datos_x(i)];
            datos_y_2 = [datos_y_2 datos_y(i)];
        end
        
        if datos_x(i) >= separador_2
            datos_x_3 = [datos_x_3 datos_x(i)];
            datos_y_3 = [datos_y_3 datos_y(i)];
        end
        
    end
        
%     datos_x_1 = datos_x(1:indice_1 - margen);
%     datos_y_1 = datos_y(1:indice_1 - margen);
% 
%     datos_x_2 = datos_x(indice_1 + margen:indice_2 - margen);
%     datos_y_2 = datos_y(indice_1 + margen:indice_2 - margen);
% 
%     datos_x_3 = datos_x(indice_2 + margen:end);
%     datos_y_3 = datos_y(indice_2 + margen:end);

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

    % calculo la diferencia, para minimizar
    suma = 0;
    
    for i = 1:numel(datos_x_1)
        dif = (datos_y_1(i) - recta_1(i))^2;
        suma = suma + dif;
    end
    
    for i = 1:numel(datos_x_2)
        dif = (datos_y_2(i) - recta_2(i))^2;
        suma = suma + dif;
    end
    
    for i = 1:numel(datos_x_3)
        dif = (datos_y_3(i) - recta_3(i))^2;
        suma = suma + dif;
    end

end