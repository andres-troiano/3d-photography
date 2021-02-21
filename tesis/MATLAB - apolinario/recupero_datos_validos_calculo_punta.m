function[x_definitivo_1, y_definitivo_1, x_definitivo_2, y_definitivo_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(perfil_x, perfil_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2)
    
    N1 = numel(datos_x_1);
    N2 = numel(datos_x_2);

    % acá me cubro de que un lado haya quedado vacío
    if N1 > 0 && N2 > 0

        % antes de descartar tomo todos los datos válidos
        datos_total_x_1 = perfil_x(perfil_x < punta_px);
        datos_total_y_1 = perfil_y(perfil_x < punta_px);

        datos_total_x_2 = perfil_x(perfil_x > punta_px);
        datos_total_y_2 = perfil_y(perfil_x > punta_px);

        % ahora tiro los que se apartan de la banda dada por el ajuste final, y lo
        % que queda lo ajusto y redefino la punta. Y a partir de ese resultado
        % decido lo que descarto

        % calculo la banda a partir de S_1, S_2 y los parámetros de los polinomios:

        % calculo los parámetros de las 6 rectas, para definir las 2 bandas
        % ya tengo a,b de las 2 rectas, me faltan de las deltas
        cant_sigmas = 12;

        [a_sup_1, b_sup_1] = calculo_parametros_recta(datos_x_1, recta_1 + cant_sigmas*delta_1);
        [a_inf_1, b_inf_1] = calculo_parametros_recta(datos_x_1, recta_1 - cant_sigmas*delta_1);

        [a_sup_2, b_sup_2] = calculo_parametros_recta(datos_x_2, recta_2 + cant_sigmas*delta_2);
        [a_inf_2, b_inf_2] = calculo_parametros_recta(datos_x_2, recta_2 - cant_sigmas*delta_2);

        % []

        % ahora que tengo los parámetros defino las bandas
        % el orden de los parámetros para polyval es de mayor orden a menor
        % es decir a,b

        x_recta_izq = datos_total_x_1;

    %     y_recta_izq = polyval([a1, b1], x_recta_izq);
        y_sup_izq = polyval([a_sup_1, b_sup_1], x_recta_izq);
        y_inf_izq = polyval([a_inf_1, b_inf_1], x_recta_izq);

        % ahora selecciono los datos que cumplen la condición
        filtro = datos_total_y_1 < y_sup_izq & datos_total_y_1 > y_inf_izq;

        x_definitivo_1 = datos_total_x_1(filtro);
        y_definitivo_1 = datos_total_y_1(filtro);

        for j = 1:3
            [x_definitivo_1, y_definitivo_1, recta_definitivo_1, a1_definitivo, b1_definitivo] = filtro_banda(x_definitivo_1, y_definitivo_1, 2);
        end



        % idem lado derecho
        x_recta_der = datos_total_x_2;

        y_sup_der = polyval([a_sup_2, b_sup_2], x_recta_der);
        y_inf_der = polyval([a_inf_2, b_inf_2], x_recta_der);

        % ahora selecciono los datos que cumplen la condición
        filtro = datos_total_y_2 < y_sup_der & datos_total_y_2 > y_inf_der;

        x_definitivo_2 = datos_total_x_2(filtro);
        y_definitivo_2 = datos_total_y_2(filtro);



        % este sería un buen lugar para descartar los recuperados que no me
        % interesan? (ruido que cumple la condición)
        [x_definitivo_1, y_definitivo_1] = tiro_datos_nulos_perfil(x_definitivo_1, y_definitivo_1);
        [x_definitivo_2, y_definitivo_2] = tiro_datos_nulos_perfil(x_definitivo_2, y_definitivo_2);
        
        % los próximos 2 renglones son una prueba
        [x_definitivo_1, y_definitivo_1] = filtro_ruido_basico(x_definitivo_1, y_definitivo_1);
        [x_definitivo_2, y_definitivo_2] = filtro_ruido_basico(x_definitivo_2, y_definitivo_2);
        
        % una vez que tengo los datos completos y sin ruido, calculo las
        % rectas
        for j = 1:3
            [x_definitivo_2, y_definitivo_2, recta_definitivo_2, a2_definitivo, b2_definitivo] = filtro_banda(x_definitivo_2, y_definitivo_2, 2);
        end

        % calculo la punta definitiva
        a1 = a1_definitivo;
        b1 = b1_definitivo;

        a2 = a2_definitivo;
        b2 = b2_definitivo;

%         punta_definitiva_px = (b2 - b1)/(a1 - a2);
%         punta_definitiva_py = a1*(b2 - b1)/(a1 - a2) + b1;

    else
        x_definitivo_1 = datos_x_1;
        y_definitivo_1 = datos_y_1;

        x_definitivo_2 = datos_x_2;
        y_definitivo_2 = datos_y_2;

%         punta_definitiva_px = punta_px;
%         punta_definitiva_py = punta_py;

%         close all
%         figure
%         hold on
%         grid on
% 
% %         plot(x, y, '.-b')
%         plot(datos_total_x_1, datos_total_y_1, '.r')
%         plot(datos_total_x_2, datos_total_y_2, '.r')
%         plot(x_definitivo_1, y_definitivo_1, '.g')
%         plot(x_definitivo_2, y_definitivo_2, '.y')

    end

end