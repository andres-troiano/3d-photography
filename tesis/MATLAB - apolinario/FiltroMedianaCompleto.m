function[u,v] = FiltroMedianaCompleto(x,y,cant_sigmas)
    
    %tiro puntos que se alejan de la mediana, tanto en x como en y, tanto
    %por encima como por debajo

    ind=true(size(x));
    mediana = median(x);
    sigma=std(x);
    ind1 = x<mediana+cant_sigmas*sigma;
    ind2 = x>mediana-cant_sigmas*sigma;
    mediana = median(y);
    sigma=std(y);
    ind3 = y<mediana+cant_sigmas*sigma;
    ind4 = y>mediana-cant_sigmas*sigma;
    
    ind=ind1&ind2&ind3&ind4;
    u=x(ind);
    v=y(ind);

end