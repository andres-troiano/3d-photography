% modificacion odel original, que lo que hace es calcular el +-35 ANTES de
% calcular el offset, es decir calcula el +-35 individual de cada c�mara,
% con esa restricci�n calcula el offset y despu�s se hace el ajuste
% global.

clear variables
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion47_CST/';

%%

% % clasifico los datos, eliminando aquellas capturas en las que no se vio
% % nada
% creo_directorios_2_camaras(path_calibracion);
% separar_frames_utiles(path_calibracion, 1);
% separar_frames_utiles(path_calibracion, 2);
% % ac� estar�a bueno eliminar los archivos originales, para no tenerlos
% % duplicados
% convertFiles2DotMatPath(path_calibracion);

%% acá uso parábolas

% encuentro la posici�n de las esquinas del patr�n
calculateIntersections_hexagono_curvo(path_calibracion);

%%

load([path_calibracion 'intersections_curvo.mat']);
C = C_curvo;
% % teniendo las coordenadas de cada esquina en mm y en pixels, calibro el
% % sistema
calculateCalibration_CST(C, path_calibracion);

%% encuentro los centros

% teniendo una primera calibraci�n hay que:
% * usar el offset conocido del hex�gono, pasando por el centro
% * calcular las fronteras propias de esta calibraci�n
% * calibrar una segunda vez s�lo en la zona de inter�s
% * medir los patrones

% 1er paso: calcular los �ngulos. Para esto tengo rectas.mat, generado por
% calculateIntersections_hexagono
% ahora puedo cargar los x,y de las esquinas, m�s las rectas y as� calcular
% xc,yc para cada punto.
% Para empezar no voy a calcular el �ngulo, voy a usar el te�rico (120).
% Para eso voy a usar s�lo L1 y le sumo 60�

clear variables
set(0,'DefaultFigureVisible', 'off');
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion47_CST/';

load([path_calibracion 'intersections_curvo.mat']);
C = C_curvo;
load([path_calibracion 'rectas.mat']);
load([path_calibracion 'calibration_CST.mat']);

r = 59.975/2;

close all
% coordenadas del centro del hex�gono
centros = {[], []};
% ac� guardo la pendiente de la cara izq, a la cual le resto 60�. Para ver
% qu� dispersi�n tienen mis resultados, dado que el �ngulo y el radio que
% uso son ctes.
pendientes = {[], []};
for q = 1:2
    
    load([path_calibracion 'camara_' num2str(q) '.mat']);
    
    ind1=C{q}(:,6)>.4;
    ind2=C{q}(:,8)>.4;
    ind3=C{q}(:,7)<100;
    ind4=C{q}(:,9)<100;

    ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
    
    indices = 1:numel(ind1);
    indices = indices(ind1); % estos son los indices donde hay perfiles v�lidos
    N = numel(indices);
    
    centro_individual = nan(N, 4);
    pendiente_individual = nan(N, 1);
    
    for i = 1:N
        fprintf('C%d - Paso %d de %d\n', q, i, N)
        n = indices(i);
        
        pxe = C{q}(n,1);
        pye = C{q}(n,2);
        
        px_recta = linspace(pxe-50, pxe)'; % tomo puntos en un entorno de la esquina
        py_recta = polyval(R{q}(n,1:2), px_recta); % me conviene usar la recta izquierda
        % porque la derecha es casi vertical en la c�mara 1, con lo cual su
        % pendiente diverge
        
        % grafico el perfil
        py = 1088-(Profiles(:,n));
        px = (1:numel(py))';
        
        % convierto
        x = polyval4XY(px2mmPol{q}(1), px, py);
        y = polyval4XY(px2mmPol{q}(2), px, py);
        x_recta = polyval4XY(px2mmPol{q}(1), px_recta, py_recta);
        y_recta = polyval4XY(px2mmPol{q}(2), px_recta, py_recta);
        xe = polyval4XY(px2mmPol{q}(1), pxe, pye);
        ye = polyval4XY(px2mmPol{q}(2), pxe, pye);
        
%         t = (max(y_recta) - min(y_recta))/(max(x_recta) - min(x_recta)); % esto da siempre positivo para cualquier �ngulo
        t=(y_recta(end) - y_recta(1))/(x_recta(end) - x_recta(1));
        a = tand(atand(t)-60); % le sumo 60� a la pendiente (por la orientaci�n
        % que tiene el perfil es una resta)
        b = ye - a*xe;
        y_recta2 = polyval([a b], x_recta);
        
        % me muevo por esta direcci�n el radio
        offset_x = r*cos(atan(a));
        offset_y = r*sin(atan(a));
        
        centro_x = xe-offset_x;
        centro_y = ye-offset_y;
        
        close all, f=figure(3); hold on, grid on
        
        plot(x, y, '.-b')
        plot(x_recta,y_recta, '.r')
        plot(xe,ye,'*r')        
%         plot(x_recta,y_recta2,'.g')
        plot(centro_x, centro_y, '*m')
        
        axis equal
        title(sprintf('C%dX%dY%d', q, X(n), Y(n)))
        margen=45;
        xlim([xe-margen, xe+margen])
        ylim([ye-margen, ye+margen])
        saveas(f, [path_calibracion 'graficos_centros/camara_' num2str(q) '\C' num2str(q) 'X' num2str(X(n)) 'Y' num2str(Y(n)) '.png'])
        
        centro_individual(i,:) = [X(n), Y(n), centro_x, centro_y];
        pendiente_individual(i) = t;
    end
    centros{q} = centro_individual;
    pendientes{q} = pendiente_individual;
end
save(fullfile(path_calibracion, 'centros'),'centros');
save(fullfile(path_calibracion, 'pendientes'),'pendientes');
set(0,'DefaultFigureVisible', 'on');

%% calculo las fronteras antes del offset

clear variables

path_datos= '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion48_CST/';
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion47_CST/';

% creo que esto no se usa
% path_offset = '/home/andres/DIRECTORIO TESIS/2021/curvo/medicion47_curvo/';

load([path_calibracion 'calibration_CST.mat']);

% esto cuándo se calcula??
% load([path_offset 'offset_hexagono.mat']);
% offset=offset_hexagono;

% determinar el centro del cilindro 630
frames = {'patron_34700630_camara_1.png', 'patron_34700630_camara_2.png'};

close all,figure(1),hold on
XY = {[], []}; % ac� habr�a que prealocar
% coordenadas de los puntos centrales de cada perfil, en mm. En columnas:
% xc;yc
M = {nan(2,1), nan(2,1)};
% este valor me sirve para separar los datos de cada c�mara despu�s de
% haberlos juntado en XY, as� no los tengo que volver a procesar
s = nan; 
R = {nan(200,2), nan(200,2)};
F = {nan(1e3,2),nan(1e3,2)};
for q = 1:2
    
    I=imread(fullfile(path_datos, frames{q}));
    Iinfo=imfinfo(fullfile(path_datos, frames{q}));
    if ~isempty(Iinfo.SignificantBits)
        I=bitshift(I,Iinfo.SignificantBits-16);
    elseif ~isempty(Iinfo.BitDepth)
        I=double(I)/Iinfo.BitDepth;
    end
    I=double(I);
    frame = I;
    
    py = median(frame);
    px = 1:size(py,2);
    [px, py] = tiro_datos_nulos_perfil(px, py);
    px = px.';
    py = py.';
    
    py = 1088-py;
    
    if q == 1
        s = numel(py);
    end
    
    % ubico �ndice correspondiente al m�ximo en p�xels, que corresponde al
    % punto central del arco
    [m,i] = max(py);
    
    x = polyval4XY(px2mmPol{q}(1), px, py);
    y = polyval4XY(px2mmPol{q}(2), px, py);
    
    % guardo los puntos centrales de cada perfil
    xc = x(i);
    yc = y(i);
    M{q}(:) = [xc;yc];
    
    if q == 1
        plot(x,y,'ob')
    end
    
    if q == 2
        plot(x,y,'.r')
    end
    
    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    
    XY = [x,y];
    
    circulo = TaubinNTN(XY);

    centro_x = circulo(1);
    centro_y = circulo(2);
    r_teorico = circulo(3);
    
    t = linspace(0, 2*pi, 100)';
    x_teorico = r_teorico * cos(t) + centro_x;
    y_teorico = r_teorico * sin(t) + centro_y;
    
    plot(x_teorico, y_teorico, '--k')
    plot(centro_x, centro_y, '+r')
    
    r_int = r_teorico - 40;
    r_ext = r_teorico + 40;

    t = {linspace(-1.2,0.1)', linspace(-2.3,-1)'};
    m = {'--b', '--r'}; % markers
    
    x_int = centro_x + r_int*cos(t{q});
    y_int = centro_y + r_int*sin(t{q});

    x_ext = centro_x + r_ext*cos(t{q});
    y_ext = centro_y + r_ext*sin(t{q});

    plot(x_int, y_int, m{q})
    plot(x_ext, y_ext, m{q})

    % flipeo el externo para que vaya en el sentido del recorrido
    x_ext = flipud(x_ext);
    y_ext = flipud(y_ext);
    
    R{q}(:,:) = [[x_int;x_ext], [y_int;y_ext]];
    
    j = 1;
    k = 100; % porque s� que cada parte radial es un linspace de 100
    F{q}(j:k,:) = [R{q}(101:200,1), R{q}(101:200,2)];
    
    alpha = calculo_angulo([0, 0], [0, 1], [M{q}(1), M{q}(2)], [centro_x, centro_y]);
    
    alpha_izq = alpha + 35;
    alpha_der = alpha - 35;
    
    % otro parche horrible xq en la 1 me quedan invertidas las rectas izq y
    % der
    
    if q == 1
        alpha_der = alpha + 35;
        alpha_izq = alpha - 35;
    end
    
    a = tand(alpha+90); % esto est� horriblemente emparchado. Deber�a entenderlo
    if q==2
        a=tand(90-alpha);
    end
    y_recta = a*x + (centro_y - a*centro_x);
    
%     % ajusto finamente las rectas para armar la m�scara
%     % primero el X izquierdo

    a = tand(alpha_izq+90);
    if q==2
        a=tand(90-alpha_izq);
    end
    
    if q==1
        x_izq=linspace(199,234)';
        x_izq = flipud(x_izq);
    end
    
    if q==2
        x_izq=linspace(131,181)';
    end
    y_izq = a*x_izq + (centro_y - a*centro_x);
    
    % agrego a las fronteras
    j = k+1;
    k = k + numel(x_izq);
    F{q}(j:k,:) = [x_izq, y_izq];
    
    j = k+1;
    k = k + 100;
    F{q}(j:k,:) = [R{q}(1:100,1), R{q}(1:100,2)];
    
    % ahora la recta derecha
    if q==1
        x_der=linspace(225,305)';
    end
    
    if q==2
        x_der=linspace(230,275)';
    end

    a = tand(alpha_der+90);
    if q==2
        a=tand(90-alpha_der);
    end
    y_der = a*x_der + (centro_y - a*centro_x);
    
    % agrego a la frontera
    j = k+1;
    k = k + numel(x_der);
    F{q}(j:k,:) = [x_der, y_der];
    
    plot(centro_x, centro_y, '+b')
    
    if q == 1
        plot(x_izq, y_izq, '--b')
        plot(x_der, y_der, '--b')
    end
    
    if q == 2
        plot(x_izq, y_izq, '--r')
        plot(x_der, y_der, '--r')
    end
    
%     plot(x, y_recta, '--k')
    
    % elimino los nan
    ind2 = ~isnan(F{q}(:,1));
    F{q} = F{q}(ind2, :);

end

plot(M{1}(1), M{1}(2), 'og')
plot(M{2}(1), M{2}(2), 'og')

save(fullfile(path_calibracion, 'fronteras_2'),'F');

%% calculo el offset, teniendo ya las F sin desplazar

% hasta ac� le estoy asignando la misma etiqueta a esquinas que en cada
% c�mara son distintas. El promedio del offset entre los centros calculados
% con una c�mara y otra es la traslaci�n que le tengo que aplicar a una de
% las 2 c�maras. Igual me va a quedar una dispersi�n.

clear variables
close all
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion47_CST/';
load([path_calibracion 'centros.mat']);

% para cuantificar el error entre los centros hay que encontrar los x,y
% para los que hubo detecci�n en ambas c�maras

x_comunes = intersect(centros{1}(:,1), centros{2}(:,1));
y_comunes = intersect(centros{1}(:,2), centros{2}(:,2));

% filtro con las fronteras
load([path_calibracion 'fronteras_2.mat']);
load([path_calibracion 'FC.mat']);
load([path_calibracion 'calibration_CST.mat']);

error = nan(numel(x_comunes)*numel(y_comunes), 4); % x, y, error_x, error_y
k=0;
for i = 1:numel(x_comunes)
    for j = 1:numel(y_comunes)
        N=nan(2,1); % indices que busco en cada camara
        k=k+1;
        for q = 1:2
            ind_x = centros{q}(:,1) == x_comunes(i);
            ind_y = centros{q}(:,2) == y_comunes(j);
            ind_comun = ind_x & ind_y;
            n=find(ind_comun);
            if numel(n)==0
                continue
            end
            N(q) = n;
        end
        if any(isnan(N))
            continue
        end
        
        error(k,:) = [x_comunes(i), y_comunes(j), centros{1}(N(1),3)-centros{2}(N(2),3), centros{1}(N(1),4)-centros{2}(N(2),4)];
    end
end

% hay que tirar los nan antes de promediar
ind = ~isnan(error(:,1));
ind1 = inpolygon(error(:,1), error(:,2), F{1}(:,1), F{1}(:,2));
ind2 = inpolygon(error(:,1), error(:,2), F{2}(:,1), F{2}(:,2));

ind = ind & ind1 | ind2;

for q = 1:2
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];
end

figure,hold on,grid on
plot(error(ind,1), error(ind,2), '.b')
plot(F{1}(:,1), F{1}(:,2), '--b')
plot(F{2}(:,1), F{2}(:,2), '--r')
plot(FC{1}(:,1), FC{1}(:,2), '--c')
plot(FC{2}(:,1), FC{2}(:,2), '--m')
title('Puntos v�lidos para calcular el offset')

% offset_x, offset_y, error_offset_x, error_offset_y
% le pongo un - adelante para que tenga el mismo signo que el offset del
% trapecio
offset_hexagono = [-mean(error(ind,3)), -mean(error(ind,4)), std(error(ind,3)), std(error(ind,4))];

save(fullfile(path_calibracion, 'offset_hexagono'),'offset_hexagono');

% close all
f1=figure; hold on, grid on
plot3(error(ind,1), error(ind,2), error(ind,3) + offset_hexagono(1),'.')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Error en offset X (mm)')
view(28,26)
saveas(f1, [path_calibracion 'graficos_centros/offset_en_X.png'])

f2=figure; hold on, grid on
plot3(error(ind,1), error(ind,2), error(ind,4) + offset_hexagono(2),'.')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Error en offset Y (mm)')
view(30,24)
saveas(f2, [path_calibracion 'graficos_centros/offset_en_Y.png'])

fprintf('Std del offset en X: %.3f mm\nStd del offset en Y: %.3f mm\n', offset_hexagono(3), offset_hexagono(4))

%% genero las FC
fronteraZonaEfectiva_curvo(path_calibracion);

%% mido cilindros

clear variables, clc

% para trabajar con datos nuevos:
path_datos = '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion48_CST/';
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/curvo_sin_tirar/medicion47_CST/';

load([path_calibracion 'calibration_CST.mat']);
load([path_calibracion 'offset_hexagono.mat']);
load([path_calibracion 'fronteras_2.mat']);
load([path_calibracion 'FC_curvo.mat']);

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
    [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron(frames_cilindro, id_cilindro{f}, px2mmPol, offset_hexagono, F, FC, [path_datos 'medicion_con_hexagono\']); % con las fronteras en el offset
    fprintf([id_cilindro{f} '\nError 2 c�maras: %.3f mm\nError C1: %.3f mm, Error C2: %.3f mm\nCentro global: (%.3f, %.3f)\nCentro C1: (%.3f, %.3f)\nCentro C2: (%.3f, %.3f)\n\n'], 2*r_teorico - nominales(f), 2*r_individual(1) - nominales(f), 2*r_individual(2) - nominales(f), centro_x, centro_y, centro_individual{1}(1), centro_individual{1}(2), centro_individual{2}(1), centro_individual{2}(2))
end