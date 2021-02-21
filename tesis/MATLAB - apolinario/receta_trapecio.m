function[datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_trapecio(datos_x, datos_y, camara)    

% Ojo, al final estoy armando datos_x, datos_y, pero no los devuelvo. Hacen
% falta o los elimino? 


%     camara vale '1' o '2'

    if camara == '1'
        
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        
%         [datos_x, datos_y] = tiro_mitad_datos(datos_x, datos_y, camara);

    % ahora itero ajustes + filtrado de outliers
%         cant_sigmas = 3;
    cant_sigmas = [3 2 3 3 3 3 3 3 3 3 3];
        
        for k = 1:8
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

    end

    %     receta camara 2
    %%%%%%%%%%%%%%%%%%%%%

    if camara == '2'
        
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);

        % tiro 3 datos de la derecha que me molestan para tirar la base
        datos_x = datos_x(1:end-3);
        datos_y = datos_y(1:end-3);
        
        % pruebo de tirar la base del trapecio acá
        [datos_x, datos_y] = tiro_base_trapecio(datos_x, datos_y, camara);

        cant_sigmas = [3 2 3 3 3 3 3 3 3 3 3];
        
        for k = 1:8
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

        % con esto me saco de encima la base del trapecio. Una vez que está
        % más o menos limpio, tiro todo lo que está a más de 150 del mínimo
        
        % esto está andando bien, el tema es que necesito devolverlo
        % partido en 2 regiones
        [datos_x, datos_y] = tiro_base_trapecio(datos_x, datos_y, camara);
        [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, 3);


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