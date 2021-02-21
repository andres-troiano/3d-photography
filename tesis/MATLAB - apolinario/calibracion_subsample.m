function calibracion_subsample(C, R, basepath, paso)
% Calcular ajustes para ir desde mm a px para la cámara 1


for q=1:2
    
    %figure,plot(C{q}(:,1),C{q}(:,2),'.'),hold all,title(sprintf('Camera %d',q))
	ind1=C{q}(:,6)>.4;%plot(C{q}(ind1,1),C{q}(ind1,2),'o','MarkerSize',8)
	ind2=C{q}(:,8)>.4;%plot(C{q}(ind2,1),C{q}(ind2,2),'+','MarkerSize',10)
	ind3=C{q}(:,7)<100;%plot(C{q}(ind3,1),C{q}(ind3,2),'x','MarkerSize',10)
	ind4=C{q}(:,9)<100;%plot(C{q}(ind4,1),C{q}(ind4,2),'s','MarkerSize',12)
	%legend('all intersections', 'estd1>0.4', 'estd2>0.4', 'n1<100', 'n2<100')
	
    % agrego la condicion de que esté adentro de la rosca
    % radios interno y externo
    % tengo que trasladar los boundaries con la cámara 2, en el sentido
    % inverso al que trasladaría los puntos
    
    delta_x = 51.763;
    delta_y = 30.463;
    
    % defino una rosca trasladada
    R_t = [R(:, 1) + delta_x, R(:, 2) + delta_y, R(:, 3) + delta_x, R(:, 4) + delta_y];
    
    ind5 = ~inpolygon(C{q}(:,3), C{q}(:,4), R(:, 1), R(:, 2));
    ind6 = inpolygon(C{q}(:,3), C{q}(:,4), R(:, 3), R(:, 4));
    
    if q == 2
        ind5 = ~inpolygon(C{q}(:,3), C{q}(:,4), R_t(:, 1), R_t(:, 2));
        ind6 = inpolygon(C{q}(:,3), C{q}(:,4), R_t(:, 3), R_t(:, 4));
    end
    
    ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1)) & ind5 & ind6;
    ind_originales = ind1;
    
    % creo que acá tendría que tirar los puntos con x<100
    ind_originales = ind1 & C{q}(:,3) >= 100; 
    
	% ind1=~isnan(C{1}(:,1));
	Xmm=C{q}(ind1,3);
	Ymm=C{q}(ind1,4);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     close all
%     figure
%     hold on
%     grid on
%     
%     plot(Xmm, Ymm, '.b')
    
    % subsampleo
    x_min = min(Xmm);
    x_max = max(Xmm);
    y_min = min(Ymm);
    y_max = max(Ymm);
    
%     paso = 50;
    X_ss = x_min:paso:x_max;
    Y_ss = y_min:paso:y_max;
    
    [X_ss, Y_ss] = meshgrid(X_ss, Y_ss);
    X_ss = reshape(X_ss, [1, numel(X_ss)]);
    Y_ss = reshape(Y_ss, [1, numel(Y_ss)]);
    
%     plot(X_ss, Y_ss, 'or')
    
    % de los xy subsampleados, filtro aquellos que están dentro de la
    % máscara
    filtro_1 = ~inpolygon(X_ss, Y_ss, R(:, 1), R(:, 2));
    filtro_2 = inpolygon(X_ss, Y_ss, R(:, 3), R(:, 4));
    
    if q == 2
        filtro_1 = ~inpolygon(X_ss, Y_ss, R_t(:, 1), R_t(:, 2));
        filtro_2 = inpolygon(X_ss, Y_ss, R_t(:, 3), R_t(:, 4));
    end
    
    % ME FALTA LA MÁSCARA DE LOS PUNTOS ORIGINALES
    j = boundary(Xmm, Ymm, 0.1);

    x_bound = Xmm(j);
    y_bound = Ymm(j);
    
    filtro_3 = inpolygon(X_ss, Y_ss, x_bound, y_bound);
    
    filtro = filtro_1 & filtro_2 & filtro_3;

%     plot(X_ss(filtro), Y_ss(filtro), 'or')
%     
%     axis equal

    X_ss = X_ss(filtro);
    Y_ss = Y_ss(filtro);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ind2 = zeros(numel(C{q}(:,3)), 1);
    for i = 1:numel(C{q}(:,3))
        for j = 1:numel(X_ss)
            igualdad = C{q}(i,3) == X_ss(j) & C{q}(i,4) == Y_ss(j);
            if igualdad == 1
                ind2(i) = 1;
            end
        end
    end
    
    ind1 = ind1 & ind2;

    % redefino x,y
    Xmm=C{q}(ind1,3);
	Ymm=C{q}(ind1,4);
    
    % tiro algunos puntos de la cámara 1 para empatar con la 2
    if q == 1
        ind2 = zeros(numel(C{q}(:,3)), 1);
        for i = 1:numel(C{q}(:,3))
            if C{q}(i,3) >= 100
                ind2(i) = 1;
            end
        end
        ind1 = ind1 & ind2;
        % redefino x,y
        Xmm=C{q}(ind1,3);
        Ymm=C{q}(ind1,4);
    end
    
	Xpx=C{q}(ind1,1);
	mm2pxPol{q}(1)=polyfit4XY(Xmm,Ymm,Xpx);
	Xpxfit=polyval4XY(mm2pxPol{q}(1),Xmm,Ymm);
	% figure,plot3(X,Y,Xfit,'.'),hold all,plot3(X,Y,Xraw,'.')
% 	figure
% 	subplot(211),plot3(Xmm,Ymm,Xpx-Xpxfit,'.'),title({sprintf('X camera %d',q),sprintf('std=%f px',std(Xpx(mm2pxPol{q}(1).ind)-Xpxfit(mm2pxPol{q}(1).ind)))}), xlabel('X [mm]'), ylabel('Y [mm]'),zlabel('Xraw-Xfit [px]')

	Ypx=C{q}(ind1,2);
	mm2pxPol{q}(2)=polyfit4XY(Xmm,Ymm,Ypx);
	Ypxfit=polyval4XY(mm2pxPol{q}(2),Xmm,Ymm);
	% figure,plot3(X,Y,Yfit,'.'),hold all,plot3(X,Y,Yraw,'.')
% 	subplot(212),plot3(Xmm,Ymm,Ypx-Ypxfit,'.'),title({sprintf('Y camera %d',q),sprintf('std=%f px',std(Ypx(mm2pxPol{q}(2).ind)-Ypxfit(mm2pxPol{q}(2).ind)))}), xlabel('X [mm]'), ylabel('Y [mm]'),zlabel('Yraw-Yfit [px]')
	

	%% Invertir la calibración para poder calcular x,y reales a partir de pixels.
	ind=mm2pxPol{q}(1).ind & mm2pxPol{q}(2).ind;
	Xpxfit1=Xpxfit(ind);
	Ypxfit1=Ypxfit(ind);
	px2mmPol{q}(1)=polyfit4XY(Xpxfit1,Ypxfit1,Xmm(ind));
%	Xmmfit=polyval4XY(px2mmPol{q}(1),Xpxfit1,Ypxfit1);
	Xmmfit=polyval4XY(px2mmPol{q}(1),Xpx(ind),Ypx(ind)); % Error total de la calibración, comparando con los valores medidos, no los utilizados en el ajuste de "inversión"
	Xr=Xmm(ind);
    
% 	figure
% 	subplot(211),plot3(Xpxfit1,Ypxfit1,Xr-Xmmfit,'.'),title({sprintf('\\DeltaX_{mm} camera %d',q), sprintf('std=%f mm',std(Xr(px2mmPol{q}(1).ind)-Xmmfit(px2mmPol{q}(1).ind)))})
% 	xlabel('X [px]'), ylabel('Y [px]'),zlabel('Xmm-Xfit [mm]')
	
	px2mmPol{q}(2)=polyfit4XY(Xpxfit1,Ypxfit1,Ymm(ind));
%	Ymmfit=polyval4XY(px2mmPol{q}(2),Xpxfit1,Ypxfit1);
	Ymmfit=polyval4XY(px2mmPol{q}(2),Xpx(ind),Ypx(ind)); % Error total de la calibración, comparando con los valores medidos, no los utilizados en el ajuste de "inversión"
	Yr=Ymm(ind);
% 	subplot(212),plot3(Xpxfit1,Ypxfit1,Yr-Ymmfit,'.'),title({sprintf('\\DeltaY_{mm} camera %d',q), sprintf('std=%f mm',std(Yr(px2mmPol{q}(2).ind)-Ymmfit(px2mmPol{q}(2).ind)))})
% 	xlabel('X [px]'), ylabel('Y [px]'),zlabel('Ymm-Yfit [mm]')
	
% 	figure
% 	ax1=subplot(211);plot(Xr-Xmmfit),title(sprintf('\\DeltaX_{mm} camera %d',q))
% 	ax2=subplot(212);plot(Yr-Ymmfit),title(sprintf('\\DeltaY_{mm} camera %d',q))
% 	linkaxes([ax1 ax2],'x')
	
	figure
	subplot(211),plot(C{q}(:,3),C{q}(:,4),'.'),hold all
	plot(Xmm(px2mmPol{q}(1).ind),Ymm(px2mmPol{q}(1).ind),'o'),title(sprintf('Used points for fitting X camera %d',q))
	set(gca,'YDir','reverse')
	subplot(212),plot(C{q}(:,3),C{q}(:,4),'.'),hold all
	plot(Xmm(px2mmPol{q}(2).ind),Ymm(px2mmPol{q}(2).ind),'o'),title(sprintf('Used points for fitting Y camera %d',q))
	set(gca,'YDir','reverse')
    
%     numel(Xmm(px2mmPol{q}(2).ind))
    
    % puntos usados para x
    A = [Xmm(px2mmPol{q}(1).ind), Ymm(px2mmPol{q}(1).ind)];
    % puntos usados para y
    B = [Xmm(px2mmPol{q}(2).ind), Ymm(px2mmPol{q}(2).ind)];

    % puntos usados para cada cámara
    M{q} = union(A, B, 'rows');
    fprintf('Cantidad de puntos usados CAM%d = %d\n', q, size(M{q}, 1));
    
    % calculo el error de calibración en TODOS LOS PUNTOS VÁLIDOS
    % selecciono los xy válidos (por el índice)
    % los transformo a pixels
    % comparo el resultado con los pixels seleccionados por esos mismos
    % índices
    
    % pixels validos
    % los puntos buenos son los dados por el ind1 original
    px_originales = C{q}(ind_originales, 1);
    py_originales = C{q}(ind_originales, 2);
    % contra éstos voy a comparar
    x_originales = C{q}(ind_originales, 3);
    y_originales = C{q}(ind_originales, 4);
    % los transformo con el polinomio
    x_transformados = polyval4XY(px2mmPol{q}(1), px_originales, py_originales);
    y_transformados = polyval4XY(px2mmPol{q}(2), px_originales, py_originales);
    
    error_x = x_transformados - x_originales;
    error_y = y_transformados - y_originales;
    fprintf('Error X CAM%d = %.0f um\nError Y CAM%d = %.0f um\n', q, 1e3*std(error_x), q, 1e3*std(error_y));

end
fprintf('\n');
save(fullfile(basepath,'calibracion_subsample.mat'),'px2mmPol')

end