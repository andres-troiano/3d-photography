function[x_filtrado, y_filtrado, recta_1, a1, b1] = filtro_banda(x, y, cant_sigmas)

    % esta función es como "filtro_apartamientos_recta", sólo que esa está
    % pensada para trabajar sobre 2 regiones, y ésta sólo una

    [pol_1, S_1] = polyfit(x, y, 1);

    [recta_1, delta_1] = polyval(pol_1, x, S_1);

    umbral_superior_1 = recta_1 + cant_sigmas*delta_1;
    umbral_inferior_1 = recta_1 - cant_sigmas*delta_1;
    indices_filtrados_1 = y < umbral_superior_1 & y > umbral_inferior_1;

    % región 1
    x_filtrado = x(indices_filtrados_1);
    y_filtrado = y(indices_filtrados_1);
    
    % vuelvo a calcular las rectas para poder devolverlas con el número
    % correcto de puntos después de haber tirado algunos en ppio
    
    [pol_1, S_1] = polyfit(x_filtrado, y_filtrado, 1);

    [recta_1, delta_1] = polyval(pol_1, x_filtrado, S_1);
    
    a1 = pol_1(1);
    b1 = pol_1(2);
    
end
