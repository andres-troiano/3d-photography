function[x_real, y_real] = interpolacion_lut_funcion(lut, x_ccd, y_ccd)

    datos_y = importdata(lut, '\t', 1);
    datos_y = datos_y.data;

    x = datos_y(:, 1);
    y = datos_y(:, 2);
    px = datos_y(:, 3);
    py = datos_y(:, 4);

    % Interpolo Y en función de px, py
    %%%%%%%%%%%%%
    F_y = scatteredInterpolant(px, py, y, 'natural');

    % evalúo el interpolador en mis datos
    pxq = x_ccd;
    pyq = y_ccd;

    y_real = F_y(pxq, pyq);

    % Interpolo X en función de px, py
    %%%%%%%%%%%%%
    F_x = scatteredInterpolant(px, py, x, 'natural');

    x_real = F_x(pxq, pyq);
    
end