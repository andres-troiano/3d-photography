function[N] = norma(x, y)

    % x son las coordenadas x (pueden ser más de 2)
    % y análogo

    x_0 = x(1);
    y_0 = y(1);
    x_1 = x(end);
    y_1 = y(end);

    N = sqrt((x_1 - x_0)^2 + (y_1 - y_0)^2);

end