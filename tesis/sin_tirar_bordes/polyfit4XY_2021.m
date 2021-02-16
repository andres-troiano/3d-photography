function P=polyfit4XY(X,Y,Z)
%	Resolver P(X,Y)=Z donde P es un polinomio de orden 4 en ambas variables.
%	Los coeficientes son para evaluar de la siguiente manera: [1 x x^2 x.^3 x^4 y y^2 y^3 y^4 x*y x^2*y x^3*y x*y^2 x*y^3 x^2*y^2]*coef
% Normalizing
xmax=max(X);
xmin=min(X);
ymax=max(Y);
ymin=min(Y);
X=(X-xmin)/(xmax/2)-1;
Y=(Y-ymin)/(ymax/2)-1;
% 
M=[ones(length(X),1) X X.^2 X.^3 X.^4 Y Y.^2 Y.^3 Y.^4 X.*Y X.^2.*Y X.^3.*Y X.*Y.^2 X.*Y.^3 X.^2.*Y.^2];
ind=true(length(X),1);
n=sum(ind);
for k=1:10
	coef=M(ind,:)\Z(ind);	% M*coef=Z
	e=Z-M*coef;
%	fprintf('std=%f, n=%d\n',std(Z(ind)-M(ind,:)*coef),sum(ind))
	ind=abs(e)<3*std(Z(ind)-M(ind,:)*coef);
%	[sum(ind) n]
	if sum(ind)==n
		break
	end
	n=sum(ind);
end
P=struct('coef',coef,'xmin',xmin,'xmax',xmax,'ymin',ymin,'ymax',ymax,'ind',ind);
end
