function[datos_x_parcial, datos_y_parcial] = tiro_mitad_datos(datos_x, datos_y, camara)

    mitad_px = datos_x(1) + (datos_x(end) - datos_x(1))/2;

%     if camara == '1'
        filtro = datos_x < mitad_px;
%     end

    % esto estaría mal xq estaba mirando la punta equivocada
    
%     if camara == '2'
%         filtro = datos_x > mitad_px;
%     end
    
    datos_x_parcial = datos_x(filtro);
    datos_y_parcial = datos_y(filtro);
    
end