function [px_bound, py_bound] = fronteraZonaEfectiva(path_calibracion)

    % atención! Las fronteras que devuelve esta función están en PIXELS (no
    % sé si es lo más conveniente). Desde ya que después de convertir hay
    % que aplicar el offset que corresponda

    load([path_calibracion 'intersections.mat']);

    FC = {[],[]};
    
    close all
    for q=1:2
        figure, hold on, grid on
        
        ind1=C{q}(:,6)>.4;
        ind2=C{q}(:,8)>.4;
        ind3=C{q}(:,7)<100;
        ind4=C{q}(:,9)<100;

        ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
        
        x = C{q}(ind1,1);
        y = C{q}(ind1,2);
        
        j = boundary(x, y, 0.1);
        px_bound = x(j);
        py_bound = y(j);
        
        plot(x,y,'.')
        plot(px_bound, py_bound, '-')
        title(['Cámara ' num2str(q)])
        
        FC{q} = [px_bound, py_bound];
    end
    save(fullfile(path_calibracion,'FC.mat'),'FC')
end