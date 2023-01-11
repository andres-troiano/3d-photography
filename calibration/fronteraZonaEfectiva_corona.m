function [px_bound, py_bound] = fronteraZonaEfectiva_corona(path_calibracion)

    % atenci�n! Las fronteras que devuelve esta funci�n est�n en PIXELS (no
    % s� si es lo m�s conveniente). Desde ya que despu�s de convertir hay
    % que aplicar el offset que corresponda
    
    % esta es una modificacion para la calibracion con corona, porque en
    % este caso C tiene menos columnas

    load([path_calibracion 'intersections.mat']);

    FC = {[],[]};
    
    close all
    for q=1:2
        figure, hold on, grid on
        
        ind1 = true(numel(C{q}(:,1)),1); % no filtro nada
        
        x = C{q}(ind1,1);
        y = C{q}(ind1,2);
        
        j = boundary(x, y, 0.3);
        px_bound = x(j);
        py_bound = y(j);
        
        plot(x,y,'.')
        plot(px_bound, py_bound, '-')
        title(['C�mara ' num2str(q)])
        
        FC{q} = [px_bound, py_bound];
    end
    save(fullfile(path_calibracion,'FC.mat'),'FC')
end