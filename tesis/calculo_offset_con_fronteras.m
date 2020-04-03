function [offset_fronteras] = calculo_offset_con_fronteras(path_datos, path_calibracion)

    % hace falta tener las intersecciones ya calculadas

    load([path_datos 'intersections.mat']);
    load([path_calibracion 'calibration_con_fronteras.mat']);

    filename = {'camara_1.mat', 'camara_2.mat'};

    % armo una estructura que tiene los perfiles de ambas cámaras
    perfiles = {load(fullfile(path_datos, filename{1})), load(fullfile(path_datos, filename{2}))};

    % identifico los pares (x, y) para los cuales se encontró la misma esquina
    % en ambas cámaras
    x_comunes = intersect(perfiles{1}.X, perfiles{2}.X);
    y_comunes = intersect(perfiles{1}.Y, perfiles{2}.Y);

    esquinas = {nan(numel(x_comunes)*numel(y_comunes), 2) , nan(numel(x_comunes)*numel(y_comunes), 2)}; % {[x1, y1], [x2, y2]}

    k=0;
    for i = 1:numel(x_comunes)
        for j = 1:numel(y_comunes)
            k=k+1;

            % recorro las cámaras
            for q = 1:2
                % encuentro el índice que corresponde al (x, y) común que estoy
                % mirando ahora. Los índices van a ser diferentes para cada
                % cámara

                % par (x, y) en el que estoy parado
                x_pedido = x_comunes(i);
                y_pedido = y_comunes(j);

                ind_x = perfiles{q}.X == x_pedido;
                ind_y = perfiles{q}.Y == y_pedido;
                ind_comun = ind_x & ind_y;

                % el indice que busco
                n = find(ind_comun);

                % para este n guardo las coordenadas de la punta
                % podría graficar los perfiles junto con las puntas para
                % chequear que todo está bien, pero por ahora no lo incluyo

                % coordenadas en pixels de las puntas
                punta_px = C{q}(n, 1);
                punta_py = C{q}(n, 2);

                % va a haber casos en los que la punta no se encontró (vale
                % NaN), así que esos los salteo
                if isnan(punta_px) == 1
    %                 disp('### No se encontró la punta ###')
                    continue
                end

                if numel(punta_px) == 0
    %                 disp('### numel = 0 ###')
                    continue
                end

                % convierto a mm
                punta_mm_x = polyval4XY(px2mmPol{q}(1), punta_px, punta_py);
                punta_mm_y = polyval4XY(px2mmPol{q}(2), punta_px, punta_py);

                % guardo en la estructura
                esquinas{q}(k, :) = [punta_mm_x, punta_mm_y];

            end
        end
    end

    % calculo el error en cada punto
    error = esquinas{2} - esquinas{1}; % [error_x, error_y]

    % tiro los casos que dieron NaN
    ind1 = ~isnan(error(:, 1));
    error = error(ind1, :);

    % calculo el offset como el promedio de los errores
    offset_fronteras = [mean(error(:, 1)), mean(error(:, 2))];
    fprintf('Offset en X = %.3f\nOffset en Y = %1.3f\n', offset_fronteras(1), offset_fronteras(2));

    % exporto para futuro uso
    save(fullfile(path_datos, 'offset_fronteras'),'offset_fronteras');
    
end