function[datos_x_filtrado, datos_y_filtrado, mediana, sigma] = filtro_pendiente_grande(datos_x, datos_y, cant_sigmas)

    % esta función tira aquellos datos que tienen una pendiente mucho más
    % grande que la mediana

    delta_x = diff(datos_x);
    delta_y = diff(datos_y);

    pendiente = delta_y./delta_x;
    
    mediana = median(pendiente);
    sigma = std(pendiente);
    
    umbral = mediana + cant_sigmas*sigma;
    
    filtro = pendiente < umbral;
    
    % corrijo para que no me queden corridos los indices
    filtro = [true filtro];
    
    datos_x_filtrado = datos_x(filtro);
    datos_y_filtrado = datos_y(filtro);

end