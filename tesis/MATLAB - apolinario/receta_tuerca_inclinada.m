function[datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_tuerca_inclinada(datos_x, datos_y, camara)    
% 
%     camara vale '1' o '2'

    if camara == '1'
        
%         [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        
%         [datos_x, datos_y] = tiro_mitad_datos(datos_x, datos_y, camara);

    % ahora itero ajustes + filtrado de outliers
        cant_sigmas = [3 3 3];
    %     
        for k = 1:2
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

    end

    %     receta camara 2
    %%%%%%%%%%%%%%%%%%%%%

    if camara == '2'
        
%         [datos_x, datos_y] = filtro_basura_derecha_absoluto(datos_x, datos_y);
%         [datos_y, datos_x] = filtro_saltos_grandes(datos_y, datos_x, 3);
    
        % para comparar distintos laseres misma camara
%         datos_x = datos_x(3:end);
%         datos_y = datos_y(3:end);
%         
%         % ahora itero ajustes + filtrado de outliers

        cant_sigmas = [3 3 3 3 3 3 3];
        for k = 1:2
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

    end
    
%     set(0,'DefaultFigureVisible', 'on');
%     
%     close all
%     figure(1)
%     hold on
%     grid on
%     
%     plot(datos_x, datos_y, '.-b')
%     plot(datos_x_1, datos_y_1, '.g')
%     plot(datos_x_2, datos_y_2, '.y')
    
end