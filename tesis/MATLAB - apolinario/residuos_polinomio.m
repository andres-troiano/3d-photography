clear variables
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';

load([path_calibracion 'intersections.mat']); % esto es C
load([path_calibracion 'calibration.mat']); % px2mmPol
% load([path_calibracion 'fronteras.mat']); % F. Esta no me interesa porque
% está en mm
load([path_calibracion 'FC.mat']); % FC

%%

mc = {'.b', '.r'};
mf = {'--b', '--r'}; % markers para las fronteras

% C tiene: xc,yc,X,Y,k,estd1,n1,estd2,n2,x1,x2,x3,x4,y1,y2,y3,y4

close all
for q = 1%:2
    
    % medir diferencia entre polinomio y dato
    
    ind = inpolygon(C{q}(:,1), C{q}(:,1), FC{q}(:,1), FC{q}(:,2));
    
    px = C{q}(ind,1);
    py = C{q}(ind,2);
    x = C{q}(ind,3);
    y = C{q}(ind,4);
    x_modelo = polyval4XY(px2mmPol{q}(1), px, py);
    y_modelo = polyval4XY(px2mmPol{q}(2), px, py);
    
    % ERROR EN X
    figure; hold on, grid on
    
    plot3(px,py,x_modelo-x, '.r')
    
    xlabel('X (px)')
    ylabel('Y (px)')
    zlabel('Error en X (mm)')
    title(['Cámara ' num2str(q) ' - Error en X'])
    
    % ERROR EN Y
    figure; hold on, grid on
    
    plot3(px,py,y_modelo-y, '.r')
    
    xlabel('X (px)')
    ylabel('Y (px)')
    zlabel('Error en Y (mm)')
    title(['Cámara ' num2str(q) ' - Error en Y'])
    
     
end