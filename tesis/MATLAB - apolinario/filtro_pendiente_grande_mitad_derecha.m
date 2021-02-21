function[datos_x_filtrado, datos_y_filtrado, mediana, sigma] = filtro_pendiente_grande_mitad_derecha(datos_x, datos_y, cant_sigmas)

    % acá separo las regiones en mitades porque estimo que con eso me
    % bastará, sin necesidad de separar exactamente en la punta
    
%     x_mitad = datos_x(round(numel(datos_x)/2));
%     
%     indices_region_1 = datos_x > x_mitad;
%     
    
    %%%%%%%%%%%%%%%%%%%

% lo hago más pro, separando con fmin search

    [~, indice_min] = min(datos_y);
    x_min = datos_x(indice_min);

    X0 = x_min;

    f = @(x)ajuste_punta_1_param_2_camaras(x, datos_x, datos_y);
    [separador, ~] = fminsearch(f, X0);
    
    indices_region_1 = datos_x < separador;

%%%%%%%%%%%%%%%%%%%%%%%%

    datos_x_1 = datos_x(indices_region_1);
    datos_y_1 = datos_y(indices_region_1);
    
    datos_x_2 = datos_x(~indices_region_1);
    datos_y_2 = datos_y(~indices_region_1);


    % ojo!! la pendiente está calculada sólo para la parte derecha, aunque
    % la notación no lo dice
    delta_x = diff(datos_x_2);
    delta_y = diff(datos_y_2);

    pendiente = delta_y./delta_x;
    
    mediana = median(pendiente);
    sigma = std(pendiente);
    
    umbral = mediana + cant_sigmas*sigma;
    
    filtro = pendiente < umbral;
    % corrijo para que no me queden corridos los indices
    filtro = [true filtro];
    
    datos_x_2_filtrado = datos_x_2(filtro);
    datos_y_2_filtrado = datos_y_2(filtro);
    
    % filtré de un lado, y ahora compongo con el otro lado
    datos_x_filtrado = [datos_x_1 datos_x_2_filtrado];
    datos_y_filtrado = [datos_y_1 datos_y_2_filtrado];  
    
%     margen = 25;
% 
%     close all
%     figure
%     hold on
%     grid on
%     
% %     plot(datos_x, datos_y, '.b')
% %     plot(datos_x_filtrado, datos_y_filtrado, 'or')
% %     xlim([min(datos_x)-margen max(datos_x)+margen])
% %     ylim([min(datos_y)-margen max(datos_y)+margen])
% 
%     plot(datos_x_2(2:end), pendiente, '.-b')
% %     plot(datos_x_2_filtrado, pendiente(filtro), 'or')
% 
% %     plot(datos_x_2, datos_y_2, '.-b')
% %     plot(datos_x_2_filtrado, datos_y_2_filtrado, 'or')

    

end