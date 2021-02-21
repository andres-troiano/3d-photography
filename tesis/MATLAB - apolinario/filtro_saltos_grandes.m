function[u, v] = filtro_saltos_grandes(x, y, cant_sigmas)

    % esta función tira los datos que presentan saltos muy grandes. Se
    % puede especificar si uno quiere hacer el filtrado en "x" o en "y", y
    % si quiere tirar los que están por encima o por debajo de la mediana +
    % una cantidad de desviaciones estándar a especificar
    
    % está pensada para trabajar en 2D, es decir queriendo filtrar dos
    % vectores. La variable de referencia es la que se da primero. Es
    % decir que si tengo 2 variables r,s y quiero tirar aquellos datos que
    % presentan saltos grandes en s, tengo que dar los argumentos en el
    % orden s,r
    
    % "condicion" dice si uno quiere tirar los que están por encima o por
    % debajo del umbral. "1" es por debajo, "-1" por encima
    
    % u,v son las variables filtradas
    
    % OJO! acá no interesa filtrar por debajo de un umbral, porque no me
    % preocupan saltos chicos
    
    saltos = diff(x);

    mediana = median(saltos);
    sigma = std(saltos);
    
%     if condicion == 1
        umbral = mediana + cant_sigmas*sigma;
        filtro = saltos < umbral;
%     end
    
%     if condicion == -1
        umbral = mediana - cant_sigmas*sigma;
        filtro = saltos > umbral;
%     end

    filtro = [true filtro];

    u = x(filtro);
    v = y(filtro);

end