function c_minimos_al_reves(C,basepath)

for q=1:2
	f5=figure;plot(C{q}(:,1),C{q}(:,2),'.'),hold all,title(sprintf('Camera %d',q))
	ind1=C{q}(:,6)>.4;plot(C{q}(ind1,1),C{q}(ind1,2),'o','MarkerSize',8)
	ind2=C{q}(:,8)>.4;plot(C{q}(ind2,1),C{q}(ind2,2),'+','MarkerSize',10)
	ind3=C{q}(:,7)<100;plot(C{q}(ind3,1),C{q}(ind3,2),'x','MarkerSize',10)
	ind4=C{q}(:,9)<100;plot(C{q}(ind4,1),C{q}(ind4,2),'s','MarkerSize',12)
	legend('all intersections', 'estd1>0.4', 'estd2>0.4', 'n1<100', 'n2<100')
	
	ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
	% ind1=~isnan(C{1}(:,1));
	Xmm=C{q}(ind1,3);
	Ymm=C{q}(ind1,4);
	Xpx=C{q}(ind1,1);
    Ypx=C{q}(ind1,2);
	px2mmPol{q}(1)=polyfit4XY(Xpx,Ypx,Xmm);
	Xmmfit=polyval4XY(px2mmPol{q}(1),Xpx,Ypx);
	% figure,plot3(X,Y,Xfit,'.'),hold all,plot3(X,Y,Xraw,'.')
%     saveas(f5, [basepath 'figuras_al_reves/f5_cam_' num2str(q) '.png'])
    
% 	f4=figure;
% 	subplot(211),plot3(Xmm,Ymm,Xmm-Xmmfit,'.'),title({sprintf('X camera %d',q),sprintf('std=%f px',std(Xmm(px2mmPol{q}(1).ind)-Xmmfit(px2mmPol{q}(1).ind)))}), xlabel('X [mm]'), ylabel('Y [mm]'),zlabel('Xraw-Xfit [px]')

	
	px2mmPol{q}(2)=polyfit4XY(Xpx,Ypx,Ymm);
	Ymmfit=polyval4XY(px2mmPol{q}(2),Xpx,Ypx);
	% figure,plot3(X,Y,Yfit,'.'),hold all,plot3(X,Y,Yraw,'.')
% 	subplot(212),plot3(Xmm,Ymm,Ymm-Ymmfit,'.'),title({sprintf('Y camera %d',q),sprintf('std=%f px',std(Ymm(px2mmPol{q}(2).ind)-Ymmfit(px2mmPol{q}(2).ind)))}), xlabel('X [mm]'), ylabel('Y [mm]'),zlabel('Yraw-Yfit [px]')
%     saveas(f4, [basepath 'figuras_al_reves/f4_cam_' num2str(q) '.png'])

% 	%% Invertir la calibración para poder calcular x,y reales a partir de pixels.
% 	ind=mm2pxPol{q}(1).ind & mm2pxPol{q}(2).ind;
% 	Xpxfit1=Xpxfit(ind);
% 	Ypxfit1=Ypxfit(ind);
% 	px2mmPol{q}(1)=polyfit4XY(Xpxfit1,Ypxfit1,Xmm(ind));
% %	Xmmfit=polyval4XY(px2mmPol{q}(1),Xpxfit1,Ypxfit1);
% 	Xmmfit=polyval4XY(px2mmPol{q}(1),Xpx(ind),Ypx(ind)); % Error total de la calibraci�n, comparando con los valores medidos, no los utilizados en el ajuste de "inversi�n"
% 	Xr=Xmm(ind);
    
	f3=figure;
	subplot(211),plot3(Xpx,Ypx,Xmm-Xmmfit,'.'),title({sprintf('\\DeltaX_{mm} camera %d',q), sprintf('std=%f mm',std(Xmm(px2mmPol{q}(1).ind)-Xmmfit(px2mmPol{q}(1).ind)))})
	xlabel('X [px]'), ylabel('Y [px]'),zlabel('Xmm-Xfit [mm]')
% 	
% 	px2mmPol{q}(2)=polyfit4XY(Xpxfit1,Ypxfit1,Ymm(ind));
% %	Ymmfit=polyval4XY(px2mmPol{q}(2),Xpxfit1,Ypxfit1);
% 	Ypxfit=polyval4XY(px2mmPol{q}(2),Xpx(ind),Ypx(ind)); % Error total de la calibraci�n, comparando con los valores medidos, no los utilizados en el ajuste de "inversi�n"
% 	Yr=Ymm(ind);
	subplot(212),plot3(Xpx,Ypx,Ymm-Ymmfit,'.'),title({sprintf('\\DeltaY_{mm} camera %d',q), sprintf('std=%f mm',std(Ymm(px2mmPol{q}(2).ind)-Ymmfit(px2mmPol{q}(2).ind)))})
	xlabel('X [px]'), ylabel('Y [px]'),zlabel('Ymm-Yfit [mm]')
    saveas(f3, [basepath 'figuras_al_reves/f3_cam_' num2str(q) '.png'])
% 	
% 	f2 = figure;
% 	ax1=subplot(211);plot(Xr-Xmmfit),title(sprintf('\\DeltaX_{mm} camera %d',q))
% 	ax2=subplot(212);plot(Yr-Ypxfit),title(sprintf('\\DeltaY_{mm} camera %d',q))
% 	linkaxes([ax1 ax2],'x')
%     saveas(f2, [basepath 'figuras_al_reves/deltas_cam_' num2str(q) '.png'])
% 	
% 	f1 = figure;
% 	subplot(211),plot(C{q}(:,3),C{q}(:,4),'.'),hold all
% 	plot(Xmm(px2mmPol{q}(1).ind),Ymm(px2mmPol{q}(1).ind),'o'),title(sprintf('Used points for fitting X camera %d',q))
% 	set(gca,'YDir','reverse')
% 	subplot(212),plot(C{q}(:,3),C{q}(:,4),'.'),hold all
% 	plot(Xmm(px2mmPol{q}(2).ind),Ymm(px2mmPol{q}(2).ind),'o'),title(sprintf('Used points for fitting Y camera %d',q))
% 	set(gca,'YDir','reverse')
%     saveas(f1, [basepath 'figuras_al_reves/used_points_cam_' num2str(q) '.png'])

end

% save(fullfile(basepath,'calibration.mat'),'px2mmPol')

end