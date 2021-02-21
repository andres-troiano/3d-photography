function[datos_x_filtrado, datos_y_filtrado, mediana, sigma] = filtro_pendiente_grande_mitad_izquierda(datos_x, datos_y, cant_sigmas)

    % acá separo las regiones en mitades porque estimo que con eso me
    % bastará, sin necesidad de separar exactamente en la punta
    
    x_mitad = datos_x(round(numel(datos_x)/2));
    
    indices_region_1 = datos_x < x_mitad;
    
    datos_x_1 = datos_x(indices_region_1);
    datos_y_1 = datos_y(indices_region_1);
    
    datos_x_2 = datos_x(~indices_region_1);
    datos_y_2 = datos_y(~indices_region_1);

    delta_x = diff(datos_x_1);
    delta_y = diff(datos_y_1);

    pendiente = delta_y./delta_x;
    
    mediana = median(pendiente);
    sigma = std(pendiente);
    
    umbral = mediana - cant_sigmas*sigma;
    
    filtro = pendiente > umbral;
    % corrijo para que no me queden corridos los indices
    filtro = [true filtro];
    
    datos_x_1_filtrado = datos_x_1(filtro);
    datos_y_1_filtrado = datos_y_1(filtro);
    
    % filtré de un lado, y ahora compongo con el otro lado
    datos_x_filtrado = [datos_x_1_filtrado datos_x_2];
    datos_y_filtrado = [datos_y_1_filtrado datos_y_2];
    
%     close all
%     figure
%     plot(datos_x_1(2:end), pendiente, '.b')

%     close all
%     plot(filtro, '.')

%     close all
%     hold on
%     plot(datos_x_1, datos_y_1, '.b')
%     plot(datos_x_1(filtro), datos_y_1(filtro), '.r')
    

end