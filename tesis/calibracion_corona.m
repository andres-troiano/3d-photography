clear variables
path_1 = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion44\';
path_2 = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion45\';

esquinas_pixels={[],[]}; % px_promedio, py_promedio
t = [9,9]; % con radio 1 ambos t son 9
close all
figure(1), hold on, grid on, title('Cámara 1')
figure(2), hold on, grid on, title('Cámara 2')
for i=1:6
    load([path_1 'radio' num2str(i) '/intersecciones.mat']);
    for q=1:2
        figure(q)
        plot(intersecciones{q}(:,1), intersecciones{q}(:,2), '.b')
        P_avg = nan(t(q),2); % coordenadas en pixels promediadas, para 1 radio
        for k = 1:t(q)
            px = intersecciones{q}(k:t(q):end-k,1);
            py = intersecciones{q}(k:t(q):end-k,2);
            P_avg(k,:)=[mean(px)', mean(py)'];
        end
        plot(P_avg(:,1), P_avg(:,2), '+r')
        esquinas_pixels{q} = [esquinas_pixels{q}; P_avg];

        axis equal
    end
end

save(fullfile(path_1, 'esquinas_pixels'),'esquinas_pixels');

%% lo corro de nuevo con el otro barrido

esquinas_pixels={[],[]}; % px_promedio, py_promedio
t = [9,9]; % con radio 1 ambos t son 9
close all
figure(1), hold on, grid on, title('Cámara 1')
figure(2), hold on, grid on, title('Cámara 2')
for i=1:6
    load([path_2 'radio' num2str(i) '/intersecciones.mat']);
    for q=1:2
        figure(q)
        plot(intersecciones{q}(:,1), intersecciones{q}(:,2), '.b')
        P_avg = nan(t(q),2); % coordenadas en pixels promediadas, para 1 radio
        for k = 1:t(q)
            px = intersecciones{q}(k:t(q):end-k,1);
            py = intersecciones{q}(k:t(q):end-k,2);
            P_avg(k,:)=[mean(px)', mean(py)'];
        end
        plot(P_avg(:,1), P_avg(:,2), '+r')
        esquinas_pixels{q} = [esquinas_pixels{q}; P_avg];

        axis equal
    end
end

save(fullfile(path_2, 'esquinas_pixels'),'esquinas_pixels');

%% convierto una de las 2 C a mm

clear variables
path_mm = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion44\';
path_px = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion45\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

load([path_mm 'esquinas_pixels.mat']);
intersections_mm=esquinas_pixels;
load([path_px 'esquinas_pixels.mat']);
intersections_px=esquinas_pixels;
load([path_calibracion 'calibration.mat']);
load([path_calibracion 'FC.mat']);
load([path_offset 'offset.mat']);

mc = {'ob', '+r'};
mf = {'--b', '--r'};
mfc = {'--c', '--m'};

C={[],[]};
close all
for q = 1:2
    px = intersections_mm{q}(:,1);
    py = 1088-intersections_mm{q}(:,2);
    x = polyval4XY(px2mmPol{q}(1), px, py);
    y = polyval4XY(px2mmPol{q}(2), px, py);
    
    px = intersections_px{q}(:,1);
    py = 1088-intersections_px{q}(:,2);

    % convierto a mm las fronteras dadas por la calibración
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];

    % desplazar el 2do
    if q == 2
        x = x-offset(1);
        y = y-offset(2);

        FC{q} = [FC{q}(:,1)-offset(1), FC{q}(:,2)-offset(2)];
    end

    % ahora que tengo definidos x,y, les aplico las fronteras
%     ind1 = inpolygon(x, y, F{q}(:,1), F{q}(:,2));
    ind2 = inpolygon(x, y, FC{q}(:,1), FC{q}(:,2));
    ind1 = true(size(ind2)); % por ahora no uso F

    ind = ind1&ind2;

    % para medir con calibraciones viejas necesito ignorar toda
    % frontera
    %         ind = true(numel(x),1);

    % 
    % armo C como con el trapecio y demás
    C{q} = [px(ind), py(ind), x(ind), y(ind)];

    %         plot(x,y,mc{q})
    figure(1), hold on, grid on
    plot(C{q}(:,3),C{q}(:,4),mc{q})
%     plot(F{q}(:,1), F{q}(:,2), mf{q})
    plot(FC{q}(:,1), FC{q}(:,2), mfc{q})
    
    xlabel('X (mm)')
    ylabel('Y (mm)')
    axis equal
end

save(fullfile(path_mm, 'intersections'),'C');

%%

clear variables
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion44\';

load([path_calibracion 'intersections.mat']);
calculateCalibration_corona(C, path_calibracion);

%% genero FC

fronteraZonaEfectiva_corona(path_calibracion);

%% mido los cilindros

clear variables, clc

path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion44\';

load([path_calibracion 'calibration.mat']);
% load([path_calibracion 'fronteras.mat']);
load([path_calibracion 'FC.mat']);

frame_cilindro = {'patron_34700530', 'patron_34700630', 'patron_34700730'};
id_cilindro = {'34700530', '34700630', '34700730'};
nominales = [139.707, 168.310, 177.805];

frames_cilindro = {[], []};

for f = 1:3
    close all
    for q = 1:2
        % ojo: le estoy pasando 2 veces FC, porque quiero medir antes de
        % calcular el +-35
        frames_cilindro{q} = [path_datos frame_cilindro{f} '_camara_' num2str(q) '.png'];
    end
    [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron_con_corona(frames_cilindro, id_cilindro{f}, px2mmPol, FC, FC, [path_datos 'medicion_con_corona\']); % por ahora no uso F
    fprintf([id_cilindro{f} '\nError 2 cámaras: %.3f mm\nError C1: %.3f mm, Error C2: %.3f mm\nCentro global: (%.3f, %.3f)\nCentro C1: (%.3f, %.3f)\nCentro C2: (%.3f, %.3f)\n\n'], 2*r_teorico - nominales(f), 2*r_individual(1) - nominales(f), 2*r_individual(2) - nominales(f), centro_x, centro_y, centro_individual{1}(1), centro_individual{1}(2), centro_individual{2}(1), centro_individual{2}(2))
end
