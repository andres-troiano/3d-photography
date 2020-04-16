clear variables

path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';
path_fronteras = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';

load([path_fronteras 'fronteras.mat']);
load([path_calibracion 'FC.mat']);
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras.mat']);

for q = 1:2
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];
end
FC{2} = [FC{2}(:,1)-offset_fronteras(1), FC{2}(:,2)-offset_fronteras(2)];

mp = {'.-b', '.-r'}; % markers para los perfiles
mp2 = {'oc', 'om'}; % markers para los perfiles
mf = {'--b', '--r'}; % markers para las fronteras
mfc = {'--c', '--m'}; % markers para las fronteras de calibracion

% con esto identifico los perfiles que me interesan, que son aquellos donde
% veo las 2 esquinas del trapecio con la cámara en cuestión.
tag_x={155:5:180, 120:5:150};
tag_y={{475:5:500, 475:5:500, 460:5:500, 450:5:500, 450:5:500, 450:5:480}, {450:5:465, 440:5:475, 435:5:480, 435:5:485, 435:5:495, 430:5:490, 455:5:485}};

% posiciones estimadas de las esquinas
estimados = {[], []};
for q=1:2
    load([path_offset 'camara_' num2str(q) '.mat']);
    
    for i = 1:numel(tag_x{q})
        for j = 1:numel(tag_y{q}{i})
            ind_x = X == tag_x{q}(i);
            ind_y = Y == tag_y{q}{i}(j);
            ind_comun = ind_x & ind_y;
            n = find(ind_comun);
            
            py = Profiles(:,n);
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
            
            x = x(ind1);
            y = y(ind1);
            
            % acá detecto las 2 esquinas
            close all, f=figure; hold on, grid on
            plot(x, y, mp{q})

            xlabel('X (mm)')
            ylabel('Y (mm)')
            title(['C' num2str(q) 'X' num2str(X(n)) 'Y' num2str(Y(n))])
            axis equal

            try
                esquinas=ginput(2);
            catch E
            end
            close(f)
            % guardo las esquinas como x1, x2, y1, y2, precedidas por las
            % etiquetas del perfil
            estimados{q} = [estimados{q};[tag_x{q}(i), tag_y{q}{i}(j), reshape(esquinas, [1,4])]];
        end
    end
end
save(fullfile(path_offset, 'esquinas_estimadas_longitud_trapecio'),'estimados');

%% antes de correr esto entero, medir el trapecio con estos 4 perfiles

clear variables

path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';
path_fronteras = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';

load([path_offset 'esquinas_estimadas_longitud_trapecio.mat']);
load([path_fronteras 'fronteras.mat']);
load([path_calibracion 'FC.mat']);
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras.mat']);

for q = 1:2
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];
end
FC{2} = [FC{2}(:,1)-offset_fronteras(1), FC{2}(:,2)-offset_fronteras(2)];

set(0,'DefaultFigureVisible', 'off');

longitud = {[], []};
for q = 1:2
    fprintf(['Cámara ' num2str(q) '\n'])
    load([path_offset 'camara_' num2str(q) '.mat']);
    for i = 1:numel(estimados{q}(:,1))
        ind_x = X == estimados{q}(i,1);
        ind_y = Y == estimados{q}(i,2);
        ind_comun = ind_x & ind_y;
        n = find(ind_comun);

        py = Profiles(:,n);
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

        x = x(ind1);
        y = y(ind1);
        
        % acá corto en pedazos y detecto
        margen=10;
        if q == 1
            % vuelvo a pisar los índices, ahora refiriéndome a las 4 rectas
            % necesarias para encontrar las 2 esquinas
            ind1 = x<estimados{q}(i, 3);
            ind2 = x>estimados{q}(i, 3) & x<estimados{q}(i, 3)+margen;
            ind3 = y<estimados{q}(i, 6) & y>estimados{q}(i, 6)-margen;
            ind4 = y>estimados{q}(i, 6) & y<estimados{q}(i, 6)+margen;
        end
        
        if q == 2
            ind1 = x<estimados{q}(i, 3);
            ind2 = x>estimados{q}(i, 3) & x<estimados{q}(i, 3)+margen;
            ind3 = x<estimados{q}(i, 4) & x>estimados{q}(i, 4)-margen;
            ind4 = x>estimados{q}(i, 4);
        end
        
        % ojo que sobreescribo los ind originales por aquellos en los que
        % se estabilizó el ajuste de rectas
        [L1,estd1,n1,ind1]=fitStraightLine_longitud_trapecio(x,y,ind1);
        [L2,estd2,n2,ind2]=fitStraightLine_longitud_trapecio(x,y,ind2);
        [L3,estd3,n3,ind3]=fitStraightLine_longitud_trapecio(x,y,ind3);
        
        % en la C1 esta recta la veo vertical, entonces la ajusto con Y
        % como independiente
        if q==1
            [L4,estd4,n4,ind4]=fitStraightLine_longitud_trapecio(y,x,ind4);
            y4=y(ind4);
            x4=polyval(L4, y(ind4));
        end
        
        if q==2
            [L4,estd4,n4,ind4]=fitStraightLine_longitud_trapecio(x,y,ind4);
            x4=x(ind4);
            y4=polyval(L4, x(ind4));
        end
        
        % si para algún ajuste no había suficientes puntos y empezó a tomar
        % de otra recta, descarto
        if estd1>.4
            fprintf('Std 1 grande\n')
            continue
        end
        
        if estd2>.4
            fprintf('Std 2 grande\n')
            continue
        end
        
        if estd3>.4
            fprintf('Std 3 grande\n')
            continue
        end
        
        % este siempre va a dar grande en C1 porque estoy midendo el error
        % vertical
        if estd4>.4
            fprintf('Std 4 grande\n')
            continue
        end
        
        if numel(L1)==0
            fprintf('L1 no convergió\n')
            continue
        end
        
        % calculo la longitud
        xe1 = (L2(2) - L1(2))/(L1(1) - L2(1));
        ye1 = L1(1)*xe1 + L1(2);
        
        % la recta 4 hay que invertirla en C1
        if q == 1
            a4 = 1/L4(1);
            b4 = -L4(2)/L4(1);
        end
        
        if q == 2
            a4 = L4(1);
            b4 = L4(2);
        end
        
        xe2 = (b4 - L3(2))/(L3(1) - a4);
        ye2 = L3(1)*xe2 + L3(2);
        
        longitud{q} = [longitud{q}; norm([xe2-xe1, ye2-ye1])];
        
        close all, f=figure; hold on, grid on
        plot(x, y, '.-b')
        
%         plot(x(ind1), y(ind1), '.r')
%         plot(x(ind2), y(ind2), 'oy')
%         plot(x(ind3), y(ind3), '.c')
%         plot(x(ind4), y(ind4), '.m')
        
        plot(x(ind1), polyval(L1, x(ind1)), '.r')
        plot(x(ind2), polyval(L2, x(ind2)), 'oy')
        plot(x(ind3), polyval(L3, x(ind3)), '.c')
        plot(x4, polyval([a4 b4], x4), '.m')
%         plot(x4, y4, '.m')
        plot(xe1, ye1, '*r')
        plot(xe2, ye2, '*g')

        xlabel('X (mm)')
        ylabel('Y (mm)')
        title(['C' num2str(q) 'X' num2str(X(n)) 'Y' num2str(Y(n))])
        axis equal
        saveas(f, [path_offset 'medicion_longitud_trapecio\camara_' num2str(q) '\C' num2str(q) 'X' num2str(X(n)) 'Y' num2str(Y(n)) '.png'])
        
    end
end
set(0,'DefaultFigureVisible', 'on');

for q = 1:2
    fprintf('LC%d = %.3f +- %.3f\n', q, mean(longitud{q}), std(longitud{q}))
end

% CON LA CÁMARA 1 NO PUEDO VER LA CARA DEL TRAPECIO QUE ME INTERESA!
% Porque no el trapecio no está alineado con esa cámara, sí con la otra
% Entonces, sólo puedo medir la longitud con la C2