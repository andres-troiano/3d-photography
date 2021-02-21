% Ojo! esta función, a diferencia de deteccion_punta_funcion, además de que
% tiene frames y no filenames como input, devuelve las coord de la punta en
% el sistema del mundo real, ie ya interpoladas

% Tiene los argumentos x,y para guardar el plot con la etiqueta del punto
% del espacio, para debuguear

function [x_real, y_real] = deteccion_punta_frame(frame, x, y)

    perfil = median(frame);

    % corrijo por el subpixel resolution
    perfil = double(perfil)/2^4;

    % primero tengo que identificar la region de interes
    % solo necesito encontrar los indices
    indice_1 = find(perfil, 1, 'first');

    % chequeo que el indice 1 sea correcto, y no que haya agarrado un punto
    % intermedio sobre el flanco ascendente.

    % Esto en ppio no es muy robusto porque podría no haber simplemente un
    % flanco ascendente, sino ruido
    % Además necesitaria que esto itere todas las veces que sea necesario. Por
    % ahora itero 4 veces
    
    for k = 1:4
        if perfil(indice_1 + 1) > perfil(indice_1)
            indice_1 = indice_1 + 1;
        end
    end

    indice_3 = find(perfil, 1, 'last');

    % Me creo un par de vectores donde guardo las coordenadas de la punta
    punta_x = [];
    punta_y = [];

    % yo quiero tirar los ceros que están entre indice 1 e indice 3
    for i = indice_1:indice_3
        if perfil(i) ~= 0
            punta_y = [punta_y perfil(i)];
            punta_x = [punta_x i];
        end
    end

    % como primer candidato a índice de la punta, propongo el punto intermedio
    % entre indice 1 e indice 3
    % Tiene que ser entero
    indice_2 = round((indice_3 - indice_1)/2);

    % Con frame 2 encuentro 2 mínimos con el mismo valor, muy cerquita uno del
    % otro. Para casos así propongo usar el primero para ajustar la
    % decreciente, y el último para la creciente.
    % Podrían presentarse casos más complicados.

    % ajusto las dos caras de la punta

    [p_decreciente, S_decreciente] = polyfit(punta_x(1:indice_2(1)), punta_y(1:indice_2(1)), 1);
    [recta_decreciente, delta_decreciente] = polyval(p_decreciente, punta_x, S_decreciente);

    [p_creciente, S_creciente] = polyfit(punta_x(indice_2(end):end), punta_y(indice_2(end):end), 1);
    [recta_creciente, delta_creciente] = polyval(p_creciente, punta_x, S_creciente);
    
    % Descarto puntos que caigan afuera de la banda de error.
    % Uso 3 sigmas como umbral (en verdad no sé si son sigmas, porque no sé
    % cómo las calculan)
    % Itero el proceso

    % para esto necesito tener discriminadas las 2 regiones por pendiente

    % Hago la limpieza creando vectores nuevos, para evitar que al tirar cosas 
    % el indice se pase del mínimo y empiece a evaluar cosas de la otra cara
    
    for k = 1:3
        
        punta_x_temp = [];
        punta_y_temp = [];

        % Yo creo que para poder iterar esto, al final del paso necesito
        % asignar los valores temporales a x punta, y punta, y volver a vaciar
        % los temporales. Y seguir trabajando con las no temporales.

        for i = 1:indice_2(1)
            % si el punto está adentro de la banda, lo guardo en temp
            % Obs.: para ver si estoy adentro, necesito cumplir ambas condiciones.
            % Para ver si estaba afuera, me faltaba no cumplir con una

            if (punta_y(i) > recta_decreciente(i) - 3*delta_decreciente(i)) && (punta_y(i) < recta_decreciente(i) + 3*delta_decreciente(i))
                punta_x_temp = [punta_x_temp punta_x(i)];
                punta_y_temp = [punta_y_temp punta_y(i)];
            end
        end

        for i = indice_2(end):numel(punta_x)
            if (punta_y(i) > recta_creciente(i) - 3*delta_creciente(i)) && (punta_y(i) < recta_creciente(i) + 3*delta_creciente(i))
                punta_x_temp = [punta_x_temp punta_x(i)];
                punta_y_temp = [punta_y_temp punta_y(i)];
            end
        end

        % recalculo el mínimo, sin los puntos no deseados
        quiebre_y = min(punta_y_temp); 
        indice_2 = find(punta_y_temp == quiebre_y);

        % y vuelvo a ajustar
        [p_decreciente, S_decreciente] = polyfit(punta_x_temp(1:indice_2), punta_y_temp(1:indice_2), 1);
        [recta_decreciente, delta_decreciente] = polyval(p_decreciente, punta_x_temp, S_decreciente);

        [p_creciente, S_creciente] = polyfit(punta_x_temp(indice_2:end), punta_y_temp(indice_2:end), 1);
        [recta_creciente, delta_creciente] = polyval(p_creciente, punta_x_temp, S_creciente);

        punta_x = punta_x_temp;
        punta_y = punta_y_temp;
        
    end

    a1 = p_decreciente(1);
    b1 = p_decreciente(2);
    a2 = p_creciente(1);
    b2 = p_creciente(2);

    x_0 = (b2 - b1)/(a1 - a2);
    y_0 = a1*x_0 + b1;
    
    set(gcf, 'Visible', 'off');

    close all
    h = figure(1);
    hold on
    %plot(perfil, '.-b')
    plot(punta_x_temp, punta_y_temp, '.-b')
    
    %plot(punta_x_temp, [recta_decreciente; recta_decreciente + delta_decreciente; recta_decreciente - delta_decreciente], 'k--')
    %plot(punta_x_temp, [recta_creciente; recta_creciente + delta_creciente; recta_creciente - delta_creciente], 'k--')
    plot(x_0, y_0, '*g')
%     xmin = indice_1 - 50;
%     xmax = indice_3 + 50;
%     xlim([xmin xmax]);
%     ylim([0 1100]);
    
    saveas(h, [path 'perfil_' x '_y_' y], 'png');
    
    [x_real, y_real] = convertir_a_unidades_reales(x_0, y_0);
    
end