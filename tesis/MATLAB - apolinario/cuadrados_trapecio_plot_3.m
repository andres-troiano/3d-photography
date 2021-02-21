function [x_real, y_modelo] = cuadrados_trapecio_plot_3(parametros, x_real)

    slope_1 = parametros(1);
    slope_2 = parametros(2);
    slope_3 = parametros(3);
    b_1 = parametros(4);
    indice_1 = parametros(5);
    indice_2 = parametros(6);
    
    N = numel(x_real);
    
    indice_1 = round(indice_1);
    indice_2 = round(indice_2);

    b_2 = x_real(indice_1)*(slope_1 - slope_2) + b_1;
    b_3 = x_real(indice_2)*(slope_2 - slope_3) + b_2;

    dominio_1 = x_real(1:indice_1);
    dominio_2 = x_real(indice_1 + 1:indice_2);
    dominio_3 = x_real(indice_2 + 1:N);

    recta_1 = slope_1*dominio_1 + b_1;
    recta_2 = slope_2*dominio_2 + b_2;
    recta_3 = slope_3*dominio_3 + b_3;

    y_modelo = [recta_1, recta_2, recta_3];
    
end