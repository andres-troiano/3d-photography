function[datos_x_1, datos_x_2, datos_y_1, datos_y_2] = separo_en_2_regiones(datos_x, datos_y, separador)
    
    indices_region_1 = datos_x < separador;
    
    datos_x_1 = datos_x(indices_region_1);
    datos_y_1 = datos_y(indices_region_1);

    datos_x_2 = datos_x(~indices_region_1);
    datos_y_2 = datos_y(~indices_region_1);
    
end