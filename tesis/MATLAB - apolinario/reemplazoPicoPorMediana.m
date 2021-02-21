function [y]=reemplazoPicoPorMediana(y)
% no se usa x. Pensado para usar en findShiftBetweenSignals
    m = median(y);
    u = 75; % umbral fijo
    ind = y > m+u | y < m-u;
    y(ind)=m;
    
%     figure,plot(y)
end