function [xguess,mi,shift]=guessNextCorner(Profiles,C,knext,xc,Xnext,Ynext)
%% Estimar la posición de la intersección en el punto Xnext, Ynext.
ind=~isnan(C(:,3));
CC=C(ind,:);
ncorner=sum(ind);
if ncorner>10 % Si hay al menos 10 intersecciones encontradas, las utiliza para estimar la siguiente intersección con un ajuste 2D.
% 	x=C(knext,3);
% 	y=C(knext,4);
	[~,ind1]=sort((CC(:,3)-Xnext).^2+(CC(:,4)-Ynext).^2);
	Xc=CC(ind1(1:min(ncorner,100)),1);
	X=CC(ind1(1:min(ncorner,100)),3);
	Y=CC(ind1(1:min(ncorner,100)),4);
	coef=polyfit2XY(X,Y,Xc);	% Esto se podría hacer menos veces, por ejemplo en coronas circulares.
	xguess=round([1 Xnext Xnext^2 Ynext Ynext^2 Xnext*Ynext]*coef);
	shift=round(xguess-xc);
	mi=NaN;
else % Si NO hay al menos 10 intersecciones encontradas, utiliza la más cercana y hace la "correlación".
	[~,ind1]=min((CC(:,3)-Xnext).^2+(CC(:,4)-Ynext).^2); %Buscar el punto más cercano para usar en la "correlacion".
	[mi,~,shift]=findShiftBetweenSignals(Profiles,CC(ind1(1),1),CC(ind1(1),5),knext);
	xguess=round(CC(ind1(1),1)+shift);
end
end

% % figuras para el informe
% % Xc son los X de las esquinas (en pixels)
% % X,Y son las coordenadas del barrido (en mm)
% % EL TIPO SOLO NECESITA AJUSTAR Xc
% 
% [XX, YY] = meshgrid(X,Y);
% XX = reshape(XX, [121,1]);
% YY = reshape(YY, [121,1]);
% pol = [ones(121,1) XX XX.^2 YY YY.^2 XX.*YY]*coef;
% 
% XX = reshape(XX, [11,11]);
% YY = reshape(YY, [11,11]);
% pol = reshape(pol, [11,11]);
% 
% close all
% f=figure; hold on, grid on
% 
% plot3(X,Y,Xc,'*r')
% surf(XX,YY,pol, 'FaceAlpha', 0.75)
% plot3(Xnext,Ynext,xguess,'*b')
% 
% xlabel('X (mm)')
% ylabel('Y (mm)')
% zlabel('X (pixels)')
% view([49,24])
% legend('Esquinas ya encontradas', 'Ajuste', 'Estimación próxima esquina', 'Location', 'Best')
% 
% % saveas(f, 'C:\Users\Norma\Downloads\imagenes tesis\guess next corner\ajuste_mas_de_10.png')