function[x, y] = tiro_datos_nulos_perfil(x, y)
    
    % esta función es similar a "filtro_datos_nulos", sólo que esa es para
    % frames, y esta descarta puntos de un perfil
    
    filtro = y ~= 0;
    x = x(filtro);
    y = y(filtro);
    
end