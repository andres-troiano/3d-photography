% Script para calcular intersecciones de dos rectas en cada perfil
% Se empieza con un perfil en piosición promedio. El usuario selecciona la
% posición aproximada de la intersección. A partir de ahí el algoritmo va
% buscando en los perfiles más cercanos las intersecciones. Primero
% haciendo correlaciones hasta encontrar suficientes y luego estimando a
% partir de las ya encontradas.

basepath='C:\Users\60069978\Documents\MATLAB\medicion38\';
% basepath='C:\Users\60069978\Documents\MATLAB\alineacion_trapecio\longitud_trapecio\';
foldername={'camara_1.mat','camara_2.mat'};

C={[],[]};
for q=1:2
	fd=foldername{q};
	load(fullfile(basepath,fd));
	Profiles=1088-Profiles;
	% Encontrar un perfil "bueno"
	Xm=median(X); % Tal vez deberían ser valores definidos a mano.
	Ym=median(Y);
    
    % corrijo el cálculo de las medianas cuando hay número impar de
    % elementos
    distancias = abs(X - Xm);
    closest = X(find(distancias == min(abs(Xm - X))));
    Xm = closest(1);
    
    distancias = abs(Y - Ym);
    closest = Y(find(distancias == min(abs(Ym - Y))));
    Ym = closest(1);
    
    % ojo!
%     Xm = 150;
%     Ym = 500;
    
    
%     if q==2
%         Xm = 150;
%     end
    
%     [Xm, Ym]
    
	km=find(X==Xm & Y==Ym);
	% Monstrar al usuario la figure para que elija la posición aproximada de la intersección. 
	nfig=figure();plot(Profiles(:,km)),hold all,title({sprintf('x=%d, y=%d',X(km),Y(km)),'Elija la intersección aproximada o cierre la ventana'})
	try
		p=ginput(1);
	catch E
	end
	close(nfig)
	% Ordenar los perfiles en función de su distancia a la posición del perfil definido arriba.
	[~,ind]=sort((X-Xm).^2+(Y-Ym).^2);
	%%
	clc
	C{q}=nan(size(X,1),9); %xc,yc,X,Y,k,estd1,n1,estd2,n2
	xguess=round(p(1));
	o=0;
	show=false;
	if show==true
		nfig=figure();hold on
		plot(X(km),Y(km),'xr'),xlim([min(X) max(X)]),ylim([min(Y) max(Y)])
	end
	for k=ind'
		if show==true
			figure(nfig),plot(X(k),Y(k),'xr'),
		end
		o=o+1;
		fprintf('Perfil %d, X=%d, Y=%d',o,X(k),Y(k))
		ind1=(xguess-40:xguess)';
		x=(1:size(Profiles,1))';
		y=Profiles(:,k);
		[L1,estd1,n1]=fitStraightLine(x,y,ind1);
		fprintf(', std1=%.2f, n1=%d',estd1,n1)
		if isempty(L1) || n1<30 || estd1>1.5
%			figure,plot(Profiles(:,k),'.-'),title(sprintf('o=%d, error en L1 ',o))
			if o<length(X)
				[xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
				fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
			end
			fprintf('  ### DESCARTADO por mal ajuste L1 ###\n')
			continue
		end
		ind1=(xguess:xguess+40)';
		if ind1(end)>2048
			if o<length(X)
				[xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
				fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
			end
			fprintf('  ### DESCARTADO por llegar al extremo\n')
			figure,plot(Profiles(:,k),'.-')
			continue
		end
		[L2,estd2,n2]=fitStraightLine(x,y,ind1);
		fprintf(', std2=%.2f, n2=%d',estd2,n2)
		if isempty(L2) || n2<30 || estd2>1.5
%			figure,plot(Profiles(:,k),'.-'),title(sprintf('o=%d, error en L2 ',o))
			if o<length(X)
				[xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
				fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
			end
			fprintf('  ### DESCARTADO por mal ajuste L2 ###\n')
			continue
		end
%		figure,plot(Profiles(:,k),'.-'),hold all,plot(1:1000,polyval(L1,1:1000),'-'),plot(1:1000,polyval(L2,1:1000),'o')
		U1=[L1(1) -1 L1(2)];
		U2=[L2(1) -1 L2(2)];
		P=cross(U1,U2);
% 		if P(3)==0
        PP(o, 1:3) = P;
        if abs(P(3))<0.01
			if o<length(X)
				[xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
				fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
			end
			fprintf('  ### DESCARTADO - Las rectas no se intersectan ###\n')
			figure,plot(Profiles(:,k),'.-'),hold all,plot(500:1500,polyval(L1,500:1500),'-'),plot(500:1500,polyval(L2,500:1500),'-'),title(sprintf('o=%d, rectas no se cortan',o))
			continue
		end
		xc=P(1)/P(3);
		fprintf(', xc=%.2f',xc)
		yc=P(2)/P(3);
		C{q}(k,:)=[xc yc X(k) Y(k) k estd1 n1 estd2 n2];
		if o<length(ind) % Hay que estimar el siguiente xguess (coordenada de la siguiente intersección de líneas)
			[xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xc,X(ind(o+1)),Y(ind(o+1)));
			fprintf(', xguess=%d, shift=%d, mi=%.2f\n',xguess,shift,mi)
		end
		if show==true
			figure(nfig),plot(X(k),Y(k),'xb')
			drawnow limitrate
		end
%		figure,plot(Profiles(:,k),'.-'),hold all,plot(500:1500,polyval(L1,500:1500),'-'),plot(500:1500,polyval(L2,500:1500),'-'),xlim([xc-100 xc+100]),ylim([yc-100 yc+100]),title(sprintf('o=%d, rectas no se cortan',o))
	end
% 	figure,plot(X,Y,'xr'),hold all,plot(C{q}(:,3),C{q}(:,4),'xb'),legend('corner not found','corner found cam1')
	
end
figure
subplot(221),plot3(C{1}(:,3),C{1}(:,4),C{1}(:,1),'.'),title('xc cam 1')
subplot(222),plot3(C{1}(:,3),C{1}(:,4),C{1}(:,2),'.'),title('yc cam 1')
subplot(223),plot3(C{2}(:,3),C{2}(:,4),C{2}(:,1),'.'),title('xc cam 2')
subplot(224),plot3(C{2}(:,3),C{2}(:,4),C{2}(:,2),'.'),title('yc cam 2')

figure,plot(X,Y,'xr'),hold all
plot(C{1}(:,3),C{1}(:,4),'ob','MarkerSize',8)
plot(C{2}(:,3),C{2}(:,4),'sg','MarkerSize',12)
set(gca,'Ydir','reverse')
legend('corner not found','corner found cam1','corner found cam2')


figure
subplot(221);plot(C{1}(:,3),C{1}(:,6),'.'),title('cam 1 estd1 vs X')
subplot(223);plot(C{1}(:,4),C{1}(:,6),'.'),title('cam 1 estd1 vs Y')
subplot(222);plot(C{1}(:,3),C{1}(:,7),'.'),title('cam 1 n1 vs X')
subplot(224);plot(C{1}(:,4),C{1}(:,7),'.'),title('cam 1 n1 vs Y')

figure
subplot(221);plot(C{1}(:,3),C{1}(:,8),'.'),title('cam 1 estd2 vs X')
subplot(223);plot(C{1}(:,4),C{1}(:,8),'.'),title('cam 1 estd2 vs Y')
subplot(222);plot(C{1}(:,3),C{1}(:,9),'.'),title('cam 1 n2 vs X')
subplot(224);plot(C{1}(:,4),C{1}(:,9),'.'),title('cam 1 n2 vs Y')


figure
subplot(221);plot(C{2}(:,3),C{2}(:,6),'.'),title('cam 2 estd1 vs X')
subplot(223);plot(C{2}(:,4),C{2}(:,6),'.'),title('cam 2 estd1 vs Y')
subplot(222);plot(C{2}(:,3),C{2}(:,7),'.'),title('cam 2 n1 vs X')
subplot(224);plot(C{2}(:,4),C{2}(:,7),'.'),title('cam 2 n1 vs Y')

figure
subplot(221);plot(C{2}(:,3),C{2}(:,8),'.'),title('cam 2 estd2 vs X')
subplot(223);plot(C{2}(:,4),C{2}(:,8),'.'),title('cam 2 estd2 vs Y')
subplot(222);plot(C{2}(:,3),C{2}(:,9),'.'),title('cam 2 n2 vs X')
subplot(224);plot(C{2}(:,4),C{2}(:,9),'.'),title('cam 2 n2 vs Y')


save(fullfile(basepath,'intersections.mat'),'C')

