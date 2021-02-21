function[datos_x, datos_y] = filtro_datos_nulos(frame)
    perfil = median(frame);
    perfil = double(perfil)/2^4;
    
    perfil_x = 1:1:numel(perfil);
    
    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);
end