%function [y, error_code] = trapecio(parametros, x)
function y = trapecio(parametros, x)

    slope_1 = parametros(1);
    slope_2 = parametros(2);
    slope_3 = parametros(3);
    b_1 = parametros(4);
%     b_2 = parametros(5);
%     b_3 = parametros(6);
%     indice_1 = parametros(7);
%     indice_2 = parametros(8);
    indice_1 = parametros(5);
    indice_2 = parametros(6);
    
    b_2 = indice_1*(slope_1 - slope_2) + b_1;
    b_3 = indice_2*(slope_2 - slope_3) + b_2;
    
    N = numel(x);
%     error_code = 0;
% 
%     if indice_1 > N
%         error_code = -1;
%     end
%     
%     if indice_2 > N
%         error_code = -1;
%     end
%     
%     if indice_1 > indice_2
%         error_code = -1;
%     end
    
    indice_1 = indice_1 - x(1);
    indice_2 = indice_2 - x(1);

    dominio_1 = x(1:indice_1);
    dominio_2 = x(indice_1 + 1:indice_2);
    dominio_3 = x(indice_2 + 1:N);

%     dominio_1 = x(1) : x(1) + indice_1;
%     dominio_2 = x(1) + indice_1 + 1 : x(1) + indice_2;
%     dominio_3 = x(1) + indice_2 + 1 : x(1) + N;
%     
%     size(dominio_1) + size(dominio_2) + size(dominio_3)
%     N

    recta_1 = slope_1*dominio_1 + b_1;
    recta_2 = slope_2*dominio_2 + b_2;
    recta_3 = slope_3*dominio_3 + b_3;

    y = [recta_1, recta_2, recta_3];
    
end