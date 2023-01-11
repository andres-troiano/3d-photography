function [L,estd,n, ind]=fitStraightLine_longitud_trapecio(x,y,ind)
% atención! A diferencia de la función original, ésta trabaja sobre mm, con
% lo cual cualquier umbral de error absoluto tiene que estar en otra escala
L=[];
estd=NaN;
n=0;
% if any(ind<1)
% 	return
% end
if any(ind>length(x))
	return
end
% x1=x(ind);
% y1=y(ind);
x1=x;
y1=y;
% ind=true(length(x1),1) & y1>0 & y1<1088;
n=sum(ind);
if n<10
	return
end
N=n;

% set(0,'DefaultFigureVisible', 'on');
% close all
% figure, hold on, grid on, plot(x1,y1,'.-b'), plot(x1(ind),y1(ind),'.r')

% acá ajusta sólo en el rango que le di
for l=1:8 %Iterar para obtener el mejor ajuste de esos datos correspondientes a ind.
	L1=[x1(ind) ones(length(x1(ind)),1)]\y1(ind);
	estd1=std([x1(ind) ones(length(x1(ind)),1)]*L1-y1(ind));
	e=abs([x1 ones(length(x1),1)]*L1-y1);
%	L1=polyfit(x1(ind),y1(ind),1);
%	estd1=std(polyval(L1,x1(ind))-y1(ind));
%	e=abs(polyval(L1,x1)-y1);
	ind=e<3*estd1 & ind;
	n=sum(ind);
	if n<10
		return
	end
	if n==N
		break
	end
end

e=abs([x ones(length(x),1)]*L1-y);

% set(0,'DefaultFigureVisible', 'on');
% close all
% figure, hold on, grid on, plot(x1,y1,'.-b'), plot(x1(ind),y1(ind),'.r')

% figure, plot(x,e,'.-')

%e=abs(polyval(L1,x)-y);
ind=e<0.5;%3*estd; %Si, 10 px de error!
ind=y>0 & ind & x>x1(1)-100 & x<x1(end)+100 & y < 1088;
n=sum(ind);
if n<40 %ojo con esto! Antes acá abortaba
    L=L1;
    estd=estd1;
	return
end
N=n;
for l=1:8				%Iterar para obtener el mejor ajuste sobre todos los puntos.
	L1=[x(ind) ones(length(x(ind)),1)]\y(ind);
	estd1=std([x(ind) ones(length(x(ind)),1)]*L1-y(ind));
	e=abs([x ones(length(x),1)]*L1-y);
% 	L1=polyfit(x(ind),y(ind),1);
% 	estd1=std(polyval(L1,x(ind))-y(ind));
% 	e=abs(polyval(L1,x)-y);
	ind=e<3*estd1 & ind;
	n=sum(ind);
	if n<40
		return
	end
	if n==N
		break
	end
end
ind(find(ind,5,'last'))=false;	% No considerar los 5 puntos en los extremos para evitar la punta redonda.
ind(find(ind,5,'first'))=false;
n=sum(ind);
if n<30
	return
end
L=[x(ind) ones(length(x(ind)),1)]\y(ind);
estd=std([x(ind) ones(length(x(ind)),1)]*L1-y(ind));
% L=polyfit(x(ind),y(ind),1);
% estd=std(abs(polyval(L,x(ind))-y(ind)));

% set(0,'DefaultFigureVisible', 'on');
% close all
% figure,hold on, grid on, plot(x, y, '.-b'), plot(x(ind),y(ind),'.r'),hold all,plot(x(ind),polyval(L1,x(ind)),'-')

end