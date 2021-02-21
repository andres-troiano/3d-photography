function[a1, b1, a2, b2] = coords_punta_2_camaras(separador, filename)
    
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

    % me armo 2 regiones de datos para ajustar
    datos_x_1 = [];
    datos_y_1 = [];
    
    datos_x_2 = [];
    datos_y_2 = [];
    
    for i = 1:numel(datos_x)
        
        if datos_x(i) < separador
            datos_x_1 = [datos_x_1 datos_x(i)];
            datos_y_1 = [datos_y_1 datos_y(i)];
        end
        
        if datos_x(i) >= separador
            datos_x_2 = [datos_x_2 datos_x(i)];
            datos_y_2 = [datos_y_2 datos_y(i)];
        end
        
    end
    
    % quiero que devuelva los parámetros de las 2 rectas a partir de el
    % separador óptimo dado por la minimización

    [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
    [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);
    
    a1 = pol_1(1);
    b1 = pol_1(2);

    a2 = pol_2(1);
    b2 = pol_2(2);
    
end