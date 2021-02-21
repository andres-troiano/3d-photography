function[datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = receta_limpieza_datos_2(datos_x, datos_y, camara)    

%     camara vale '1' o '2'

    if camara == '1'

        [datos_x, datos_y] = filtro_basura_derecha_absoluto(datos_x, datos_y);

        % esto está para tratar un caso bastante drástico en el que se ve
        % la mesa con muchos puntos
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 2);
        
        for j = 1:2
            [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        end

        for j = 1
            [datos_y, datos_x] = filtro_saltos_grandes(datos_y, datos_x, 3);
            [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);
            [datos_x, datos_y, mediana, sigma] = filtro_pendiente_grande_mitad_derecha(datos_x, datos_y, 1);
            [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
            [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, 1, 3);
            [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, -1, 3);
        end

    % ahora itero ajustes + filtrado de outliers
        cant_sigmas = [3 3 3];
    %     
        for k = 1:2
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

        % hago una vuelta más de tirar basura
        [datos_x, datos_y] = filtro_basura_derecha_absoluto(datos_x, datos_y);

        cant_sigmas = [3 3 3];
    %     
        for k = 1:2
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end
    end

    %     receta camara 2
    %%%%%%%%%%%%%%%%%%%%%

    if camara == '2'

        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 2);
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);
        [datos_y, datos_x] = filtro_saltos_grandes(datos_y, datos_x, 3);
        [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, 1, 3);
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        [datos_y, datos_x] = filtro_saltos_grandes(datos_y, datos_x, 3);
        
        for k = 1:3
            [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        end
        
        [datos_x, datos_y] = filtro_basura_derecha_absoluto(datos_x, datos_y);
        
        %%%% agregado %%%%
        
        [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, 1, 2);
        
        %%%%%%%%%%%%%%%%%%
        
        % ahora itero ajustes + filtrado de outliers
        cant_sigmas = [3 3 3];
    %     
        for k = 1:3
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end
        
        [datos_x, datos_y] = filtro_basura_derecha_absoluto(datos_x, datos_y);
        
        for k = 1:3
            [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, -1, 3);
        end
        
        % ahora itero ajustes + filtrado de outliers
        cant_sigmas = [3 3 3];
    %     
        for k = 1:3
            [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas(k));
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end

    end
    
end