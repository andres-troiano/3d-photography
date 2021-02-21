function[a, b] = calculo_parametros_recta(x, y)
    
    % x,y son 2 vectores
    x_1 = x(1);
    x_2 = x(end);

    y_1 = y(1);
    y_2 = y(end);
    
    a = (y_2 - y_1)/(x_2 - x_1);
    b = y_1 - a*x_1;
    
end