function[datos_x, datos_y] = tiro_base_trapecio(datos_x, datos_y, camara)
    
    if camara == '2'
        min_y = min(datos_y);
        distancia = 150;
        
        filtro = datos_y < min_y + distancia;

        datos_x = datos_x(filtro);
        datos_y = datos_y(filtro);
    end

end

% close all
% figure
% 
% plot(datos_x, filtro, '.-')