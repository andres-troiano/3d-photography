function[x, y] = esquinas_trapecio(a1, a2, a3, b1, indice_1, indice_2)

    % esta función devuelve las esquinas del trapecio P1 = (x1, y1)
    % P2 = (x2, y2)
    
    % usar estos indices no me limita la resolución?
    % acá no necesito que los indices sean enteros, puedo usar los que me
    % devuelve la optimización

    b2 = indice_1*(a1 - a2) + b1;
    b3 = indice_2*(a2 - a3) + b2;
    
    x1 = (b2 - b1)/(a1 - a2);
    y1 = a1*(b2 - b1)/(a1 - a2) + b1;
    
    x2 = (b3 - b2)/(a2 - a3);
    y2 = a2*(b3 - b2)/(a2 - a3) + b2;
    
    x = [x1, x2];
    y = [y1, y2];

end