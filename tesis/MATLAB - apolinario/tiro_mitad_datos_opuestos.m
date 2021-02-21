function[datos_x_parcial, datos_y_parcial] = tiro_mitad_datos_opuestos(datos_x, datos_y, camara)

    % esta es una variante de "tiro mitad datos" para el caso en que una
    % cámara busca la punta izq y la otra la derecha

    mitad_px = datos_x(1) + (datos_x(end) - datos_x(1))/2;

    if camara == '1'
        filtro = datos_x < mitad_px;
    end
    
    if camara == '2'
        filtro = datos_x > mitad_px;
    end
    
    datos_x_parcial = datos_x(filtro);
    datos_y_parcial = datos_y(filtro);
    
end