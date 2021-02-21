function[datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_trapecio_idea_2(datos_x, datos_y, camara)    

    if camara == '1'

        [datos_x, datos_y] = filtro_basura_derecha_absoluto(datos_x, datos_y);

        cant_sigmas = [3 2 3 3 3 3 3 3 3 3 3];

        for k = 1:3
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

    end

    %     receta camara 2
    %%%%%%%%%%%%%%%%%%%%%

    if camara == '2'
        
        % tiro basuras izquierdas a más de 25 pixels
%         [datos_x, datos_y] = filtro_basura_izquierda_absoluto(datos_x, datos_y);
        
        cant_sigmas = [3 2 3 3 3 3 3 3 3 3 3];
        
        for k = 1:3
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

    end
    
    
%     
%     close all
%     figure
%     hold on
% 
%     plot(datos_x, datos_y, '.-')
%     plot(datos_x_1, datos_y_1, '.g')
%     plot(datos_x_2, datos_y_2, '.y')
    
end