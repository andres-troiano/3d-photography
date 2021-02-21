% variación del script anterior, donde en este caso recorro todas las
% esquinas de izq a der.

clear variables

basepath='C:\Users\60069978\Documents\MATLAB\medicion35\';
filename={'PerfilesCoronaCamara1.mat','PerfilesCoronaCamara2.mat'};

close all
n0=20;
%valores con los que selecciono el pedacito donde ajusto
rango = 15;
margen=6;

% qué dimensiones tiene que tener esto?
% una celda por cada cámara, una celda por cada perfil
% LL={cell(1,6),cell(1,6)};
valores_iniciales = [[790, 775, 754, 736, 711, 687]; [830, 809, 787, 769, 751, 730]];
for q=2
    % inicializo el array de rectas. Asumo que no voy a tener más de 10.
    % Siempre tengo 2 parámetros
    fd=filename{q};
	load(fullfile(basepath,fd));
%     for k = 1:size(Profiles,2)

    % hago otro for, sobre las esquinas de un mismo radio
    N = 10; % cantidad de esquinas que voy a detectar
    R = nan(2,2*N);

    % recorro perfiles
    for k = 1
        % itero sobre los sentidos derecho e izquierdo
        % derecho = 0, izq = 1
        l=0; % este índice se mueve por todas las puntas de un perfil
            
        x=(1:size(Profiles,1))';
        y=Profiles(:,k);
        set(0,'DefaultFigureVisible', 'on');
        
        p = valores_iniciales(q,k);

%         nfig=figure(2);plot(x,y,'.-'),hold all,grid on,axis equal
%         try
%             p=ginput(1);
%         catch E
%         end
%         close(gcf)
%         xguess = round(p(1));
        
        [x_lim, y_lim] = tiro_datos_nulos_perfil(x, y);
        
        for sentido = 0
            xguess=round(p(1));
            for j=1:N
                l=l+1;
                fprintf('Cámara %d, perfil %d, sentido %d, esquina %d, valor inicial %.3f\n', q, k, sentido, l, round(p(1)))
                % dado el xguess, ajusto la recta a la derecha
                if sentido == 0
                    ind=(xguess:xguess+20-margen)';
                end
                if sentido == 1
                    ind=(xguess-rango-margen:xguess-margen)'; % dejo un margen para no ajustar sobre la punta
                end
                
                if ind(end)>2048
                    fprintf('  ### DESCARTADO por llegar al extremo\n')
                    figure,plot(Profiles(:,k),'.-')
                    continue
                end
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

                h=figure(1);hold on,plot(x, y, '.-b'),plot(x_recta,y_recta,'.r'),tit=sprintf('Camara %d, Radio %d', q, radio(k));title(tit),xlabel('Pixel X'),ylabel('Pixel Y'),grid on,axis equal
                xlim([min(x_lim) max(x_lim)]),ylim([min(y_lim) max(y_lim)])
                plot(xguess, y(xguess), '*y')
                plot(x(ind), y(ind), '.g')
                saveas(h, fullfile(basepath, sprintf('graficos\\Camara%d_Perfil%d', q, radio(k))), 'png')

                % dentro de un mismo radio, voy guardando todas las rectas en
                % una estructura
                R(:,l)=L;
            end
        end
        save(fullfile(basepath, sprintf('rectas_camara%d_perfil%d', q, k)),'R')
        
        % para cada radio, guardo las coords x,y de todas las
        % intersecciones encontradas
%         LL{q,k} = R;
    end
    
    close all
end

% plot(x(ind), y(ind), '.m')

%%

clear variables
basepath='C:\Users\60069978\Documents\MATLAB\medicion35\';
filename={'PerfilesCoronaCamara1.mat','PerfilesCoronaCamara2.mat'};

% load(fullfile(basepath,'PerfilesCoronaCamara1.mat'));
% load(fullfile(basepath,'intersecciones_corona.mat'));

% necesito una por cámara, con los 6 perfiles
% por cada perfil tengo 9 puntos
% pongo un perfil a continuación del anterior
intersecciones = {NaN(9*6,2), NaN(9*6,2)};

set(0,'DefaultFigureVisible', 'off')

% camara
for q=1:2
    
    close all
    h=figure;
    hold on
    grid on

    % perfil
    load(fullfile(basepath,sprintf('PerfilesCoronaCamara%d.mat',q)));
    for k=1:6
        
        load(fullfile(basepath, sprintf('rectas_camara%d_perfil%d.mat', q, k)))

        x=(1:size(Profiles,1))';
        y=Profiles(:,k);
        [x_lim, y_lim] = tiro_datos_nulos_perfil(x, y);
        [x_lim,y_lim] = FiltroMedianaCompleto(x_lim,y_lim,3);

        % perfil
        plot(x, y, '.-b')

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
%     saveas(h, fullfile(basepath, sprintf('esquinas\\EsquinasCamara%d', q)), 'png')
end

save(fullfile(basepath, 'intersecciones'),'intersecciones')

%%

clear variables

% dadas las esquinas que encontré, convierto a mm con mi calibración hecha
% con los stages

path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion32\';
path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion35\';
load([path_calibracion 'intersections.mat']);

% calculateCalibration(C,path_calibracion)

load([path_calibracion 'calibration.mat']);
load([path_datos 'intersecciones.mat']); % genial elección de nombres

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
    
    figure
    hold on
    grid on
    
    plot(C{q}(:, 1), C{q}(:, 2), '.')
%     plot(C{q}(ind1, 1), C{q}(ind1, 2), 'o')
%     plot(C{q}(j, 1), C{q}(j, 2), '-g')
    plot(validos_x, validos_y, 'o')
    plot(boundary_x, boundary_y, '-g')

end

%%

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
    
    x = polyval4XY(px2mmPol{q}(1), px, py);
    y = polyval4XY(px2mmPol{q}(2), px, py);
    
    pxVsMm{q}(:, 3:4) = [x,y];
end



set(0,'DefaultFigureVisible', 'on')

delta_x = 51.763;
delta_y = 30.463;

boundaries_mm = {{polyval4XY(px2mmPol{1}(1), boundaries_pixel{1}{1}, boundaries_pixel{1}{2}), polyval4XY(px2mmPol{1}(2), boundaries_pixel{1}{1}, boundaries_pixel{1}{2})}, {polyval4XY(px2mmPol{2}(1), boundaries_pixel{2}{1}, boundaries_pixel{2}{2}) - delta_x, polyval4XY(px2mmPol{2}(2), boundaries_pixel{2}{1}, boundaries_pixel{2}{2}) - delta_y}};

close all
figure
hold on
grid on

% plot(pxVsMm{1}(:, 3), pxVsMm{1}(:, 4), '.b')
plot(pxVsMm{1}(ind2{1}, 3), pxVsMm{1}((ind2{1}), 4), '.b')
% plot(pxVsMm{2}(:, 3) - delta_x, pxVsMm{2}(:, 4) - delta_y, '.r')
plot(pxVsMm{2}(ind2{2}, 3) - delta_x, pxVsMm{2}(ind2{2}, 4) - delta_y, '.r')
plot(boundaries_mm{1}{1}, boundaries_mm{1}{2}, '--b')
plot(boundaries_mm{2}{1}, boundaries_mm{2}{2}, '--r')

margen=5;

axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
xlim([min(pxVsMm{2}(:, 3)) - delta_x - margen max(pxVsMm{1}(:, 3)) + margen])
ylim([min(pxVsMm{2}(:, 4)) - delta_y - margen max(pxVsMm{1}(:, 4)) + margen])