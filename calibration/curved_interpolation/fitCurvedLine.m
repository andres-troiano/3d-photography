% por ahora sigo ajustando rectas, pero además ajusto cuadráticas para ver
% si hay término cuadrático no nulo.

function [L,estd,n]=fitCurvedLine(x,y,ind)
L=[];
estd=NaN;
n=0;
if any(ind<1)
	return
end
if any(ind>length(x))
	return
end
x1=x(ind);
y1=y(ind);
ind=true(length(x1),1) & y1>0 & y1<1088;
n=sum(ind);
if n<10
	return
end
N=n;

% figure, hold on, plot(x, y, '.-'), plot(x1,y1,'.r')

for l=1:8 %Iterar para obtener el mejor ajuste de esos datos correspondientes a ind.
    % ACA HAY UN AJUSTE
% 	L1=[x1(ind) ones(length(x1(ind)),1)]\y1(ind);
    L1=[(x1(ind)).^2 x1(ind) ones(length(x1(ind)),1)]\y1(ind);
% 	estd1=std([x1(ind) ones(length(x1(ind)),1)]*L1-y1(ind));
    estd1=std([(x1(ind)).^2 x1(ind) ones(length(x1(ind)),1)]*L1-y1(ind));
% 	e=abs([x1 ones(length(x1),1)]*L1-y1);
    e=abs([x1.^2 x1 ones(length(x1),1)]*L1-y1);
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
% figure,plot(x1(ind),y1(ind),'.-'),hold all,plot(x1(ind),polyval(L1,x1(ind)),'-')

% e=abs([x ones(length(x),1)]*L1-y);
e=abs([x.^2 x ones(length(x),1)]*L1-y);

% figure, plot(x,e,'.-')

%e=abs(polyval(L1,x)-y);
ind=e<5;%3*estd; %Si, 10 px de error!
ind=y>0 & ind & x>x1(1)-100 & x<x1(end)+100 & y < 1088;
n=sum(ind);
if n<40
	return
end
N=n;
for l=1:8				%Iterar para obtener el mejor ajuste sobre todos los puntos.
% 	L1=[x(ind) ones(length(x(ind)),1)]\y(ind);
    L1=[(x(ind)).^2 x(ind) ones(length(x(ind)),1)]\y(ind);
% 	estd1=std([x(ind) ones(length(x(ind)),1)]*L1-y(ind));
    estd1=std([(x(ind)).^2 x(ind) ones(length(x(ind)),1)]*L1-y(ind));
% 	e=abs([x ones(length(x),1)]*L1-y);
    e=abs([x.^2 x ones(length(x),1)]*L1-y);
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
% L=[x(ind) ones(length(x(ind)),1)]\y(ind);
L=[(x(ind)).^2 x(ind) ones(length(x(ind)),1)]\y(ind);
% estd=std([x(ind) ones(length(x(ind)),1)]*L1-y(ind));
estd=std([(x(ind)).^2 x(ind) ones(length(x(ind)),1)]*L1-y(ind));
% L=polyfit(x(ind),y(ind),1);
% estd=std(abs(polyval(L,x(ind))-y(ind)));

% figure,hold on, grid on, plot(x, y, '.-b'), plot(x(ind),y(ind),'.r'),hold all,plot(x(ind),polyval(L1,x(ind)),'-')

% como variante hago el mismo ajuste con polyfit a ver si da igual
% ya chequeé que da igual así que no lo uso
% L_alt = polyfit(x(ind), y(ind), 2);

end