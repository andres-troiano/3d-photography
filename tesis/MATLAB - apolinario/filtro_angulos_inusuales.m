function[tag_x_array, tag_y_array, x_ccd, y_ccd, angulos, gamma, mediana, sigma] = filtro_angulos_inusuales(tag_x_array, tag_y_array, x_ccd, y_ccd, angulos, gamma, cant_sigmas)
    
%     filtro = true(size(angulos));
    
    mediana = median(angulos);
    sigma = std(angulos);
    
    umbral_superior = mediana + cant_sigmas*sigma;
    umbral_inferior = mediana - cant_sigmas*sigma;
    
    filtro = angulos < umbral_superior & angulos > umbral_inferior;

    tag_x_array = tag_x_array(filtro);
    tag_y_array = tag_y_array(filtro);
    x_ccd = x_ccd(filtro);
    y_ccd = y_ccd(filtro);
    angulos = angulos(filtro);
    gamma = gamma(filtro);

end