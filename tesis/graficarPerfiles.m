clear variables

path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';
path_fronteras = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';

load([path_offset 'intersections.mat']);
load([path_fronteras 'fronteras.mat']);
load([path_calibracion 'FC.mat']);
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras.mat']);

% convierto a mm las fronteras dadas por la calibración
for q = 1:2
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];
end
FC{2} = [FC{2}(:,1)-offset_fronteras(1), FC{2}(:,2)-offset_fronteras(2)];

set(0,'DefaultFigureVisible', 'off');

mp = {'.-b', '.-r'}; % markers para los perfiles
mp2 = {'oc', 'om'}; % markers para los perfiles
mf = {'--b', '--r'}; % markers para las fronteras
mfc = {'--c', '--m'}; % markers para las fronteras de calibracion


for q=1:2
    
    load([path_offset 'camara_' num2str(q) '.mat']);

    ind1=C{q}(:,6)>.4;
    ind2=C{q}(:,8)>.4;
    ind3=C{q}(:,7)<100;
    ind4=C{q}(:,9)<100;

    ind=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
    
    N = sum(ind);
    
    for i=1:N
        if ind==0
            continue
        end
        
        fprintf('Paso %d de %d\n', i, N);
    
        py = Profiles(:,i);
        py=1088-py;
        px=(1:numel(py))';
        
        x = polyval4XY(px2mmPol{q}(1), px, py);
        y = polyval4XY(px2mmPol{q}(2), px, py);
        
        if q == 2
            x = x-offset_fronteras(1);
            y = y-offset_fronteras(2);
        end
        
        ind1 = inpolygon(x, y, F{q}(:,1), F{q}(:,2));
        ind2 = inpolygon(x, y, FC{q}(:,1), FC{q}(:,2));
        
        ind1 = ind1&ind2; % ojo que estoy pisando variables viejas
        
        if sum(ind1) == 0
            continue
        end

        close all, f=figure; hold on, grid on
%         plot(x, y, mp{q})
        plot(x(ind1), y(ind1), mp{q})
        plot(F{q}(:,1), F{q}(:,2), mf{q})
        plot(FC{q}(:,1), FC{q}(:,2), mfc{q})
        
        xlabel('X (mm)')
        ylabel('Y (mm)')
        title(['C' num2str(q) 'X' num2str(X(i)) 'Y' num2str(Y(i))])
        axis equal
        saveas(f, [path_offset 'graficos_perfiles\camara_' num2str(q) '\C' num2str(q) 'X' num2str(X(i)) 'Y' num2str(Y(i)) '.png'])
    
    end
    
end

set(0,'DefaultFigureVisible', 'on');