function[x_real, y_real] = convertir_a_unidades_reales(pxq, pyq, lut)

    %lut = 'C:\Users\60069978\Documents\MATLAB\scan18\LUT.txt';
    % ahora hay que darle como argumento la LUT que quiero que use

    datos_y = importdata(lut, '\t', 1);
    datos_y = datos_y.data;

    x = datos_y(:, 1);
    y = datos_y(:, 2);
    px = datos_y(:, 3);
    py = datos_y(:, 4);

    % Interpolo Y en función de px, py
    %%%%%%%%%%%%%
    F_y = scatteredInterpolant(px, py, y, 'natural');

    y_real = F_y(pxq, pyq);

    % Interpolo X en función de px, py
    %%%%%%%%%%%%%
    F_x = scatteredInterpolant(px, py, x, 'natural');

    x_real = F_x(pxq, pyq);
    
end