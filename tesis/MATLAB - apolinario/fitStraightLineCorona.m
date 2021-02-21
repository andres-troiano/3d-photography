function [L,estd,n,iR,iL]=fitStraightLineCorona(x,y,ind)



% n0 = 20;
n0 = 15; % de prueba para casos problemáticos
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

% plot(x1(ind), y1(ind), '*')

n=sum(ind);
if n<10
	return
end
N=n;


sigma=[3, 3, 3, 3, 3, 3, 3, 3];
for l=1:8 %Iterar para obtener el mejor ajuste de esos datos correspondientes a ind.
	L1=[x1(ind) ones(length(x1(ind)),1)]\y1(ind);
	estd1=std([x1(ind) ones(length(x1(ind)),1)]*L1-y1(ind));
	e=abs([x1 ones(length(x1),1)]*L1-y1);
%     ind=e<3*estd1 & ind;
	ind=e<sigma(l)*estd1 & ind;
	n=sum(ind);
    
	if n<10
		return
	end
	if n==N
		break
    end

%     plot(x1(ind), y1(ind), 'g.'), plot(x1(ind), polyval(L1, x1(ind)), '-r')
end
% figure,plot(x1(ind),y1(ind),'.-'),hold all,plot(x1(ind),polyval(L1,x1(ind)),'-')
% plot(x1(ind), y1(ind), 'g.'), plot(x1(ind), polyval(L1, x1(ind)), '-r')

e=abs([x ones(length(x),1)]*L1-y);
%e=abs(polyval(L1,x)-y);
% antes el umbral era 5 px. Para el radio 6 lo cambié por 3
ind=e<5;%3*estd; %Si, 10 px de error!
ind=y>0 & ind & x>x1(1)-100 & x<x1(end)+100 & y < 1088;
n=sum(ind);

% figure, hold all, plot(x(ind), y(ind), '.')

if n<n0
    L = NaN;
    estd = NaN;
    n = NaN;
    iR = NaN;
    iL = NaN;
	return
end
N=n;

% figure
% hold all
% ind=e<2 & ind; % de prueba para los casos problemáticos
sigma=[3, 3, 3, 3, 3, 3, 3, 3];
for l=1:8				%Iterar para obtener el mejor ajuste sobre todos los puntos.
    
	L1=[x(ind) ones(length(x(ind)),1)]\y(ind);
	estd1=std([x(ind) ones(length(x(ind)),1)]*L1-y(ind));
	e=abs([x ones(length(x),1)]*L1-y);
% 	ind=e<3*estd1 & ind;
    ind=e<sigma(l)*estd1 & ind; % de prueba para los casos problemáticos
	n=sum(ind);
	if n<n0
		return
	end
	if n==N
		break
	end
end



flag = 1;

ind(find(ind,5,'last'))=false;	% No considerar los 5 puntos en los extremos para evitar la punta redonda.
ind(find(ind,5,'first'))=false;

% figure, hold all, grid on,
% 
% plot(x(ind), y(ind), 'g.'), plot(x(ind), polyval(L1, x(ind)), '-r')
% figure, hold all, grid on, plot(x(ind), e(ind), '.'), title('Error')

n=sum(ind);
if n<n0-10
	return
end
L=[x(ind) ones(length(x(ind)),1)]\y(ind);
estd=std([x(ind) ones(length(x(ind)),1)]*L1-y(ind));
% L=polyfit(x(ind),y(ind),1);
% estd=std(abs(polyval(L,x(ind))-y(ind)));
% figure,plot(x(ind),y(ind),'.-'),hold all,plot(x(ind),polyval(L1,x(ind)),'-')

%devuelvo los índices correspondientes al primer y el último punto donde el
%ajuste tiene validez
iR = find(ind,1,'last');
iL = find(ind,1,'first');

end