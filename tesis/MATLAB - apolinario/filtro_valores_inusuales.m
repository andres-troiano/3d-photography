function[u, v, mediana, sigma] = filtro_valores_inusuales(x, y, condicion, cant_sigmas)
    
    % acá sí me interesa tirar valores por encima y por debajo de un umbral

    filtro = true(size(x));
    
    mediana = median(x);
    sigma = std(x);
    
    if condicion == -1
        umbral = mediana + cant_sigmas*sigma;
        filtro = x < umbral;
    end
    
    if condicion == 1
        umbral = mediana - cant_sigmas*sigma;
        filtro = x > umbral;
    end

    u = x(filtro);
    v = y(filtro);

end