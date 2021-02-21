% variación del script anterior, donde en este caso recorro todas las
% esquinas de izq a der.

% ANTES DE CORRER ESTE SCRIPT hay que convertir a .mat

% la variable "radio" se carga con los .mat

clear variables
clc

% Por ahora ESTE VALOR SE PONE A MANO
corona = 6;

basepath=['C:\Users\60069978\Documents\MATLAB\medicion45\radio' num2str(corona)];
filename={'PerfilesCoronaCamara1.mat','PerfilesCoronaCamara2.mat'};

close all
n0=19;
%valores con los que selecciono el pedacito donde ajusto
rango = 15;
% margen=6;

% qué dimensiones tiene que tener esto?
% una celda por cada cámara, una celda por cada perfil
% LL={cell(1,6),cell(1,6)};

% valores_iniciales = [791; 831]; % radio 1
% valores_iniciales = [771; 812]; % radio 2
% valores_iniciales = [751; 791]; % radio 3
% valores_iniciales = [730; 772]; % radio 4
% valores_iniciales = [710; 752]; % radio 5
valores_iniciales = [690; 732]; % radio 6



for q=1:2
    % inicializo el array de rectas. Asumo que no voy a tener más de 10.
    % Siempre tengo 2 parámetros
    fd=filename{q};
	load(fullfile(basepath,fd));
%     for k = 1:size(Profiles,2)

    % hago otro for, sobre las esquinas de un mismo radio
    N = 10; % cantidad de rectas que voy a detectar
    R = nan(2,2*N);

    % recorro perfiles
    for k = 1:11 % ojo con este número
%     for k = 6
        % itero sobre los sentidos derecho e izquierdo
        % derecho = 0, izq = 1
        l=0; % este índice se mueve por todas las puntas de un perfil
            
        x=(1:size(Profiles,1))';
        y=Profiles(:,k);
        
        p = valores_iniciales(q);
        
        [x_lim, y_lim] = tiro_datos_nulos_perfil(x, y);
        
        h=figure(1);hold on,plot(x, y, '.-b')
        for sentido = 0
            xguess=round(p(1));
            
            for j=1:N
                l=l+1;
%                 fprintf('Cámara %d, perfil %d, sentido %d, esquina %d, valor inicial %.3f\n', q, k, sentido, l, round(p(1)))
                fprintf('Cámara %d, perfil %d, esquina %d\n', q, k, l)
                % dado el xguess, ajusto la recta a la derecha
                if sentido == 0
                    ind=(xguess+7:xguess+20-4)'; % funcionó bien para radios chicos
%                     ind=(xguess+3:xguess+20-7)'; % para radios grandes
                end
%                 if sentido == 1
%                     ind=(xguess-rango-margen:xguess-margen)'; % dejo un margen para no ajustar sobre la punta
%                 end
                
                if ind(end)>2048
                    fprintf('  ### DESCARTADO por llegar al extremo\n')
                    figure,plot(Profiles(:,k),'.-')
                    continue
                end
                
                flag = 0;
                
%                 fprintf('Ajusto la recta número %d\n',l)
                [L,estd,n,iR,iL]=fitStraightLineCorona(x,y,ind);
                if isnan(iR) == 1
                    fprintf('### falló el ajuste\n')
                    continue
                end
    %             fprintf(', std2=%.2f, n2=%d',estd,n)
                if isempty(L) || n<n0-10 || estd>1.55
                    fprintf('  ### DESCARTADO por mal ajuste L2 ###\n')
                    continue
                end
                
                x_recta = iL:iR;
                y_recta = polyval(L,x_recta);

                % propongo el próximo xguess a la derecha
                xguess=GuessNextCornerCorona(x,y,L,iR,estd,sentido);
                
%                 set(0,'DefaultFigureVisible', 'off')

%                 h=figure(1);hold on,plot(x, y, '.-b'),plot(x_recta,y_recta,'.r')
                tit=sprintf('Camara %d, Radio %d, Perfil %d', q, corona, radio(k));title(tit),xlabel('Pixel X'),ylabel('Pixel Y'),grid on,axis equal
                xlim([min(x_lim) max(x_lim)]),ylim([min(y_lim) max(y_lim)])
%                 plot(xguess, y(xguess), '*y')
%                 plot(x(ind), y(ind), '.g')
                plot(x(iL:iR), polyval(L, x(iL:iR)), '.m')
                saveas(h, fullfile(basepath, sprintf('graficos\\Camara%d_Radio%d_Perfil%d', q, corona, radio(k))), 'png')

                % dentro de un mismo radio, voy guardando todas las rectas en
                % una estructura
                R(:,l)=L;
            end
        end
        save(fullfile(basepath, sprintf('rectas_camara%d_radio%d_perfil%d', q, corona, radio(k))),'R')
        close all
    end
    close all
end

% plot(x(ind), y(ind), '.m')

%%

clear variables
clc

% ESTO SE FIJA A MANO!
corona = 6;
% radio = 0:10:200;   % radio 1
radio = 0:5:100;  % radios 2:6
cant_perfiles = 11; % OJO con ésto

basepath= ['C:\Users\60069978\Documents\MATLAB\medicion45\radio' num2str(corona) '\'];
filename={'PerfilesCoronaCamara1.mat','PerfilesCoronaCamara2.mat'};

% load(fullfile(basepath,'PerfilesCoronaCamara1.mat'));
% load(fullfile(basepath,'intersecciones_corona.mat'));

% necesito una por cámara, con los 6 perfiles
% por cada perfil tengo 9 puntos
% pongo un perfil a continuación del anterior
intersecciones = {NaN(9*cant_perfiles,2), NaN(9*cant_perfiles,2)};

set(0,'DefaultFigureVisible', 'on')

% camara
for q=1:2
    
    close all
    h=figure;
    hold on
    grid on

    % perfil
    load(fullfile(basepath,sprintf('PerfilesCoronaCamara%d.mat',q)));
    for k=1:cant_perfiles
        
        load(fullfile(basepath, sprintf('rectas_camara%d_radio%d_perfil%d.mat', q, corona, radio(k))))

        x=(1:size(Profiles,1))';
        y=Profiles(:,k);
        [x_lim, y_lim] = tiro_datos_nulos_perfil(x, y);
        [x_lim,y_lim] = FiltroMedianaCompleto(x_lim,y_lim,3);

        % perfil
        plot(x, y, '-')

        % rectas
%         for j=1:size(R,2)
%             plot(x, polyval(R(:, j), x), '--')
%         end

        esquinas = NaN(9,2);
        % esquinas
        for j=1:9
            [x0, y0] = interseccion_2_rectas(R(:, j), R(:, j+1));
            plot(x0,y0,'*r')
            esquinas(j,:) = [x0, y0];
        end
        
        intersecciones{q}(1+9*(k-1):9*k, :) = esquinas;

        axis equal
        xlim([min(x_lim) max(x_lim)]),ylim([min(y_lim)-50 max(y_lim)+70])
        xlabel('Pixel X')
        ylabel('Pixel Y')
%         title(sprintf('Cámara %d, perfil %d', q, k))
        title(sprintf('Cámara %d', q))

%         saveas(h, fullfile(basepath, sprintf('esquinas\\EsquinasCamara%d_Perfil%d', q, k)), 'png')
%         close all
    end
    saveas(h, fullfile(basepath, sprintf('esquinas\\EsquinasCamara%d', q)), 'png')
end

save(fullfile(basepath, 'intersecciones'),'intersecciones')

%%

clear variables

% dadas las esquinas que encontré, convierto a mm con mi calibración hecha
% con los stages

corona = 1;

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_datos= 'C:\Users\Norma\Downloads\datos_calibraciones\medicion44\';
path_radio= ['C:\Users\Norma\Downloads\datos_calibraciones\medicion44\radio' num2str(corona) '\'];
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

load([path_calibracion 'intersections.mat']);

% calculateCalibration(C,path_calibracion)

load([path_calibracion 'calibration.mat']);
load([path_radio 'intersecciones.mat']); % genial elección de nombres

% me aseguro de descartar los puntos que escapan a las zonas calibradas
close all

boundaries_pixel = {{[], []}, {[], []}}; % x1, y1, x2, y2
for q = 1:2
    
    ind1=C{q}(:,6)>.4;
	ind2=C{q}(:,8)>.4;
	ind3=C{q}(:,7)<100;
	ind4=C{q}(:,9)<100;
    
    ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
    
    validos_x = C{q}(ind1, 1);
    validos_y = C{q}(ind1, 2);
    
    j = boundary(validos_x, validos_y);
    boundary_x = validos_x(j);
    boundary_y = validos_y(j);
    
    boundaries_pixel{q}{1} = boundary_x;
    boundaries_pixel{q}{2} = boundary_y;

end

save(fullfile(path_datos, 'boundaries_pixel'),'boundaries_pixel')

load([path_radio 'intersecciones.mat']);
load([path_datos 'boundaries_pixel.mat']);
load([path_calibracion 'calibration.mat']);
load([path_offset 'offset.mat']);

% lo voy a hacer todo en loop
pxVsMm = {NaN(size(intersecciones{1}, 1), 4), NaN(size(intersecciones{2}, 1), 4)};
ind2 = {[], []};

for q = 1:2
    pxVsMm{q}(:, 1:2) = intersecciones{q};
    % convierto a mm
    px = intersecciones{q}(:, 1);
    py = 1088 - intersecciones{q}(:, 2);
    
    % me quedo sólo con los válidos
    ind2{q} = inpolygon(px, py, boundaries_pixel{q}{1}, boundaries_pixel{q}{2});
    
    % lo que hago es acá guardar todos, y seleccionar los válidos en la
    % celda siguiente. Podría directamente seleccionar antes de guardar
    x = polyval4XY(px2mmPol{q}(1), px, py);
    y = polyval4XY(px2mmPol{q}(2), px, py);
    
    pxVsMm{q}(:, 3:4) = [x,y];
end

set(0,'DefaultFigureVisible', 'on')

delta_x = offset(1);
delta_y = offset(2);

boundaries_mm = {[polyval4XY(px2mmPol{1}(1), boundaries_pixel{1}{1}, boundaries_pixel{1}{2}), polyval4XY(px2mmPol{1}(2), boundaries_pixel{1}{1}, boundaries_pixel{1}{2})], [polyval4XY(px2mmPol{2}(1), boundaries_pixel{2}{1}, boundaries_pixel{2}{2}) - delta_x, polyval4XY(px2mmPol{2}(2), boundaries_pixel{2}{1}, boundaries_pixel{2}{2}) - delta_y]};

figure,hold on,grid on
plot(boundaries_mm{1}(:, 1), boundaries_mm{1}(:, 2), '--b')
plot(boundaries_mm{q}(:, 1), boundaries_mm{q}(:, 2), '--r')

axis equal



close all
figure
hold on
grid on

plot(pxVsMm{1}(:, 3), pxVsMm{1}(:, 4), '.c')
plot(pxVsMm{1}(ind2{1}, 3), pxVsMm{1}((ind2{1}), 4), '.b')
plot(pxVsMm{2}(:, 3) - delta_x, pxVsMm{2}(:, 4) - delta_y, '.m')
plot(pxVsMm{2}(ind2{2}, 3) - delta_x, pxVsMm{2}(ind2{2}, 4) - delta_y, '.r')
plot(boundaries_mm{1}(:, 1), boundaries_mm{1}(:, 2), '--b')
plot(boundaries_mm{2}(:, 1), boundaries_mm{2}(:, 2), '--r')

margen=5;

axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
xlim([min(pxVsMm{2}(:, 3)) - delta_x - margen max(pxVsMm{1}(:, 3)) + margen])
ylim([min(pxVsMm{2}(:, 4)) - delta_y - margen max(pxVsMm{1}(:, 4)) + margen])

% save(fullfile(path_radio, 'pxVsMm'),'pxVsMm')

% promediar cada nube de puntos

% CORRER LA CELDA ANTERIOR

x_avg = {[], []};
y_avg = {[], []};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cámara 1
q = 1;
    
x = pxVsMm{q}(ind2{q}, 3);
y = pxVsMm{q}((ind2{q}), 4);

close all
figure
hold on
grid on

plot(pxVsMm{q}(:, 3), pxVsMm{q}(:, 4), '.c')
plot(x, y, '.b')

% cantidad de esquinas válidas. Esto se usa para seleccionar todos los
% puntos que corresponden a una esquina
t = 8;

% loop sobre las esquinas
% esto es válido para los radios 1:5
for k = 1:t
    x_avg{q}(k) = mean(x(k:t:end-k));
    y_avg{q}(k) = mean(y(k:t:end-k));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cámara 2
q = 2;
    
x = pxVsMm{q}(ind2{q}, 3)- delta_x;
y = pxVsMm{q}((ind2{q}), 4)- delta_y;

% close all, figure, hold on
plot(pxVsMm{q}(:, 3) - delta_x, pxVsMm{q}(:, 4) - delta_y, '.m')
plot(x, y, '.r')

% cantidad de esquinas válidas. Esto se usa para seleccionar todos los
% puntos que corresponden a una esquina
t = 9;

% loop sobre las esquinas
for k = 1:t
    u = x(k:t:end-k);
    v = y(k:t:end-k);
    
    x_avg{q}(k) = mean(u);
    y_avg{q}(k) = mean(v);
end

% descarto puntos donde no se haya detectado la punta
u = u(~isnan(u));
v = v(~isnan(v));

plot(x_avg{1}, y_avg{1}, '+b')
plot(x_avg{2}, y_avg{2}, '+r')
plot(boundaries_mm{1}(:, 1), boundaries_mm{1}(:, 2), '--b')
plot(boundaries_mm{2}(:, 1), boundaries_mm{2}(:, 2), '--r')

axis equal
xlim([min(pxVsMm{2}(:, 3)) - delta_x - margen max(pxVsMm{1}(:, 3)) + margen])
ylim([min(pxVsMm{2}(:, 4)) - delta_y - margen max(pxVsMm{1}(:, 4)) + margen])
xlabel('X (mm)')
ylabel('Y (mm)')
title(sprintf('Promedio de las esquinas Radio %d', corona))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculo los errores entre los puntos comunes
% los puntos son:
% de la cámara 1: 1:3
% de la cámara 2: 7:9

x_avg = {x_avg{1}.', x_avg{2}.'};
y_avg = {y_avg{1}.', y_avg{2}.'};

% % para radios 1:5
error_x = (x_avg{1}(1:3) - x_avg{2}(7:9));
error_y = (y_avg{1}(1:3) - y_avg{2}(7:9));

% para radio 6
% error_x = x_avg{1}(1:2) - x_avg{2}(8:9);
% error_y = y_avg{1}(1:2) - y_avg{2}(8:9);

fprintf('Radio %d\n', corona)
fprintf('Error en X: %.0f +- %.0f um\n', 1e3*mean(error_x), 1e3*std(error_x))
fprintf('Error en Y: %.0f +- %.0f um\n', 1e3*mean(error_y), 1e3*std(error_y))

% guardo las posiciones de las esquinas. Tengo en cuenta el caso R6 aparte
% no me interesa distinguir entre cámaras, sino que quiero determinar las
% posiciones
comunes_x = (x_avg{1}(1:3) + x_avg{2}(7:9))/2;
comunes_y = (y_avg{1}(1:3) + y_avg{2}(7:9))/2;
esquinas = [[x_avg{2}(1:6), y_avg{2}(1:6)]; [comunes_x, comunes_y]; [x_avg{1}(4:8), y_avg{1}(4:8)]];

plot(esquinas(:, 1), esquinas(:, 2), '+g')

% if corona == 6
%     esquinas = [[x_avg{2}(1:6), y_avg{2}(1:6)]; [comunes_x, comunes_y]; [x_avg{1}(4:8), y_avg{1}(4:8)]];
% else
%     esquinas = [[x_avg{2}(1:6), y_avg{2}(1:6)]; [comunes_x, comunes_y]; [x_avg{1}(4:9), y_avg{1}(4:9)]];
% end

save(fullfile(path_datos, sprintf('esquinas_radio_%d', corona)),'esquinas')