function[datos_x_1_filtrado, datos_x_2_filtrado, datos_y_1_filtrado, datos_y_2_filtrado, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = filtro_apartamientos_recta(datos_x, datos_y, cant_sigmas)
    
    [~, indice_min] = min(datos_y);
    x_min = datos_x(indice_min);

    X0 = x_min;

    f = @(x)ajuste_punta_1_param_2_camaras(x, datos_x, datos_y);
    [x, ~] = fminsearch(f, X0);

    % era un valor de x, no un índice
    separador_optimo = x;

    % ahora veo qué datos están dentro de sigma
    % para definir el umbral tengo que ajustar linealmente

    [datos_x_1, datos_x_2, datos_y_1, datos_y_2] = separo_en_2_regiones(datos_x, datos_y, separador_optimo);

    [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
    [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);

    [recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
    [recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);

    umbral_superior_1 = recta_1 + cant_sigmas*delta_1;
    umbral_inferior_1 = recta_1 - cant_sigmas*delta_1;
    indices_filtrados_1 = datos_y_1 < umbral_superior_1 & datos_y_1 > umbral_inferior_1;

    umbral_superior_2 = recta_2 + cant_sigmas*delta_2;
    umbral_inferior_2 = recta_2 - cant_sigmas*delta_2;
    indices_filtrados_2 = datos_y_2 < umbral_superior_2 & datos_y_2 > umbral_inferior_2;

    % región 1
    datos_x_1_filtrado = datos_x_1(indices_filtrados_1);
    datos_y_1_filtrado = datos_y_1(indices_filtrados_1);
    
    % región 2
    datos_x_2_filtrado = datos_x_2(indices_filtrados_2);
    datos_y_2_filtrado = datos_y_2(indices_filtrados_2);
    
    % vuelvo a calcular las rectas para poder devolverlas con el número
    % correcto de puntos después de haber tirado algunos en ppio
    
    [pol_1, S_1] = polyfit(datos_x_1_filtrado, datos_y_1_filtrado, 1);
    [pol_2, S_2] = polyfit(datos_x_2_filtrado, datos_y_2_filtrado, 1);

    [recta_1, delta_1] = polyval(pol_1, datos_x_1_filtrado, S_1);
    [recta_2, delta_2] = polyval(pol_2, datos_x_2_filtrado, S_2);
    
    a1 = pol_1(1);
    b1 = pol_1(2);

    a2 = pol_2(1);
    b2 = pol_2(2);
    
    % miro el incremento más grande observado en los datos originales y
    % en los filtrados, y me fijo que en los filtrados nunca el paso
    % sea mayor de lo que era en los datos originales, porque eso
    % significa que se creó un hueco en el medio

%     paso_max_x_1 = max(diff(datos_x_1));
%     paso_max_x_1_filtrado = max(diff(datos_x_1_filtrado));
% 
%     % si se generó un hueco, se resetean los datos
%     if paso_max_x_1_filtrado > paso_max_x_1
%     %             disp('True 1')
%         indices_filtrados_1 = true(size(datos_x_1));
%     end
% 
%     paso_max_x_2 = max(diff(datos_x_2));
%     paso_max_x_2_filtrado = max(diff(datos_x_2_filtrado));
% 
%     % idem
%     if paso_max_x_2_filtrado > paso_max_x_2
%     %             disp('True 2')
%         indices_filtrados_2 = true(size(datos_x_2));
%     end
    
end
