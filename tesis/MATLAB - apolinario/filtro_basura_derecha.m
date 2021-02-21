function[u, v] = filtro_basura_derecha(datos_x, datos_y, cant_sigmas)

    % tiro el cacho de la derecha
    paso_x = diff(datos_x);
    mediana_paso_x = median(paso_x);
    sigma_paso_x = std(paso_x);

    umbral = mediana_paso_x + cant_sigmas*sigma_paso_x;
    filtro = paso_x > umbral;

    x_corte = datos_x([false filtro]);
    paso_corte = paso_x(filtro);
    
    filtro_2 = true(numel(datos_x), 1);

    if numel(x_corte) >= 1
%         disp('ERROR')
        
        % si hay más de un punto que se pasa, me quedo con el 1ro
        x_corte = x_corte(1);
        
        filtro_2 = datos_x < x_corte;
    end
    
    u = datos_x(filtro_2);
    v = datos_y(filtro_2);
    
    if numel(u) < 30
        u = datos_x;
        v = datos_y;
    end
%     
%     close all
%     figure
%     hold on
%     
%     plot(datos_x, datos_y, '.b')
% %     plot(u, v, 'or')
%     
%     plot(datos_x(2:end), paso_x, '.-')

end