function[suma] = ajuste_punta_1_param(indice, frame)

%     tag = strsplit(filename, '.');
%     tag = tag{1};
%     tag = strsplit(tag, 'frame_');
%     tag = tag{2};

     indice = round(indice);
% 
%     if indice<0
%         indice = -indice;
%     end
%    
%     if indice == 0
%         indice = 1;
%     end

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

    datos_x_temp = [];
    datos_y_temp = [];

    % tiro unos pocos puntos al final, que pertenecen al flanco que va del
    % trapecio a la mesa
    % Podría verlos al ppio también
    datos_x = datos_x(1:end-3);
    datos_y = datos_y(1:end-3);

    datos_x = datos_x(3:end);
    datos_y = datos_y(3:end);
    
    % antes de separar en regiones, trato de tirar el ruido del reflejo
    % miro la mediana a ver si está sobre la punta, así tiro los que están
    % muy por debajo
    mediana_y = median(datos_y);
    std_y = std(datos_y);
    
    datos_x_temp = [];
    datos_y_temp = [];
    
    for i = 1:numel(datos_x)
        if datos_y(i) > mediana_y - 2*std_y
            datos_x_temp = [datos_x_temp datos_x(i)];
            datos_y_temp = [datos_y_temp datos_y(i)];
        end
    end
    
    datos_x = datos_x_temp;
    datos_y = datos_y_temp;

    % me armo 2 regiones de datos para ajustar
    % dejo un margen a cada lado de la esquina
    
%     if indice > numel(datos_x)
%         indice = numel(datos_x);
%     end
    
    try
        datos_x_1 = datos_x(1:indice);
    catch E
        indice
    end
    datos_y_1 = datos_y(1:indice);
    
    try
        datos_x_2 = datos_x(indice:end);
    catch E
        indice
    end
    datos_y_2 = datos_y(indice:end);

    for j = 1:3

        [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
        [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);

        [recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
        [recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);

        % hay problemas cuando hay ruido distinto de 0. Filtro apartamientos
        % del ajuste

        sigmas = 3;

        % en la region 1:
        datos_x_1_filtrado = [];
        datos_y_1_filtrado = [];

        for i = 1:numel(datos_x_1)
            if (datos_y_1(i) > recta_1(i) - sigmas*delta_1(i)) && (datos_y_1(i) < recta_1(i) + sigmas*delta_1(i))
                datos_x_1_filtrado = [datos_x_1_filtrado datos_x_1(i)];
                datos_y_1_filtrado = [datos_y_1_filtrado datos_y_1(i)];
            end
        end

        datos_x_1 = datos_x_1_filtrado;
        datos_y_1 = datos_y_1_filtrado;

        % en la region 2:
        datos_x_2_filtrado = [];
        datos_y_2_filtrado = [];

        for i = 1:numel(datos_x_2)
            if (datos_y_2(i) > recta_2(i) - sigmas*delta_2(i)) && (datos_y_2(i) < recta_2(i) + sigmas*delta_2(i))
                datos_x_2_filtrado = [datos_x_2_filtrado datos_x_2(i)];
                datos_y_2_filtrado = [datos_y_2_filtrado datos_y_2(i)];
            end
        end

        datos_x_2 = datos_x_2_filtrado;
        datos_y_2 = datos_y_2_filtrado;

    end

    %calculo la diferencia, para minimizar
    suma = 0;

    for i = 1:numel(datos_x_1)
        dif = (datos_y_1(i) - recta_1(i))^2;
        suma = suma + dif;
    end

    for i = 1:numel(datos_x_2)
        dif = (datos_y_2(i) - recta_2(i))^2;
        suma = suma + dif;
    end
    
end