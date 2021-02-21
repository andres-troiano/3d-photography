function[x, y] = filtro_ruido_basico(x, y)

    [y, x, mediana, sigma] = filtro_valores_inusuales(y, x, -1, 3);
    [y, x, mediana, sigma] = filtro_valores_inusuales(y, x, 1, 3);
    
    [x, y, mediana, sigma] = filtro_valores_inusuales(x, y, -1, 3);
    [x, y, mediana, sigma] = filtro_valores_inusuales(x, y, 1, 3);
    
end