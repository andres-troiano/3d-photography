function[datos_x_filtrado, datos_y_filtrado, mediana, sigma] = filtro_pendiente_nula(datos_x, datos_y, cant_sigmas)

    delta_x = diff(datos_x);
    delta_y = diff(datos_y);

    pendiente = delta_y./delta_x;
    
%     mediana = median(pendiente);
%     sigma = std(pendiente);
%     
%     umbral = mediana - cant_sigmas*sigma;
%     
%     filtro = pendiente > umbral;
%     % corrijo para que no me queden corridos los indices
%     filtro = [true filtro];
%     
%     datos_x_2_filtrado = datos_x_2(filtro);
%     datos_y_2_filtrado = datos_y_2(filtro);
%     
%     % filtré de un lado, y ahora compongo con el otro lado
%     datos_x_filtrado = [datos_x_1 datos_x_2_filtrado];
%     datos_y_filtrado = [datos_y_1 datos_y_2_filtrado];  

    close all
    figure
    hold on
    plot(datos_x(2:end), pendiente, '.')
    ylim([-1, 1])

end