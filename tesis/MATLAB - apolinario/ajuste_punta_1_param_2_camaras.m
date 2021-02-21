function[cuadrado_residuos] = ajuste_punta_1_param_2_camaras(separador, datos_x, datos_y)

    % me armo 2 regiones de datos para ajustar

    indices_region_1 = datos_x < separador;
    
    datos_x_1 = datos_x(indices_region_1);
    datos_y_1 = datos_y(indices_region_1);
    
    datos_x_2 = datos_x(~indices_region_1);
    datos_y_2 = datos_y(~indices_region_1);
    
    [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
    [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);

    [recta_1, ~] = polyval(pol_1, datos_x_1, S_1);
    [recta_2, ~] = polyval(pol_2, datos_x_2, S_2);

    residuos_1 = S_1.normr;
    residuos_2 = S_2.normr;
    
    cuadrado_residuos = residuos_1^2 + residuos_2^2;
   
end